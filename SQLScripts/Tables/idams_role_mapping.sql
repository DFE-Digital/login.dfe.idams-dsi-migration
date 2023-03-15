CREATE TABLE [dbo].[idams_role_mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[idams_role_name] [varchar](500) NULL,
	[dsi_role_name] [varchar](500) NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_idams_role_mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

