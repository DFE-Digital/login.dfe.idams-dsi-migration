ALTER TABLE dbo.organisation
ADD
	[masteringCode] [nvarchar](50) NULL,
	[ProviderProfileID] [nvarchar](100) NULL,
	[SourceSystem] [nvarchar](100) NULL,
	[UPIN] [nvarchar](100) NULL,
	[ProviderTypeName] [nvarchar](500) NULL,
	[GIASProviderType] [nvarchar](100) NULL,
	[PIMSProviderType] [nvarchar](100) NULL,
	[ProviderTypeCode] [int] NULL,
	[PIMSProviderTypeCode] [int] NULL,
	[PIMSStatus] [int] NULL,
	[OpenedOn] [nvarchar](100) NULL,
	[DistrictAdministrativeName] [nvarchar](500) NULL,
	[DistrictAdministrativeCode] [nvarchar](100) NULL
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
	[PIMSStatus] [int] NULL,
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
-- Functions --
CREATE FUNCTION [dbo].[Getclosedduplicateorgsbyukprn] ()
returns TABLE
AS
    RETURN
      (
      -- Add the SELECT statement with parameter references here
      SELECT ukprn,status
       FROM   dbo.organisation
       WHERE  ukprn IN (SELECT ukprn
                        FROM   dbo.organisation
                        GROUP  BY ukprn
                        HAVING Count(ukprn) > 1) 
              ) 
CREATE FUNCTION [dbo].[Getclosedduplicateorgsbyurn] ()
returns TABLE AS
RETURN
(
       -- Add the SELECT statement with parameter references here
       SELECT urn,status
       FROM   dbo.organisation
       WHERE  urn IN
              (
                       SELECT   urn
                       FROM     dbo.organisation
                       GROUP BY urn
                       HAVING   Count(urn) > 1 )
      )
