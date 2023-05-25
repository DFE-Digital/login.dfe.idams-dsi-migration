CREATE TABLE [dbo].[idams_user_data_updates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Idamsuid] [nvarchar](50) NOT NULL,
	[fieldchanged] [varchar](50) NULL,
	[beforevalue] [varchar](200) NULL,
	[updatedvalue] [varchar](200) NULL,
	[updatedat] [datetime2](7) NULL,
 CONSTRAINT [PK_idams_user_data_updates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


