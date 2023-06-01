CREATE OR ALTER TRIGGER [dbo].[TrackChanges_Idams_user_services]
ON [dbo].[idams_user_services]
FOR UPDATE
AS
BEGIN
    DECLARE @TableName NVARCHAR(100) = 'dbo.idams_user_services';
    DECLARE @uid NVARCHAR(50), @ColumnName NVARCHAR(100), @OldValue NVARCHAR(MAX), @NewValue NVARCHAR(MAX);
    
    -- Iterate through the updated columns and store the changes in the historical table
    DECLARE @UpdatedColumns TABLE (
        ColumnName NVARCHAR(100),
        OldValue NVARCHAR(MAX),
        NewValue NVARCHAR(MAX),
		Idamsuid NVARCHAR(50)
    );
    
    INSERT INTO @UpdatedColumns (ColumnName,NewValue, OldValue,Idamsuid)
    SELECT 'superuser', i.superuser, d.superuser,i.[uid]
    FROM inserted i
    JOIN deleted d ON i.uid=d.uid
    WHERE i.superuser <> d.superuser
		
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