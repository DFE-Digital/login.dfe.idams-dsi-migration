/****** Object:  UserDefinedTableType [dbo].[idams_user_type]    Script Date: 21/11/2022 10:45:45 ******/
CREATE TYPE [dbo].[idams_user_type] AS TABLE(
	[uid] [nvarchar](50) NULL,
	[name] [nvarchar](200) NULL,
	[givenName] [nvarchar](200) NULL,
	[sn] [nvarchar](200) NULL,
	[upin] [nvarchar](50) NULL,
	[ukprn] [nvarchar](50) NULL,
	[superuser] [nvarchar](10) NULL,
	[modifytimestamp] [nvarchar](50) NULL,
	[mail] [nvarchar](200) NULL,
	[serviceId] [nvarchar](200) NULL,
	[roleName] [nvarchar](500) NULL
)
GO


