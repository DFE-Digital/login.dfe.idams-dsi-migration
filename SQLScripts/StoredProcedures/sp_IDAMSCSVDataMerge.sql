CREATE PROCEDURE [dbo].[sp_IDAMSCSVDataMerge] (
	-- Add the parameters for the stored procedure here
	@idams_user_type idams_user_type READONLY
	)
AS
BEGIN
	--This top line essentially does a "SELECT *" from the named table
	--and looks for a match based on the "ON" statement below
	MERGE dbo.idams_user AS Target
	USING @idams_user_type AS Source
		ON Source.mail = Target.mail
			-- For Inserts
	WHEN NOT MATCHED BY Target
		THEN
			INSERT (
				uid
				,name
				,upin
				,ukprn
				,superuser
				,modifytimestamp
				,mail
				)
			VALUES (
				Source.uid
				,Source.name
				
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
				,Target.name = Source.name
				,Target.upin = Source.upin
				,Target.ukprn = Source.ukprn
				,Target.superuser = Source.superuser
				,Target.modifytimestamp = Source.modifytimestamp
				,Target.mail = Source.mail;
END