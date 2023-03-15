/****** Object:  StoredProcedure [dbo].[sp_AddUpdateIDAMSUserServicesRoles]    Script Date: 14/03/2023 21:54:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_AddUpdateIDAMSUserServicesRoles] (
	-- Add the parameters for the stored procedure here
	@idams_user_type IDAMS_USER_TYPE readonly
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
DECLARE @IDAMSUserRolesData  IDAMS_USER_TYPE
	INSERT INTO @IDAMSUserRolesData
	SELECT * FROM @idams_user_type

	;WITH cteIDAMSRoles
	AS (
		SELECT mail,roleName
			,Row_number() OVER (
				PARTITION BY mail,roleName ORDER BY mail,roleName
				) row_num
		FROM @IDAMSUserRolesData
		)
	DELETE
	FROM cteIDAMSRoles
	WHERE row_num > 1;
	-- Insert statements for procedure here
	MERGE dbo.idams_user_services_roles AS Target
	USING @IDAMSUserRolesData AS Source
		ON source.mail  = Target.mail
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
				,serviceName
				,roleName
				)
			VALUES (
				Source.mail 
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
				,roleName = Source.roleName;


	
END
