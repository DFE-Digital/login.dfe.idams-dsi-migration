ALTER TABLE dbo.organisation
ADD
	 masteringCode NVARCHAR (50) NULL,
	 ProviderProfileID NVARCHAR (100) NULL,
	 SourceSystem NVARCHAR (100) NULL,
	 UPIN NVARCHAR (100) NULL,
	 ProviderTypeName NVARCHAR (500) NULL,
     GIASProviderType NVARCHAR (100) NULL,
	 PIMSProviderType NVARCHAR (100) NULL,
 	 ProviderTypeCode INT NULL,
	 PIMSProviderTypeCode INT NULL,
	 PIMSStatus NVARCHAR (100) NULL,
	 OpenedOn NVARCHAR (100) NULL,
	 DistrictAdministrativeName NVARCHAR (500) NULL,
	 DistrictAdministrativeCode NVARCHAR (100) NULL
GO
-- Stored Procedures---
CREATE PROCEDURE [dbo].[SyncOrgs]
AS

BEGIN

update organisation
set ProviderProfileID = p.ProviderProfileID
from
organisation o INNER JOIN pp_cache p
on p.URN = o.URN AND o.ProviderProfileID IS NULL

update organisation
set ProviderProfileID = p.ProviderProfileID
from
organisation o INNER JOIN pp_cache p
on o.URN IS NULL AND p.UKPRN = o.UKPRN AND o.ProviderProfileID IS NULL

update organisation
set name=p.name,
 Category=p.Category,
 Type=p.Type,
 URN=p.URN,
 UID=p.UID,
 UKPRN=p.UKPRN,
 EstablishmentNumber=p.EstablishmentNumber,
 Status=p.Status,
 ClosedOn=p.ClosedOn,
 Address=p.Address,
 phaseOfEducation=p.phaseOfEducation,
 statutoryLowAge=p.statutoryLowAge,
 statutoryHighAge=p.statutoryHighAge,
 telephone=p.telephone,
 regionCode=p.regionCode,
 legacyId=p.legacyId,
 companyRegistrationNumber=p.companyRegistrationNumber,
 createdAt=p.createdAt,
 updatedAt=p.updatedAt,
 DistrictAdministrative_code=p.DistrictAdministrative_code,
 UPIN=p.UPIN,
 PIMSProviderType=p.PIMSProviderType,
 PIMSStatus=p.PIMSStatus,
 DistrictAdministrativeName=p.DistrictAdministrativeName,
 OpenedOn=p.OpenedOn,
 SourceSystem=p.SourceSystem,
 ProviderTypeName=p.ProviderTypeName,
 GIASProviderType=p.GIASProviderType,
 masteringCode=p.masteringCode,
 ProviderTypeCode=p.ProviderTypeCode,
 PIMSProviderTypeCode=p.PIMSProviderTypeCode
from
organisation o INNER JOIN pp_cache p
on p.ProviderProfileID = o.ProviderProfileID


insert into organisation (id,
name,
Category,
Type,
URN,
UID,
UKPRN,
EstablishmentNumber,
Status,
ClosedOn,
Address,
phaseOfEducation,
statutoryLowAge,
statutoryHighAge,
telephone,
regionCode,
legacyId,
companyRegistrationNumber,
createdAt,
updatedAt,
DistrictAdministrative_code,
ProviderProfileID,
UPIN,
PIMSProviderType,
PIMSStatus,
DistrictAdministrativeName,
OpenedOn,
SourceSystem,
ProviderTypeName,
GIASProviderType,
ProviderTypeCode,
masteringCode,
PIMSProviderTypeCode)
SELECT NEWID(), p.name, p.Category, p.Type, p.URN, p.UID, p.UKPRN,p.EstablishmentNumber,p.Status,p.ClosedOn,p.Address,p.phaseOfEducation,p.statutoryLowAge,p.statutoryHighAge,
p.telephone, p.regionCode,p.legacyId,p.companyRegistrationNumber, p.createdAt, p.updatedAt,p.DistrictAdministrative_code, p.ProviderProfileID,p.UPIN,
p.PIMSProviderType,p.PIMSStatus, p.DistrictAdministrativeName, p.OpenedOn,p.SourceSystem,p.ProviderTypeName, p.GIASProviderType,p.ProviderTypeCode,p.masteringCode,p.PIMSProviderTypeCode from pp_cache p
WHERE NOT EXISTS (select * from organisation o WHERE o.ProviderProfileID = p.ProviderProfileID)
END

