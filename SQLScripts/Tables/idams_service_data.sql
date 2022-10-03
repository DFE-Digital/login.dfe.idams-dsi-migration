INSERT INTO [dbo].[idams_service]
           ([perian_serviceId]
           ,[perian_serviceName]
           ,[dfe_serviceId]
           ,[dfe_clientId])
     VALUES
           ('CSS'
           ,'ChildSafeGuarding'
           ,(SELECT [id]   FROM [dbo].[service] where name = 'Child safeguarding')
            ,'CSG'
		   )
GO


