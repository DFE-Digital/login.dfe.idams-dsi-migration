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
                log.LogInformation($"Blob '{name}' doesn't have the .csv extension. Skipping processing.");
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
            var connectionString = String.Format("Server=tcp:{0},1433;Initial Catalog={1};Persist Security Info=False;User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
                         hostName, directoriesdbName, directoriesdbUserName, directoriesdbPassword);

            return connectionString;
        }
        private static void ProcessCSVFile(Stream myBlob, string name, ILogger log)
        {
            
            List<idamsUserCSVItem> items;
            int pFrom;
            int pTo;
            String result = name;
            if (!string.IsNullOrEmpty(name))
            {
                pFrom = name.IndexOf("_") + "_".Length;
                pTo = name.LastIndexOf(".");
                result = name[pFrom..pTo];
            }
            string serviceId = result;
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
                DataTable dtRoleMappings = new DataTable("rolemappings");
                DataTable dtResult = new DataTable("idamsusers");
                dtResult.Columns.Add("serviceId", typeof(string));
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

                foreach (idamsUserCSVItem item in items)
                {
                    log.LogInformation($"ServiceId : '{serviceId}' ");
                    // Check for MYESF Service
                    if (serviceId == "sfs")
                    {
                        log.LogInformation("MyESF Service");
                        using (var sqlConn = new SqlConnection(CreateConnectionString()))

                        {
                            try
                            {
                                log.LogInformation($"SQL Connection is open");
                                string commandText = "SELECT * FROM dbo.idams_role_mapping";
                                SqlCommand idamsrolemappingCommand = new SqlCommand(commandText, sqlConn);
                                                               
                                sqlConn.Open();
                                SqlDataAdapter da = new SqlDataAdapter(idamsrolemappingCommand);
                                da.Fill(dtRoleMappings);
                                log.LogInformation("DataTable Idams Role Mappings Count: " + dtRoleMappings.Rows.Count);
                            }
                            catch (Exception ex)
                            {
                                log.LogInformation(ex.Message);

                            }

                            finally
                            {
                                sqlConn?.Close();
                                log.LogInformation($"SQL Connection is closed");
                            }
                        }
                        if(dtRoleMappings.Rows.Count > 0)
                        {
                            string searchExpression = "idams_role_name =" + item.roleName;
                            System.Data.DataRow[] drRowMappings = dtRoleMappings.Select(searchExpression);
                            if(drRowMappings.Length > 0)
                            {
                                log.LogInformation("Roles found for MYESF");
                                foreach (System.Data.DataRow row in drRowMappings)
                                {
                                    dtResult.Rows.Add(item.uid, item.name, item.givenName, item.sn, item.upin, item.ukprn, item.superuser, item.modifytimestamp,
                                    item.mail, serviceId, row["dsi_role_name"].ToString());
                                }
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
                        CommandType = CommandType.StoredProcedure
                    };
                    SqlParameter sqlParameter = idamsuserimportCommand.Parameters.AddWithValue("@idams_user_type", dtResult);
                    idamsuserimportCommand.Connection = sqlConn;
                    sqlConn.Open();
                    var rows = idamsuserimportCommand.ExecuteNonQuery();
                    log.LogInformation($"{rows} rows were updated");

                }
                catch (Exception ex)
                {
                    log.LogInformation(ex.Message);

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
