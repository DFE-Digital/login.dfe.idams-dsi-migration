/****** Object:  UserDefinedTableType [dbo].[idams_user_type]    Script Date: 11/07/2022 12:18:55 ******/
CREATE TYPE [dbo].[pp_org_type] AS TABLE(
	[upin] [varchar](100) NULL,
	[pimsProviderType] [varchar](100) NULL,
	[pimsStatus] [varchar](100) NULL,
	[districtAdministrativeName] [varchar](100) NULL,
	[masterDateOpened] [varchar](100) NULL,
	[sourceSystem] [varchar](100) NULL,
	[masterProviderTypeName] [varchar](100) NULL,
	[giasProviderType] [varchar](100) NULL,
	[masterUkprn] [varchar](100) NULL,
	[masterProviderCode] [varchar](100) NULL,
	[giasUrn] [varchar](100) NULL,
	[masterEdubaseUid] [varchar](100) NULL
)
GO


