
CREATE OR ALTER TRIGGER [dbo].[TrackChanges_Idams_user]
ON [dbo].[idams_user]
FOR UPDATE
AS
BEGIN
    DECLARE @TableName NVARCHAR(100) = 'dbo.idams_user';
    DECLARE @uid NVARCHAR(50), @ColumnName NVARCHAR(100), @OldValue NVARCHAR(MAX), @NewValue NVARCHAR(MAX);
    
    -- Iterate through the updated columns and store the changes in the historical table
    DECLARE @UpdatedColumns TABLE (
        ColumnName NVARCHAR(100),
        OldValue NVARCHAR(MAX),
        NewValue NVARCHAR(MAX),
		Idamsuid NVARCHAR(50)
    );
    
    INSERT INTO @UpdatedColumns (ColumnName,NewValue, OldValue,Idamsuid)
    SELECT 'name', i.[name], d.[name],i.[uid]
    FROM inserted i
    JOIN deleted d ON i.uid=d.uid
    WHERE i.name <> d.name
	     
   INSERT INTO @UpdatedColumns (ColumnName,NewValue, OldValue,Idamsuid)
    SELECT 'sn' , i.sn, d.sn,i.[uid]
    FROM inserted i
    JOIN deleted d ON i.uid=d.uid
    WHERE i.sn <> d.sn 

    INSERT INTO @UpdatedColumns (ColumnName,NewValue, OldValue,Idamsuid)
    SELECT 'mail', i.mail, d.mail,i.[uid]
    FROM inserted i
    JOIN deleted d ON i.uid=d.uid
    WHERE  i.mail <> d.mail;

	
    INSERT INTO @UpdatedColumns (ColumnName,NewValue, OldValue,Idamsuid)
    SELECT 'givenName', i.givenName, d.givenName,i.[uid]
    FROM inserted i
    JOIN deleted d ON i.uid=d.uid
    WHERE  i.givenName <> d.givenName;
    
    
  
	
    -- Iterate through the updated columns and insert the changes into the idams_user_data_updates table
    WHILE EXISTS (SELECT 1 FROM @UpdatedColumns)
    BEGIN
        SELECT TOP 1 @ColumnName = ColumnName, @OldValue = OldValue, @NewValue = NewValue, @uid = Idamsuid
        FROM @UpdatedColumns;
      
        DELETE FROM @UpdatedColumns WHERE ColumnName = @ColumnName and Idamsuid = @uid;
        
        INSERT INTO idams_user_data_updates (Idamsuid, fieldchanged, beforevalue, updatedvalue,  updatedat)
        VALUES (@uid, @ColumnName,  @OldValue, @NewValue, GETDATE());
    END;
END;