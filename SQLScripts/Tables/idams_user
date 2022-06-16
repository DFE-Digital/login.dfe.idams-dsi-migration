CREATE TABLE [dbo].[idams_user](
	[uid] [nvarchar](50) NULL,
	[name] [nvarchar](200) NULL,
	[upin] [nvarchar](50) NULL,
	[ukprn] [nvarchar](50) NULL,
	[superuser] [nvarchar](10) NULL,
	[modifytimestamp] [nvarchar](50) NULL,
	[mail] [nvarchar](200) NULL,
	[hasInvitationSent] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[idams_user] ADD  CONSTRAINT [DF__idams_use__hasIn__2B0A656D]  DEFAULT ((0)) FOR [hasInvitationSent]
GO