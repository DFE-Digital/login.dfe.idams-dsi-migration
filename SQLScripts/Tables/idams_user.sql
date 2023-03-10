CREATE TABLE [dbo].[idams_user](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [nvarchar](50) NULL,
	[name] [nvarchar](200) NULL,
	[givenName] [nvarchar](200) NULL,
	[sn] [nvarchar](200) NULL,
	[upin] [nvarchar](50) NULL,
	[ukprn] [nvarchar](50) NULL,
	[modifytimestamp] [nvarchar](50) NULL,
	[mail] [nvarchar](200) NULL,
 CONSTRAINT [PK_idams_user] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


