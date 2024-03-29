using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Collections;

namespace IDAMS_Import_FunctionApp.Functions
{
    public static class copyPPDatatoSQL
    {
        [FunctionName("copyPPDatatoSQL")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log
        )
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string name = "copyPPtoSQL";
            int recordNumber = 0;
            var limit = Convert.ToInt32(Environment.GetEnvironmentVariable("PP_API_LIMIT"));
            var offset = Convert.ToInt32(Environment.GetEnvironmentVariable("PP_API_OFFSET"));
            int pageNumber = 1;
            JArray arr = null;
            DataTable dtResult = new DataTable("pporgs");
            DataTable dtWithoutDuplicates = new DataTable("pporgsnoduplicates");
            dtResult.Columns.Add("upin", typeof(string));
            dtResult.Columns.Add("pimsProviderType", typeof(string));
            dtResult.Columns.Add("pimsStatus", typeof(string));
            dtResult.Columns.Add("districtAdministrativeName", typeof(string));
            dtResult.Columns.Add("masterDateOpened", typeof(string));
            dtResult.Columns.Add("sourceSystem", typeof(string));
            dtResult.Columns.Add("masterProviderTypeName", typeof(string));
            dtResult.Columns.Add("giasProviderType", typeof(string));
            dtResult.Columns.Add("masterUkprn", typeof(string));
            dtResult.Columns.Add("masterprovidercode", typeof(string));
            dtResult.Columns.Add("giasUrn", typeof(string));
            dtResult.Columns.Add("masterEdubaseUid", typeof(string));

            do
            {
                log.LogInformation($"------Empty Data Table------");
                dtResult.Clear();
                log.LogInformation($"Limit: " + limit);
                log.LogInformation($"Offset: " + offset);

                string uri =
                    Environment.GetEnvironmentVariable("PP_API_ENDPOINT_URL")
                    + "?limit="
                    + limit
                    + "&offset="
                    + offset;

                log.LogInformation($"API URL: " + uri);

                var webRequest = (HttpWebRequest)WebRequest.Create(uri);
                webRequest.Method = "GET";
                webRequest.ContentType = "application/json";
                webRequest.Headers["x-functions-key"] = Environment.GetEnvironmentVariable(
                    "PP_API_FUNCTION_KEY"
                );

                using var webResponse = (HttpWebResponse)webRequest.GetResponse();
                if (webResponse.StatusCode == HttpStatusCode.OK)
                {
                    var reader = new StreamReader(webResponse.GetResponseStream());
                    string s = reader.ReadToEnd();
                    arr = JsonConvert.DeserializeObject<JArray>(s);
                    //log.LogInformation($"Array Size : " + arr.Count);
                    //if (arr == null) break;

                    foreach (JObject obj in arr)
                    {
                        recordNumber++;
                        string upin = obj.Value<string>("masterUpin");
                        string pimsProviderType = obj.Value<string>("pimsProviderType");
                        string pimsStatus = obj.Value<string>("pimsStatus");
                        string districtAdministrativeName = obj.Value<string>("districtAdministrativeName");
                        string masterDateOpened = obj.Value<string>("masterDateOpened");
                        string sourceSystem = obj.Value<string>("sourceSystem");
                        string masterProviderTypeName = obj.Value<string>("masterProviderTypeName");
                        string giasProviderType = obj.Value<string>("giasProviderType");
                        string masterUkprn = obj.Value<string>("masterUkprn");
                        string masterProviderCode = obj.Value<string>("masterProviderCode");
                        string giasUrn = obj.Value<string>("giasUrn");
                        string masterEdubaseUid = obj.Value<string>("masterEdubaseUid");

                        log.LogInformation($"------Record Start-----");
                      //  log.LogInformation($"Page Number : {pageNumber}");
                        log.LogInformation($"Record Number: {recordNumber}");
                        log.LogInformation($"upin: {upin}");
                        log.LogInformation($"masterUkprn: {masterUkprn}");
                        log.LogInformation($"masterProviderCode: {masterProviderCode}");
                        log.LogInformation($"giasUrn: {giasUrn}");
                        log.LogInformation($"giasProviderType: {giasProviderType}");
                        log.LogInformation($"------Record End-----");

                        dtResult.Rows.Add(
                            upin,
                            pimsProviderType,
                            pimsStatus,
                            districtAdministrativeName,
                            masterDateOpened,
                            sourceSystem,
                            masterProviderTypeName,
                            giasProviderType,
                            masterUkprn,
                            masterProviderCode,
                            giasUrn,
                            masterEdubaseUid
                        );
                    }
                    log.LogInformation($"------SQL Update Start------");
                    log.LogInformation($"DataTable Size: " + dtResult.Rows.Count);
                
                  log.LogInformation($"------Remove Duplicate Records from Datatable------");
                  dtWithoutDuplicates = RemoveDuplicateRows(dtResult, "masterUkprn",log);
                ImportDataToSQL(name, log, dtWithoutDuplicates);
                }
                offset += limit;
                pageNumber += 1;
            } while (arr != null & arr.Count > 0);

