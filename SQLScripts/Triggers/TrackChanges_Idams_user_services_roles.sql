CREATE OR ALTER TRIGGER [dbo].[TrackChanges_Idams_user_services_roles]
   ON  [dbo].[idams_user_services_roles]
   FOR INSERT,DELETE
AS 
BEGIN
    DECLARE @TableName NVARCHAR(100) = 'dbo.idams_user_services_roles';
    DECLARE @uid NVARCHAR(50),@mail NVARCHAR(200),@roleName nvarchar(500), @status varchar(50);
    
    -- Iterate through the updated columns and store the changes in the historical table
    DECLARE @AddedData TABLE (
        mail NVARCHAR(200),
        status varchar(50),
        roleName nvarchar(500),
		Idamsuid NVARCHAR(50)
    )
	 DECLARE @DeletedData TABLE (
        mail NVARCHAR(200),
        status varchar(50),
        roleName nvarchar(500),
		Idamsuid NVARCHAR(50)
    )
    
   -- Check if the value is added
   IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)

    BEGIN
	  
	INSERT INTO @AddedData (mail,status, roleName,Idamsuid)
    SELECT i.mail, 'ADDED', i.roleName,i.[uid]
    FROM inserted i
   
    -- Iterate through the updated columns and insert the changes into the idams_user_roles_updates table
    WHILE EXISTS (SELECT 1 FROM @AddedData)
    BEGIN
        SELECT TOP 1 @uid = Idamsuid, @mail = mail, @roleName = roleName
        FROM @AddedData;
        DELETE FROM @AddedData WHERE Idamsuid = @uid and roleName = @roleName;
        
        
        INSERT INTO [dbo].[idams_user_role_updates] ([Idamsuid]
           ,[mail]
           ,[roleName]
           ,[status]
           ,[updatedat])
        VALUES (@uid,
		   @mail,
		   @roleName,
		   'ADDED',
		   GETDATE());
    END;

	
    END

    -- Check if the value is deleted
   IF EXISTS (SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
    BEGIN
	INSERT INTO @DeletedData (mail,status, roleName,Idamsuid)
    SELECT d.mail, 'DELETED', d.roleName,d.[uid]
    FROM deleted d

	-- Iterate through the updated columns and insert the changes into the idams_user_roles_updates table
    WHILE EXISTS (SELECT 1 FROM @DeletedData)
    BEGIN
        SELECT TOP 1 @uid = Idamsuid, @mail = mail, @roleName = roleName
        FROM @DeletedData;
        DELETE FROM @DeletedData WHERE Idamsuid = @uid and roleName = @roleName;
        
        
        INSERT INTO [dbo].[idams_user_role_updates] ([Idamsuid]
           ,[mail]
           ,[roleName]
           ,[status]
           ,[updatedat])
        VALUES (@uid,
		   @mail,
		   @roleName,
		   'DELETED',
		   GETDATE());
    END;
    
		END
    END
