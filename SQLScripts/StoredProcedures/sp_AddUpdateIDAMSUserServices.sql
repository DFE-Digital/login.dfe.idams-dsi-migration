CREATE PROCEDURE [dbo].[sp_AddUpdateIDAMSUserServices] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	-- Insert statements for procedure here
	-- Merge idams_user_services data
	MERGE dbo.idams_user_services AS Target
	USING @idams_user_type AS Source
		ON source.uid = Target.[uid]
			AND ((
				SELECT perian_serviceName
				FROM dbo.Idams_service
				WHERE perian_serviceId =  dbo.GetPireanServiceId(Source.serviceId,Source.uid)
				) = Target.serviceName OR Source.serviceId IS NULL)
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			-- INSERT Data for idams_Services table
			INSERT (
				mail
				,serviceName
				,superuser
				,userId
				,[uid]
				)
			VALUES (
				Source.mail 
				,(
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId =  dbo.GetPireanServiceId(Source.serviceId,Source.uid) 
					),
				Source.superuser,
				(SELECT Id FROM dbo.idams_user WHERE uid = Source.uid ),
				Source.uid 
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET serviceName = (
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId =  dbo.GetPireanServiceId(Source.serviceId,Source.uid) 
					),
					mail = Source.mail,
					superuser = Source.superuser;



END
