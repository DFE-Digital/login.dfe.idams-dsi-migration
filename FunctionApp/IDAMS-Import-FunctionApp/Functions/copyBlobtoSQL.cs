using LINQtoCSV;
using Microsoft.Azure.WebJobs;
using System.Data.SqlClient;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using Microsoft.WindowsAzure.Storage.Blob;

using IDAMS_Import_FunctionApp.HelperClasses;

namespace IDAMS_Import_FunctionApp
{
   
    public static class copyBlobtoSQL
    {
       
        [FunctionName("copyBlobtoSQL")]
        public static void Run([BlobTrigger("attachments/{name}", Connection = "AzureWebJobsStorage")]Stream myBlob, string name, ILogger log)
        {
            log.LogInformation($"C# Blob trigger function Processed blob\n Name:{name} \n Size: {myBlob.Length} Bytes");

            string azureSQLConnectionString = Environment.GetEnvironmentVariable("AzureSQL");
            if (!name.EndsWith(".csv"))
            {
                log.LogWarning($"Blob '{name}' doesn't have the .csv extension. Skipping processing.");
                return;
            }

            log.LogInformation($"Processesing the csv file '{name}'");

            ProcessCSVFile(myBlob, name, log);
        }
        private static string CreateConnectionString()
        {
            var hostName = Environment.GetEnvironmentVariable("DATABASE_DIRECTORIES_HOST_NAME");
            var directoriesdbName = Environment.GetEnvironmentVariable("DATATBASE_DIRECTORIES_NAME");
            var directoriesdbUserName = Environment.GetEnvironmentVariable("DATABASE_DIRECTORIES_USERNAME");
            var directoriesdbPassword = Environment.GetEnvironmentVariable("DATABASE_DIRECTORIES_PASSWORD");
            var connectionString = String.Format("Server=tcp:{0},1433;Initial Catalog={1};Persist Security Info=False;User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=0;",
                         hostName, directoriesdbName, directoriesdbUserName, directoriesdbPassword);

            return connectionString;
        }
        private static void ProcessCSVFile(Stream myBlob, string name, ILogger log)
        {
            
            List<idamsUserCSVItem> items;
            int pFrom;
            int pTo;
            String result = name;
            bool existingData = false;
            string serviceId = "";
            if (!string.IsNullOrEmpty(name))
            {
                if (name.IndexOf("_") == -1)
                    serviceId = null;
                else
                {
                    pFrom = name.IndexOf("_") + "_".Length;
                    pTo = name.LastIndexOf(".");
                    result = name[pFrom..pTo];
                    serviceId = result;
                }
            }
            
            CsvFileDescription inputFileDescription = new CsvFileDescription
            {
                SeparatorChar = ',',
                FirstLineHasColumnNames = true,
                FileCultureName = "en-gb"
            };

            CsvContext cc = new CsvContext();

            using (StreamReader sr = new StreamReader(myBlob))
            {

                items = cc.Read<idamsUserCSVItem>(sr, inputFileDescription).ToList();

            }
            if (items != null)
            {
                log.LogInformation($"Number of items found: '{items.Count}'");
                DataTable dtRoleMappings = new DataTable();
                DataTable dtResult = new DataTable("idamsusers");
                dtResult.Columns.Add("roleName", typeof(string));
                dtResult.Columns.Add("uid", typeof(string));
                dtResult.Columns.Add("name", typeof(string));
                dtResult.Columns.Add("givenName", typeof(string));
                dtResult.Columns.Add("sn", typeof(string));
                dtResult.Columns.Add("upin", typeof(string));
                dtResult.Columns.Add("ukprn", typeof(string));
                dtResult.Columns.Add("superuser", typeof(string));
                dtResult.Columns.Add("modifytimestamp", typeof(string));
                dtResult.Columns.Add("mail", typeof(string));
                dtResult.Columns.Add("serviceId", typeof(string));

                dtRoleMappings = GetRoleMappings(log, dtRoleMappings);
                foreach (idamsUserCSVItem item in items)
                {
                   // log.LogInformation($"ServiceId : '{serviceId}' ");
                    // Check for MYESF Service
                    if (serviceId == "sfs")
                    {
                      //  log.LogInformation("MyESF Service");
                       
                        if (dtRoleMappings.Rows.Count > 0)
                        {

                            string filterExpr = string.Format("{0} = '{1}' ", "[idams_role_name]", item.roleName);
                          //  log.LogInformation("filterExpr : " + filterExpr);
                            System.Data.DataRow[] drRowMappings = dtRoleMappings.Select(filterExpr);
                            if (drRowMappings.Length > 0)
                            {
                            //    log.LogInformation("Roles found for MYESF");
                                foreach (System.Data.DataRow row in drRowMappings)
                                {

                                    dtResult.Rows.Add(item.uid, item.name, item.givenName, item.sn, item.upin, item.ukprn, item.superuser, item.modifytimestamp,
                                    item.mail, serviceId, row["dsi_role_name"].ToString());
                                }
                            }
                            else // Role do not exists in the mappings
                            {
                                if(item.roleName != "MYESF - Contract admin")
                                    dtResult.Rows.Add(item.uid, item.name, item.givenName, item.sn, item.upin, item.ukprn, item.superuser, item.modifytimestamp,
                                    item.mail, serviceId, item.roleName);
                            }
                        }


                    }
                    else // Other Services
                    {
                        dtResult.Rows.Add(item.uid, item.name, item.givenName, item.sn, item.upin, item.ukprn, item.superuser, item.modifytimestamp,
                        item.mail, serviceId, item.roleName);
                    }
                }
                log.LogInformation($"Records Count in Data Table '{dtResult.Rows.Count}' ");
                ImportDataToSQL(name, log, dtResult);
            }
        }

