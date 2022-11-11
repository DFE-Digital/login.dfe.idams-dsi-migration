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
		ON source.mail = Target.mail
			AND (
				SELECT perian_serviceName
				FROM dbo.Idams_service
				WHERE perian_serviceId = Source.serviceId
				) = Target.serviceName
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			-- INSERT Data for IDams_Services_Roles table
			INSERT (
				mail
				,serviceName
				,superuser
				,userId
				)
			VALUES (
				Source.mail 
				,(
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId = Source.serviceId
					),
				Source.superuser,
				(SELECT Id FROM dbo.idams_user WHERE mail = Source.mail)
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET serviceName = (
					SELECT perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId = Source.serviceId
					),
					superuser = Source.superuser;

-- Delete duplicates for the first insert
	WITH cte
	AS (
		SELECT mail,serviceName
			,Row_number() OVER (
				PARTITION BY mail,serviceName ORDER BY mail,serviceName
				) row_num
		FROM dbo.idams_user_services
		)
	DELETE
	FROM cte
	WHERE row_num > 1;
END
GO