-- Stored Procedures---
CREATE PROCEDURE [dbo].[Syncorgs]
AS
  BEGIN
      --Start- Get Duplicate records by URN & UKPRN -Start-
      DECLARE @duplicate_urn_variable TABLE
        (
           urn    VARCHAR(25),
           status INT
        )
      DECLARE @duplicate_ukprn_variable TABLE
        (
           ukprn  VARCHAR(25),
           status INT
        )

      INSERT INTO @duplicate_urn_variable
      SELECT *
      FROM   Getclosedduplicateorgsbyurn()
      

      INSERT INTO @duplicate_ukprn_variable
      SELECT *
      FROM   Getclosedduplicateorgsbyukprn()
     
 --End- Get Duplicate records by URN & UKPRN -End-

      UPDATE organisation
      SET    providerprofileid = p.providerprofileid
      FROM   organisation o
             INNER JOIN pp_cache p
                     ON p.urn = o.urn
      WHERE  p.urn IS NOT NULL
             AND o.providerprofileid IS NULL
             AND ( o.urn NOT IN (SELECT urn
                                 FROM   @duplicate_urn_variable where Status = 2) ) -- Update for set of duplicates closed orgs
	  UPDATE organisation
      SET    providerprofileid = p.providerprofileid
      FROM   organisation o
             INNER JOIN pp_cache p
                     ON p.urn = o.urn
      WHERE  p.urn IS NOT NULL
             AND o.providerprofileid IS NULL
             AND ( o.urn  IN (SELECT urn
                                 FROM   @duplicate_urn_variable where Status <> 2) ) -- Update for set of duplicates not-closed orgs

      UPDATE organisation
      SET    providerprofileid = p.providerprofileid
      FROM   organisation o
             INNER JOIN pp_cache p
                     ON p.ukprn = o.ukprn
      WHERE  p.ukprn IS NOT NULL
             AND o.providerprofileid IS NULL
             AND ( o.ukprn NOT IN (SELECT ukprn
                                   FROM   @duplicate_ukprn_variable where Status = 2) ) -- Update for set of duplicates closed orgs
	 UPDATE organisation
      SET    providerprofileid = p.providerprofileid
      FROM   organisation o
             INNER JOIN pp_cache p
                     ON p.ukprn = o.ukprn
      WHERE  p.ukprn IS NOT NULL
             AND o.providerprofileid IS NULL
             AND ( o.ukprn  IN (SELECT ukprn
                                   FROM   @duplicate_ukprn_variable where Status <> 2) ) -- Update for set of duplicates not-closed orgs

      UPDATE organisation
      SET    NAME = p.NAME,
             urn = p.urn,
             [uid] = p.uid,
             ukprn = p.ukprn,
             establishmentnumber = p.establishmentnumber,
             [status] = p.status,
             closedon = p.closedon,
             [address] = p.address,
             phaseofeducation = p.phaseofeducation,
             statutorylowage = p.statutorylowage,
             statutoryhighage = p.statutoryhighage,
             telephone = p.telephone,
             regioncode = p.regioncode,
             legacyid = p.legacyid,
             companyregistrationnumber = p.companyregistrationnumber,
             createdat = p.createdat,
             updatedat = p.updatedat,
             masteringcode = p.masteringcode,
             providerprofileid = p.providerprofileid,
             sourcesystem = p.sourcesystem,
             upin = p.upin,
             providertypename = p.providertypename,
             giasprovidertype = p.giasprovidertype,
             pimsprovidertype = p.pimsprovidertype,
             providertypecode = p.providertypecode,
             pimsprovidertypecode = p.pimsprovidertypecode,
             openedon = p.openedon,
             pimsstatus = p.pimsstatus,
             districtadministrativename = p.districtadministrativename,
             districtadministrativecode = p.districtadministrativecode
      FROM   organisation o
             INNER JOIN pp_cache p
                     ON p.providerprofileid = o.providerprofileid

      INSERT INTO organisation
                  (id,
                   [name],
                   category,
                   [type],
                   urn,
                   [uid],
                   ukprn,
                   establishmentnumber,
                   [status],
                   closedon,
                   [address],
                   phaseofeducation,
                   statutorylowage,
                   statutoryhighage,
                   telephone,
                   regioncode,
                   legacyid,
                   companyregistrationnumber,
                   createdat,
                   updatedat,
                   masteringcode,
                   providerprofileid,
                   sourcesystem,
                   upin,
                   providertypename,
                   giasprovidertype,
                   pimsprovidertype,
                   providertypecode,
                   pimsprovidertypecode,
                   pimsstatus,
                   openedon,
                   districtadministrativename,
                   districtadministrativecode)
      SELECT Newid(),
             p.NAME,
             p.category,
             p.type,
             p.urn,
             p.uid,
             p.ukprn,
             p.establishmentnumber,
             p.status,
             p.closedon,
             p.address,
             p.phaseofeducation,
             p.statutorylowage,
             p.statutoryhighage,
             p.telephone,
             p.regioncode,
             p.legacyid,
             p.companyregistrationnumber,
             p.createdat,
             p.updatedat,
             p.masteringcode,
             p.providerprofileid,
             p.sourcesystem,
             p.upin,
             p.providertypename,
             p.giasprovidertype,
             p.pimsprovidertype,
             P.providertypecode,
             P.pimsprovidertypecode,
             p.pimsstatus,
             P.openedon,
             p.districtadministrativename,
             p.districtadministrativecode
      FROM   pp_cache p
      WHERE  NOT EXISTS (SELECT *
                         FROM   organisation o
                         WHERE  o.providerprofileid = p.providerprofileid)
             -- Add checks to ignore the duplicate URN or UKPRN insertion from PP for Closed Orgs in DSI
             AND ( ( urn NOT IN (SELECT urn
                                 FROM   @duplicate_urn_variable where status = 2)
                     AND urn IS NOT NULL )
                    OR ( ukprn NOT IN (SELECT ukprn
                                       FROM  @duplicate_ukprn_variable where status = 2)
                         AND ukprn IS NOT NULL ) )
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

