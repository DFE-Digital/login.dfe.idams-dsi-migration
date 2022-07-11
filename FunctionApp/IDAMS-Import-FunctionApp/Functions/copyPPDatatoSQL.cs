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
using System.Text;
using Newtonsoft.Json.Linq;

namespace IDAMS_Import_FunctionApp.Functions
{
    public static class copyPPDatatoSQL
    {
        [FunctionName("copyPPDatatoSQL")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string name = "copyPPtoSQL";
            int recordNumber = 0;
            var limit = 1000;
            var offset = 0;
            int pageNumber = 1;
            string masterProviderCode = "";
            string upin = "";
            string pimsProviderType = "";
            string pimsStatus = "";
            string districtAdministrativeName = "";
            string masterDateOpened = "";
            string sourceSystem = "";
            string masterProviderTypeName = "";
            string giasProviderType = "";
            string masterUkprn = "";
            string giasUrn = "";
            string masterEdubaseUid = "";

            while (true)
            {
                
                string uri = Environment.GetEnvironmentVariable("PP_API_ENDPOINT_URL") + "?limit=" +limit + "&offset=" + offset;
                var webRequest = (HttpWebRequest)WebRequest.Create(uri);
                webRequest.Method = "GET";
                webRequest.ContentType = "application/json";
                webRequest.Headers["x-functions-key"] = Environment.GetEnvironmentVariable("PP_API_FUNCTION_KEY");
                  

                using var webResponse = (HttpWebResponse)webRequest.GetResponse();
                if (webResponse.StatusCode == HttpStatusCode.OK)
                {
                    var reader = new StreamReader(webResponse.GetResponseStream());
                    string s = reader.ReadToEnd();
                    var arr = JsonConvert.DeserializeObject<JArray>(s);
                    if (arr == null) break;

                    foreach (JObject obj in arr)
                    {
                        recordNumber++;
                        masterProviderCode = obj.Value<string>("masterProviderCode") ?? "";
                        upin = obj.Value<string>("upin") ?? "";
                        pimsProviderType = obj.Value<string>("pimsProviderType") ?? "";
                        pimsStatus = obj.Value<string>("pimsStatus") ?? "";
                        districtAdministrativeName = obj.Value<string>("districtAdministrativeName") ?? "";
                        masterDateOpened = obj.Value<string>("masterDateOpened") ?? "";
                        sourceSystem = obj.Value<string>("sourceSystem") ?? "";
                        masterProviderTypeName = obj.Value<string>("masterProviderTypeName") ?? "";
                        giasProviderType = obj.Value<string>("giasProviderType") ?? "";
                        masterUkprn = obj.Value<string>("masterUkprn") ?? "";
                        giasUrn = obj.Value<string>("giasUrn") ?? "";
                        masterEdubaseUid = obj.Value<string>("masterEdubaseUid") ?? "";

                        log.LogInformation($"------Record Start-----");
                        log.LogInformation($"Page Number : {pageNumber}");
                        log.LogInformation($"Record Number: {recordNumber}");
                        log.LogInformation($"upin: {upin}");
                        log.LogInformation($"pimsProviderType: {pimsProviderType}");
                        log.LogInformation($"pimsStatus: {pimsStatus}");
                        log.LogInformation($"districtAdministrativeName: {districtAdministrativeName}");
                        log.LogInformation($"masterDateOpened: {masterDateOpened}");
                        log.LogInformation($"sourceSystem: {sourceSystem}");
                        log.LogInformation($"masterProviderTypeName: {masterProviderTypeName}");
                        log.LogInformation($"giasProviderType: {giasProviderType}");
                        log.LogInformation($"masterUkprn: {masterUkprn}");
                        log.LogInformation($"Master Provider Code: {masterProviderCode}");
                        log.LogInformation($"giasUrn: {giasUrn}");
                        log.LogInformation($"masterEdubaseUid: {masterEdubaseUid}");
                        log.LogInformation($"------Record End-----");
                    }
                }
               

                offset += limit;
                pageNumber+=1;
            }
            string responseMessage = string.IsNullOrEmpty(name)
                    ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                    : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}
