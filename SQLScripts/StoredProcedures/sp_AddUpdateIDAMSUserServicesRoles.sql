CREATE PROCEDURE [dbo].[sp_AddUpdateIDAMSUserServicesRoles] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	-- Insert statements for procedure here
	MERGE dbo.idams_user_services_roles AS Target
	USING @idams_user_type AS Source
		ON source.mail  = Target.mail
			AND (
				SELECT perian_serviceName
				FROM dbo.Idams_service
				WHERE perian_serviceId = Source.serviceId
				) = Target.serviceName
			AND source.roleName = Target.roleName
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			-- INSERT Data for IDams_Services_Roles table
			INSERT (
				mail
				,serviceName
				,roleName
				)
			VALUES (
				Source.mail 
				,(
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId = Source.serviceId
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
					WHERE perian_serviceId = Source.serviceId
					)
				,roleName = Source.roleName;
END
GO


