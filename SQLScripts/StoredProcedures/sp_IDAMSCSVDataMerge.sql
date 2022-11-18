CREATE PROCEDURE [dbo].[sp_IDAMSCSVDataMerge] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
DECLARE @IDAMSUserData  IDAMS_USER_TYPE
	INSERT INTO @IDAMSUserData
	SELECT * FROM @idams_user_type

	;WITH cteIDAMS
	AS (
		SELECT mail,ukprn
			,Row_number() OVER (
				PARTITION BY mail,ukprn ORDER BY mail,ukprn
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
		ON source.mail = Target.mail
			AND source.ukprn = Target.ukprn
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			INSERT (
				uid
				,NAME
				,upin
				,ukprn
				
				,modifytimestamp
				,mail
				)
			VALUES (
				Source.uid
				,Source.NAME
				,Source.upin
				,Source.ukprn
				
				,Source.modifytimestamp
				,Source.mail 
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET Target.uid = Source.uid
				,Target.NAME = Source.NAME
				,Target.upin = Source.upin
				,Target.ukprn = Source.ukprn
				
				,Target.modifytimestamp = Source.modifytimestamp
				,Target.mail = Source.mail ;

	
	-- Merge idams_user_services data
	EXEC dbo.sp_AddUpdateIDAMSUserServices @IDAMSUserData;
	-- Merge idams_user_services_roles data
	EXEC sp_AddUpdateIDAMSUserServicesRoles @idams_user_type;



END
GO


