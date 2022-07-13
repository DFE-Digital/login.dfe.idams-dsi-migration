CREATE PROCEDURE [dbo].[sp_PPJSONDataMerge] (
	-- Add the parameters for the stored procedure here
	@pp_org_type PP_ORG_TYPE readonly
	)
AS
BEGIN
	--This top line essentially does a "SELECT *" from the named table
	--and looks for a match based on the "ON" statement below
	MERGE dbo.organisation AS Target
	USING @pp_org_type AS Source
		ON source.masterUkprn = Target.UKPRN
		OR source.giasUrn = Target.URN
		OR source.upin = Target.UID
			-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET Target.ProviderProfileID = Source.masterprovidercode
				,Target.UPIN = Source.upin
				,Target.PIMSProviderType = Source.pimsProviderType
				,Target.PIMSStatus = Source.pimsStatus
				,Target.DistrictAdministrativeName = Source.districtAdministrativeName
				,Target.OpenedOn = Source.masterDateOpened
				,Target.SourceSystem = Source.sourceSystem 
				,Target.ProviderTypeName = Source.masterProviderTypeName 
				,Target.GiasProviderType = Source.giasProviderType ;				
				
	
END
