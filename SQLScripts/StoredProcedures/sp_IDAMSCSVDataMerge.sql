CREATE PROCEDURE [dbo].[sp_IDAMSCSVDataMerge] (
  -- Add the parameters for the stored procedure here
  @idams_user_type IDAMS_USER_TYPE readonly)
AS

  BEGIN
      --This top line essentially does a "SELECT *" from the named table
      --and looks for a match based on the "ON" statement below
      MERGE dbo.idams_user AS Target
      using @idams_user_type AS Source
      ON source.mail = Target.mail AND source.ukprn = Target.ukprn
      -- For Inserts
      WHEN NOT matched BY target THEN
        INSERT ( uid,
                 NAME,
                 upin,
                 ukprn,
                 superuser,
                 modifytimestamp,
                 mail )
        VALUES ( Source.uid,
                 Source.NAME,
                 Source.upin,
                 Source.ukprn,
                 Source.superuser,
                 Source.modifytimestamp,
                 Source.mail + '123' )
      -- For Updates
      WHEN matched THEN
        UPDATE SET Target.uid = Source.uid,
                   Target.NAME = Source.NAME,
                   Target.upin = Source.upin,
                   Target.ukprn = Source.ukprn,
                   Target.superuser = Source.superuser,
                   Target.modifytimestamp = Source.modifytimestamp,
                   Target.mail = Source.mail;

-- Merge idams_user_services data
   MERGE dbo.idams_user_services_roles AS Target
      using @idams_user_type AS Source
      ON source.mail = Target.mail AND 
	     source.serviceId = Target.serviceName AND 
		 source.roleName  = Target.roleName
      -- For Inserts
      WHEN NOT matched BY target THEN
	  -- INSERT Data for IDams_Services_Roles table
        INSERT ( mail,
				 serviceName,
				 roleName)
        VALUES ( Source.mail + '123',
		         Source.serviceId,
				 Source.roleName
		         )
      -- For Updates
      WHEN matched THEN
        UPDATE SET serviceName = Source.serviceId,
		           roleName	   = Source.roleName;

      -- Delete duplicates for the first insert
      WITH cte
           AS (SELECT mail,
                      Row_number()
                        OVER (
                          partition BY mail
                          ORDER BY mail ) row_num
               FROM   dbo.idams_user)
      DELETE FROM cte
      WHERE  row_num > 1;
  END 