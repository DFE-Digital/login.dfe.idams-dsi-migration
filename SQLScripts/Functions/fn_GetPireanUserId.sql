CREATE FUNCTION [dbo].[GetPireanUserId]
(
    -- Add the parameters for the function here
    @mail NVARCHAR(200),
	@serviceId VARCHAR(10),
	@uid NVARCHAR(50)
	
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @existing_userId INT
	DECLARE @new_userId INT
	DECLARE @listOfIDs TABLE (Id INT); 
	DECLARE @serviceName VARCHAR(200)

    -- Add the T-SQL statements to compute the return value here
		
		SELECT @serviceName =  perian_serviceName
					FROM dbo.Idams_service
					WHERE perian_serviceId =  dbo.GetPireanServiceId(@serviceId,@uid)

		INSERT INTO @listOfIDs
		SELECT Id FROM dbo.idams_user WHERE mail = @mail

		SELECT @existing_userId = userId FROM dbo.idams_user_services WHERE serviceName <> @serviceName   
		SELECT @new_userId = Id FROM @listOfIDs WHERE Id <> @existing_userId
		

    -- Return the result of the function
    RETURN @new_userId 
END
GO


