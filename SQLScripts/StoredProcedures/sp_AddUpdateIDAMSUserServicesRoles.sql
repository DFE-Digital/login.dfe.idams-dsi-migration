CREATE PROCEDURE sp_AddUpdateIDAMSUserServicesRoles (
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
		ON source.mail + '123' = Target.mail
			AND (
				SELECT serviceName
				FROM dbo.Idams_service
				WHERE serviceId = Source.serviceId
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
				Source.mail + '123'
				,(
					SELECT serviceName
					FROM dbo.Idams_service
					WHERE serviceId = Source.serviceId
					)
				,Source.roleName
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET serviceName = (
					SELECT serviceName
					FROM dbo.Idams_service
					WHERE serviceId = Source.serviceId
					)
				,roleName = Source.roleName;
END
GO

