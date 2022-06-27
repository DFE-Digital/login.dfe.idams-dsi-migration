/****** Object:  StoredProcedure [dbo].[sp_AddUpdateIDAMSUserServices]    Script Date: 24/06/2022 11:19:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_AddUpdateIDAMSUserServices] (
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
		ON source.mail + '123' = Target.mail
			AND (
				SELECT serviceName
				FROM dbo.Idams_service
				WHERE serviceId = Source.serviceId
				) = Target.serviceName
			-- For Inserts
	WHEN NOT MATCHED BY target
		THEN
			-- INSERT Data for IDams_Services_Roles table
			INSERT (
				mail
				,serviceName
				)
			VALUES (
				Source.mail + '123'
				,(
					SELECT serviceName
					FROM dbo.Idams_service
					WHERE serviceId = Source.serviceId
					)
				)
				-- For Updates
	WHEN MATCHED
		THEN
			UPDATE
			SET serviceName = (
					SELECT serviceName
					FROM dbo.Idams_service
					WHERE serviceId = Source.serviceId
					);

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
