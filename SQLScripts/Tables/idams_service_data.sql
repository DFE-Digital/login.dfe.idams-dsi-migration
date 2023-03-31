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


ALTER TABLE idams_service 
ADD service_url VARCHAR (255) 

UPDATE idams_service SET service_url = 'https://web.tst.eld.titan.fasst.org.uk/enter-learning-data/' WHERE perian_serviceName='Submit Learner Data';
UPDATE idams_service SET service_url = 'https://web.tst.eld.titan.fasst.org.uk/enter-learning-data/' WHERE perian_serviceName='Submit Learner Data Operations';
UPDATE idams_service SET service_url = 'https://childsafeguarding.education.gov.uk' WHERE perian_serviceName='ChildSafeGuarding';

GO


