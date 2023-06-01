CREATE OR ALTER PROCEDURE [dbo].[sp_AddUpdateIDAMSUserServicesRoles] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	DECLARE @IDAMSUserData  IDAMS_USER_TYPE
	INSERT INTO @IDAMSUserData
	SELECT * FROM @idams_user_type

	;WITH cteIDAMS
	AS (
		SELECT uid
			,Row_number() OVER (
				PARTITION BY uid,serviceId,roleName ORDER BY uid,serviceId,roleName
				) row_num
		FROM @IDAMSUserData
		)
	DELETE
	FROM cteIDAMS
	WHERE row_num > 1;
	-- Insert statements for procedure here
	MERGE dbo.idams_user_services_roles AS Target
	USING @IDAMSUserData AS Source
		ON source.uid  = Target.[uid]
			AND (
				SELECT perian_serviceName
				FROM dbo.Idams_service
				WHERE perian_serviceId = dbo.GetPireanServiceId(Source.serviceId,Source.uid)
				) = Target.serviceName
			AND source.roleName = Target.roleName
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			-- INSERT Data for IDams_Services_Roles table
			INSERT (
				mail
				,[uid]
				,serviceName
				,roleName
				)
			VALUES (
				Source.mail 
				,Source.uid
				,(
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId = dbo.GetPireanServiceId(Source.serviceId,Source.uid)
					)
				,Source.roleName
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET serviceName = (
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId = dbo.GetPireanServiceId(Source.serviceId,Source.uid)
					)
				,roleName = Source.roleName
				,mail = Source.mail;


	
END
