CREATE TABLE [dbo].[idams_user_services](
	[mail] [nvarchar](200) NULL,
	[serviceName] [varchar](200) NULL,
	[sendWelcomeEmail] [bit] NULL,
	[sendPasswordEmail] [bit] NULL
) ON [PRIMARY]