        private static DataTable GetRoleMappings(ILogger log, DataTable dtRoleMappings)
        {
            using (var sqlConn = new SqlConnection(CreateConnectionString()))

            {
                try
                {
                    dtRoleMappings = new DataTable();
                    log.LogInformation($"SQL Connection is open");
                    string commandText = "SELECT * FROM dbo.idams_role_mapping where active = 1";
                    SqlCommand idamsrolemappingCommand = new SqlCommand(commandText, sqlConn);
                    idamsrolemappingCommand.CommandTimeout = 0;

                    sqlConn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(idamsrolemappingCommand);
                    da.Fill(dtRoleMappings);

                }
                catch (Exception ex)
                {
                    log.LogError(ex.Message);

                }

                finally
                {
                    sqlConn?.Close();
                    log.LogInformation($"SQL Connection is closed");
                }
            }

            return dtRoleMappings;
        }

        private static void ImportDataToSQL(string name, ILogger log, DataTable dtResult)
        {
            log.LogInformation($"Blob '{name}' found. Uploading to Azure SQL");

            


            using (var sqlConn = new SqlConnection(CreateConnectionString()))

            {
                try
                {
                    log.LogInformation($"SQL Connection is open");
                    SqlCommand idamsuserimportCommand = new SqlCommand
                    {
                        CommandText = "dbo.sp_IDAMSCSVDataMerge",
                        CommandType = CommandType.StoredProcedure,
                        CommandTimeout = 0
                    };
                    SqlParameter sqlParameter = idamsuserimportCommand.Parameters.AddWithValue("@idams_user_type", dtResult);
                    idamsuserimportCommand.Connection = sqlConn;
                    sqlConn.Open();
                    var rows = idamsuserimportCommand.ExecuteNonQuery();
                    log.LogInformation($"{rows} rows were updated");

                }
                catch (Exception ex)
                {
                    log.LogError(ex.Message);

                }

                finally
                {
                    sqlConn?.Close();
                    log.LogInformation($"SQL Connection is closed");
                    
                }
            }
        }

        public static void CreateTableValuedParameter(this SqlParameterCollection paramCollection, string parameterName, List<string> data)
        {
            if (paramCollection != null)
            {
                var p = paramCollection.Add(parameterName, SqlDbType.Structured);
                p.TypeName = "dbo.idams_user_type";
                DataTable _dt = new DataTable() { Columns = { "Value" } };
                data.ForEach(value => _dt.Rows.Add(value));
                p.Value = _dt;
            }
        }
    }
}
