using System;
using System.Collections.Generic;
using System.Text;
using LINQtoCSV;

namespace IDAMS_Import_FunctionApp.HelperClasses
{
   public class idamsUserCSVItem
    {
            [CsvColumn(Name = "uid")]
            public string uid { get; set; }

            [CsvColumn(Name = "Name")]
            public string name { get; set; }

            [CsvColumn(Name = "givenName")]
            public string givenname { get; set; }

            [CsvColumn(Name = "sn")]
            public string surname { get; set; }

            [CsvColumn(Name = "sfaProviderUserType")]
            public string sfaproviderusertype { get; set; }

            [CsvColumn(Name = "A1LifecycleState")]
            public string a1lifecyclestate { get; set; }

            [CsvColumn(Name = "UPIN")]
            public string upin { get; set; }

            [CsvColumn(Name = "UKPRN")]
            public string ukprn { get; set; }

            [CsvColumn(Name = "Superuser")]
            public string superuser { get; set; }

            [CsvColumn(Name = "mobile")]
            public string mobile { get; set; }

            [CsvColumn(Name = "createtimestamp")]
            public string createtimestamp { get; set; }

            [CsvColumn(Name = "mail")]
            public string mail { get; set; }
        }
    
}
