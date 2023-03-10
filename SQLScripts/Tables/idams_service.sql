CREATE TABLE [dbo].[idams_service](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[perian_serviceId] [varchar](200) NULL,
	[perian_serviceName] [varchar](200) NULL,
	[dfe_serviceId] [uniqueidentifier] NULL,
	[dfe_clientId] [varchar](50) NULL,
	[service_url] VARCHAR (255) NULL
 CONSTRAINT [PK_idams_service] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


