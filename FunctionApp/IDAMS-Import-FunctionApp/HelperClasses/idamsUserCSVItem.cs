using System;
using System.Collections.Generic;
using System.Text;
using LINQtoCSV;

namespace IDAMS_Import_FunctionApp.HelperClasses
{
   public class idamsUserCSVItem
    {
        
            [CsvColumn(Name = "roleName")]
            public string roleName { get; set; }
            [CsvColumn(Name = "uid")]
            public string uid { get; set; }

            [CsvColumn(Name = "Name")]
            public string name { get; set; }

            [CsvColumn(Name = "UPIN")]
            public string upin { get; set; }

            [CsvColumn(Name = "UKPRN")]
            public string ukprn { get; set; }

            [CsvColumn(Name = "Superuser")]
            public string superuser { get; set; }

            [CsvColumn(Name = "modifytimestamp")]
            public string modifytimestamp { get; set; }

            [CsvColumn(Name = "mail")]
            public string mail { get; set; }
        }
    
}
