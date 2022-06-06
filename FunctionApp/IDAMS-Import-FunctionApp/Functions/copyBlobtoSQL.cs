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

        private static void ProcessCSVFile(Stream myBlob, string name, ILogger log)
        {
            List<idamsUserCSVItem> items;

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

                DataTable dtResult = new DataTable("idamsusers");
                dtResult.Columns.Add("uid", typeof(string));
                dtResult.Columns.Add("name", typeof(string));
                dtResult.Columns.Add("givenname", typeof(string));
                dtResult.Columns.Add("surname", typeof(string));
                dtResult.Columns.Add("sfaproviderusertype", typeof(string));
                dtResult.Columns.Add("a1lifecyclestate", typeof(string));
                dtResult.Columns.Add("upin", typeof(string));
                dtResult.Columns.Add("ukprn", typeof(string));
                dtResult.Columns.Add("superuser", typeof(string));
                dtResult.Columns.Add("mobile", typeof(string));
                dtResult.Columns.Add("createtimestamp", typeof(string));
                dtResult.Columns.Add("mail", typeof(string));

                foreach (idamsUserCSVItem item in items)
                {
                    dtResult.Rows.Add(item.uid, item.name, item.givenname, item.surname, item.sfaproviderusertype,
                    item.a1lifecyclestate, item.upin, item.ukprn, item.superuser, item.mobile, item.createtimestamp,
                    item.mail);
                }

                ImportDataToSQL(name, log, dtResult);
            }
        }

        private static void ImportDataToSQL(string name, ILogger log, DataTable dtResult)
        {
            log.LogInformation($"Blob '{name}' found. Uploading to Azure SQL");

            var hostName = Environment.GetEnvironmentVariable("DATABASE_DIRECTORIES_HOST_NAME");
            var directoriesdbName = Environment.GetEnvironmentVariable("DATATBASE_DIRECTORIES_NAME");
            var directoriesdbUserName = Environment.GetEnvironmentVariable("DATABASE_DIRECTORIES_USERNAME");
            var directoriesdbPassword = Environment.GetEnvironmentVariable("DATABASE_DIRECTORIES_PASSWORD");
            var connectionString = String.Format("Server=tcp:{0},1433;Initial Catalog={1};Persist Security Info=False;User ID={2};Password={3};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
                         hostName, directoriesdbName, directoriesdbUserName, directoriesdbPassword);


            using (var sqlConn = new SqlConnection(connectionString))

            {
                try
                {
                    log.LogInformation($"SQL Connection is Open");
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