            string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }

        private static void ImportDataToSQL(string name, ILogger log, DataTable dtResult)
        {
            
            var hostName = Environment.GetEnvironmentVariable("DATABASE_ORGANISATIONS_HOST_NAME");
            var organisationsdbName = Environment.GetEnvironmentVariable(
                "DATATBASE_ORGANISATIONS_NAME"
            );
            var organisationsdbUserName = Environment.GetEnvironmentVariable(
                "DATABASE_ORGANISATIONS_USERNAME"
            );
            var organisationsdbPassword = Environment.GetEnvironmentVariable(
                "DATABASE_ORGANISATIONS_PASSWORD"
            );
            var connectionString = String.Format(
                "Server=tcp:{0},1433;Initial Catalog={1};Persist Security Info=False;User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
                hostName,
                organisationsdbName,
                organisationsdbUserName,
                organisationsdbPassword
            );

            using (var sqlConn = new SqlConnection(connectionString))
            {
                try
                {
                    log.LogInformation($"SQL Connection is Open");
                    SqlCommand ppimportCommand = new SqlCommand
                    {
                        CommandText = "dbo.sp_PPJSONDataMerge",
                        CommandType = CommandType.StoredProcedure
                    };
                    SqlParameter sqlParameter = ppimportCommand.Parameters.AddWithValue(
                        "@pp_org_type",
                        dtResult
                    );
                    ppimportCommand.Connection = sqlConn;
                    sqlConn.Open();
                    var rows = ppimportCommand.ExecuteNonQuery();
                    log.LogInformation($"{rows} rows were updated");
                }
                catch (Exception ex)
                {
                    log.LogInformation(ex.Message);
                }
                finally
                {
                    log.LogInformation($"SQL Connection is Closed");
                    sqlConn?.Close();
                }
            }
        }
        public static void CreateTableValuedParameter(
            this SqlParameterCollection paramCollection,
            string parameterName,
            List<string> data
        )
        {
            if (paramCollection != null)
            {
                var p = paramCollection.Add(parameterName, SqlDbType.Structured);
                p.TypeName = "dbo.pp_org_type";
                DataTable _dt = new DataTable() { Columns = { "Value" } };
                data.ForEach(value => _dt.Rows.Add(value));
                p.Value = _dt;
            }
        }
        public static DataTable RemoveDuplicateRows(DataTable dTable, string colName, ILogger log)
        {
            log.LogInformation("Size of Data Table - Before: " + dTable.Rows.Count);
            Hashtable hTable = new Hashtable();
            ArrayList duplicateList = new ArrayList();

            //Add list of all the unique item value to hashtable, which stores combination of key, value pair.
            //And add duplicate item value in arraylist.
            foreach (DataRow drow in dTable.Rows)
            {
                if (hTable.Contains(drow[colName]))
                    duplicateList.Add(drow);
                else
                    hTable.Add(drow[colName], string.Empty);
            }

            //Removing a list of duplicate items from datatable.
            foreach (DataRow dRow in duplicateList)
                dTable.Rows.Remove(dRow);

            //Datatable which contains unique records will be return as output.
            log.LogInformation("Size of Data Table - After: " + dTable.Rows.Count);
            return dTable;
        }
    }
}
