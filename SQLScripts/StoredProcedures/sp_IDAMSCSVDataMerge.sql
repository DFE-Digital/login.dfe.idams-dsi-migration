CREATE PROCEDURE [dbo].[sp_IDAMSCSVDataMerge] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
	--This top line essentially does a "SELECT *" from the named table
	--and looks for a match based on the "ON" statement below
	MERGE dbo.idams_user AS Target
	USING @idams_user_type AS Source
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
				,superuser
				,modifytimestamp
				,mail
				)
			VALUES (
				Source.uid
				,Source.NAME
				,Source.upin
				,Source.ukprn
				,Source.superuser
				,Source.modifytimestamp
				,Source.mail + '123'
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET Target.uid = Source.uid
				,Target.NAME = Source.NAME
				,Target.upin = Source.upin
				,Target.ukprn = Source.ukprn
				,Target.superuser = Source.superuser
				,Target.modifytimestamp = Source.modifytimestamp
				,Target.mail = Source.mail + '123';

	
	-- Merge idams_user_services data
	EXEC dbo.sp_AddUpdateIDAMSUserServices @idams_user_type;
	-- Merge idams_user_services_roles data
	EXEC sp_AddUpdateIDAMSUserServicesRoles @idams_user_type;

	-- Delete duplicates for the first insert
	WITH cte
	AS (
		SELECT mail
			,Row_number() OVER (
				PARTITION BY mail ORDER BY mail
				) row_num
		FROM dbo.idams_user
		)
	DELETE
	FROM cte
	WHERE row_num > 1;
END