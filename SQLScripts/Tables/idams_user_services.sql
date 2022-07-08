CREATE TABLE [dbo].[idams_user_services](
	[mail] [nvarchar](200) NULL,
	[serviceName] [varchar](200) NULL,
	[sendWelcomeEmail] [tinyint] NOT NULL,
	[sendPasswordEmail] [tinyint] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[idams_user_services] ADD  CONSTRAINT [DF_idams_user_services_sendWelcomeEmail]  DEFAULT ((0)) FOR [sendWelcomeEmail]
GO

ALTER TABLE [dbo].[idams_user_services] ADD  CONSTRAINT [DF_idams_user_services_sendPasswordEmail]  DEFAULT ((0)) FOR [sendPasswordEmail]
GO


