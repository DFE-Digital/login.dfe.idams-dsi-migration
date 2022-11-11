CREATE TABLE [dbo].[idams_user_services](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[mail] [nvarchar](200) NULL,
	[serviceName] [varchar](200) NULL,
	[sendWelcomeEmail] [tinyint] NOT NULL,
	[sendPasswordEmail] [tinyint] NOT NULL,
	[superuser] [nvarchar](10) NULL,
	[dateSendWelcomeEmail] [datetime2](7) NULL,
	[dateSendPasswordEmail] [datetime2](7) NULL,
 CONSTRAINT [PK_idams_user_services] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[idams_user_services] ADD  CONSTRAINT [DF_idams_user_services_sendWelcomeEmail]  DEFAULT ((0)) FOR [sendWelcomeEmail]
GO

ALTER TABLE [dbo].[idams_user_services] ADD  CONSTRAINT [DF_idams_user_services_sendPasswordEmail]  DEFAULT ((0)) FOR [sendPasswordEmail]
GO

ALTER TABLE [dbo].[idams_user_services] ADD  CONSTRAINT [DF__idams_use__super__540C7B00]  DEFAULT ('No') FOR [superuser]
GO

ALTER TABLE [dbo].[idams_user_services]  WITH CHECK ADD  CONSTRAINT [FK_idams_user_services_idams_user] FOREIGN KEY([userId])
REFERENCES [dbo].[idams_user] ([Id])
GO

ALTER TABLE [dbo].[idams_user_services] CHECK CONSTRAINT [FK_idams_user_services_idams_user]
GO


