CREATE TABLE [dbo].[idams_user_role_updates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Idamsuid] [nvarchar](50) NULL,
	[mail] [nvarchar](200) NULL,
	[roleName] [nvarchar](500) NULL,
	[status] [varchar](50) NULL,
	[updatedat] [datetime2](7) NULL,
 CONSTRAINT [PK_idams_user_role_updates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


