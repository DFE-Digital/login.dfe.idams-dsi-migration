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

                       
            var limit = 1000;
            var offset = 0;
            string masterProviderCode = "";
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
                         masterProviderCode = obj.Value<string>("masterProviderCode") ?? "";
                    }
                }

                log.LogInformation($"Master Provider Code: {masterProviderCode}");
                offset += limit;
            }
            string responseMessage = string.IsNullOrEmpty(name)
                    ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                    : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}
