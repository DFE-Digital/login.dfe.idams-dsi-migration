CREATE PROCEDURE [dbo].[sp_IDAMSCSVDataMerge] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
DECLARE @serviceId NVARCHAR(50)
SELECT TOP 1 @serviceId = serviceId FROM @idams_user_type
DECLARE @IDAMSUserData  IDAMS_USER_TYPE
	INSERT INTO @IDAMSUserData
	SELECT * FROM @idams_user_type

	;WITH cteIDAMS
	AS (
		SELECT [uid]
			,Row_number() OVER (
				PARTITION BY [uid] ORDER BY [uid]
				) row_num
		FROM @IDAMSUserData
		)
	DELETE
	FROM cteIDAMS
	WHERE row_num > 1;

	--This top line essentially does a "SELECT *" from the named table
	--and looks for a match based on the "ON" statement below
	MERGE dbo.idams_user AS Target
	USING @IDAMSUserData AS Source
		ON source.uid = Target.[uid]
		
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			INSERT (
				uid
				,NAME
				,givenName
				,sn
				,upin
				,ukprn
				,modifytimestamp
				,mail
				)
			VALUES (
				Source.uid
				,Source.NAME
				,Source.givenName
				,Source.sn
				,Source.upin
				,CASE Source.ukprn WHEN 'Not found' THEN NULL ELSE Source.ukprn END
				,Source.modifytimestamp
				,Source.mail 
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET 
				 Target.NAME = Source.NAME
				,Target.givenName = Source.givenName
				,Target.sn = Source.sn
				,Target.upin = Source.upin
				,Target.ukprn = CASE Source.ukprn WHEN 'Not found' THEN NULL ELSE Source.ukprn END
				,Target.modifytimestamp = Source.modifytimestamp
				,Target.mail = Source.mail ;

	
	-- Merge idams_user_services data
	EXEC dbo.sp_AddUpdateIDAMSUserServices @IDAMSUserData;
	-- Merge idams_user_services_roles data
	-- Check for Users without a Service
	IF(@serviceId IS NOT NULL OR @serviceId <> '')
		EXEC sp_AddUpdateIDAMSUserServicesRoles @idams_user_type;


END
