CREATE FUNCTION [dbo].[GetPireanServiceId]
(
    -- Add the parameters for the function here
    @serviceId VARCHAR(50),
	@uid       VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @perian_serviceId VARCHAR(50)

    -- Add the T-SQL statements to compute the return value here
    SET @perian_serviceId = CASE @serviceId WHEN 'SLD' THEN CASE SUBSTRING(@uid, 1,3) WHEN 'lsc' THEN 'SLDS' ELSE 'SLDEx' END 
									  ELSE  @serviceId END 

    -- Return the result of the function
    RETURN @perian_serviceId 
END
