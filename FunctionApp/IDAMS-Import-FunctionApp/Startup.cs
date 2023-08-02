using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;

[assembly: FunctionsStartup(typeof(IDAMS_Import_FunctionApp.Startup))]
namespace IDAMS_Import_FunctionApp
{
    public class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            // Configure Application Insights
            var instrumentationKey = "16650b26-5638-47f6-aeee-c4bcf18fb00d";
            var config = TelemetryConfiguration.Active;
            config.InstrumentationKey = instrumentationKey;
        }
        public override void Configure(IFunctionsHostBuilder builder)
        {
            // Configuration and services setup go here
        }
    }
}