GO
CREATE PROCEDURE [dbo].[SyncOrgsAssociation]
AS

BEGIN

DROP TABLE IF EXISTS #temporgAsso;

(SELECT (select top 1 id from organisation o WHERE o.ProviderProfileID=p.masterProviderCode) organisation_id,
(select top 1 id from organisation o WHERE o.ProviderProfileID=p.associatedMasterProviderCode) associated_organisation_id, p.linkType as link_type into #temporgAsso from pp_org_asso_cache p)

DELETE oa from organisation_association oa LEFT JOIN #temporgAsso view2
    on oa.associated_organisation_id = view2.associated_organisation_id AND oa.organisation_id = view2.organisation_id AND view2.link_type = oa.link_type
    Where view2.organisation_id IS NULL

--- insert script
INSERT INTO organisation_association (organisation_id,associated_organisation_id,link_type)
 SELECT view2.organisation_id, view2.associated_organisation_id, view2.link_type from #temporgAsso view2 LEFT JOIN organisation_association oa
    on oa.associated_organisation_id = view2.associated_organisation_id AND oa.organisation_id = view2.organisation_id AND view2.link_type = oa.link_type
    Where oa.organisation_id IS NULL

END
GO
-- Cache Tables
CREATE TABLE [dbo].[pp_cache](
	[id] [uniqueidentifier] NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[Category] [varchar](25) NULL,
	[Type] [varchar](25) NULL,
	[URN] [varchar](25) NULL,
	[UID] [varchar](25) NULL,
	[UKPRN] [varchar](25) NULL,
	[EstablishmentNumber] [varchar](25) NULL,
	[Status] [int] NOT NULL,
	[ClosedOn] [date] NULL,
	[Address] [nvarchar](max) NULL,
	[phaseOfEducation] [int] NULL,
	[statutoryLowAge] [int] NULL,
	[statutoryHighAge] [int] NULL,
	[telephone] [varchar](25) NULL,
	[regionCode] [char](1) NULL,
	[legacyId] [bigint] NULL,
	[companyRegistrationNumber] [varchar](50) NULL,
	[createdAt] [datetime2](7) NOT NULL,
	[updatedAt] [datetime2](7) NOT NULL,
	[masteringCode] [nvarchar](50) NULL,
	[ProviderProfileID] [nvarchar](100) NULL,
	[SourceSystem] [nvarchar](100) NULL,
	[UPIN] [nvarchar](100) NULL,
	[ProviderTypeName] [nvarchar](500) NULL,
	[GIASProviderType] [nvarchar](100) NULL,
	[PIMSProviderType] [nvarchar](100) NULL,
	[ProviderTypeCode] [int] NULL,
	[PIMSProviderTypeCode] [int] NULL,
	[PIMSStatus] [nvarchar](100) NULL,
	[OpenedOn] [nvarchar](100) NULL,
	[DistrictAdministrativeName] [nvarchar](500) NULL,
	[DistrictAdministrativeCode] [nvarchar](100) NULL,
	[DistrictAdministrative_code] [nvarchar](100) NULL,
	[refreshedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[pp_cache] ADD  DEFAULT ((1)) FOR [Status]
GO

ALTER TABLE [dbo].[pp_cache] ADD  DEFAULT (getdate()) FOR [refreshedAt]

GO
ALTER TABLE [dbo].[pp_cache] ADD  DEFAULT ((1)) FOR [Status]
GO


    CREATE TABLE [dbo].[pp_org_asso_cache](
        [masterProviderCode] [varchar](100) NOT NULL,
        [associatedMasterProviderCode] [varchar](100) NOT NULL,
        [linkType] [varchar](25) NOT NULL
    ) ON [PRIMARY]
    GO
    SET ANSI_PADDING ON
    GO
    CREATE NONCLUSTERED INDEX [idx_associatedMP] ON [dbo].[pp_org_asso_cache]
    (
        [associatedMasterProviderCode] ASC
    )WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
    GO

-- Indexes
GO
CREATE NONCLUSTERED INDEX [ProviderProfileID_index] ON [dbo].[organisation]
(
	[ProviderProfileID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
