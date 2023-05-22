CREATE TABLE [dbo].[idams_user_services_roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[mail] [nvarchar](200) NULL,
	[uid] [nvarchar](50) NULL,
	[serviceName] [varchar](500) NOT NULL,
	[roleName] [varchar](500) NULL,
 CONSTRAINT [PK_idams_user_services_roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


