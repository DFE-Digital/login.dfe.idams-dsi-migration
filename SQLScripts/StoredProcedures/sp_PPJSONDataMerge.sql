CREATE PROCEDURE [dbo].[sp_PPJSONDataMerge] (
	-- Add the parameters for the stored procedure here
	@pp_org_type PP_ORG_TYPE readonly
	)
AS
BEGIN
	--This top line essentially does a "SELECT *" from the named table
	--and looks for a match based on the "ON" statement below
	MERGE INTO dbo.organisation AS TGT
	USING (
		SELECT masterUkprn
			,giasUrn
			,upin
			,pimsStatus
			,districtAdministrativeName
			,masterDateOpened
			,sourceSystem
			,masterProviderTypeName
			,giasProviderType
			,masterprovidercode
			,pimsProviderType
		FROM @pp_org_type
		GROUP BY masterUkprn
			,giasUrn
			,upin
			,pimsStatus
			,districtAdministrativeName
			,masterDateOpened
			,sourceSystem
			,masterProviderTypeName
			,giasProviderType
			,masterprovidercode
			,pimsProviderType
		) AS SRC
		ON SRC.masterUkprn = TGT.UKPRN
			OR SRC.giasUrn = TGT.URN
			OR SRC.upin = TGT.UID
	WHEN MATCHED
		THEN
			UPDATE
			SET TGT.ProviderProfileID = SRC.masterprovidercode
				,TGT.UPIN = SRC.upin
				,TGT.PIMSProviderType = SRC.pimsProviderType
				,TGT.PIMSStatus = SRC.pimsStatus
				,TGT.DistrictAdministrativeName = SRC.districtAdministrativeName
				,TGT.OpenedOn = SRC.masterDateOpened
				,TGT.SourceSystem = SRC.sourceSystem
				,TGT.ProviderTypeName = SRC.masterProviderTypeName
				,TGT.GiasProviderType = SRC.giasProviderType;
END