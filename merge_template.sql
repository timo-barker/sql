DECLARE @Customer TABLE 
  (
    CustomerID   INT IDENTITY(1,1) NOT NULL
   ,CustomerKey  INT
   ,CustomerName VARCHAR(50)
   ,Planet       VARCHAR(50)
   ,Affiliation  VARCHAR(50)
   ,TS           DATETIME DEFAULT CURRENT_TIMESTAMP
  );

DECLARE @CustomerStaging TABLE
  (
    CustomerID   INT IDENTITY(1,1) NOT NULL
   ,CustomerKey  INT
   ,CustomerName VARCHAR(50)
   ,Planet       VARCHAR(50)
   ,Affiliation  VARCHAR(50)
   ,TS           DATETIME DEFAULT CURRENT_TIMESTAMP
  );

INSERT INTO @Customer
  (
    CustomerKey  
   ,CustomerName 
   ,Planet       
   ,Affiliation  
  )
VALUES 
  (1,'Anakin Skywalker','Tatooine' ,NULL         )
 ,(2,'Yoda'            ,'Coruscant','Jedi'       )
 ,(3,'Obi-Wan Kenobi'  ,'Coruscant','Jedi'       )
 ,(4,'Boba Fett'       ,'Kamino'   ,'Mandalorian');

INSERT INTO @CustomerStaging
  (
    CustomerKey  
   ,CustomerName 
   ,Planet       
   ,Affiliation  
  )
VALUES 
  (2,'Master Yoda'     ,'Coruscant','Jedi'       )
 ,(3,'Obi-Wan Kenobi'  ,'Tatooine' ,'Jedi'       )
 ,(4,'Boba Fett'       ,'Kamino'   ,'Mandalorian')
 ,(5,'Darth Vader'     ,'Coruscant','Sith'       );

MERGE INTO @Customer AS tgt 
USING (
       SELECT 
           CustomerKey
          ,CustomerName
          ,Planet
          ,Affiliation
       FROM @CustomerStaging
      ) AS src
ON (tgt.CustomerKey = src.CustomerKey)  
WHEN MATCHED
    AND EXISTS (SELECT tgt.CustomerName, tgt.Planet, tgt.Affiliation
                EXCEPT
                SELECT src.CustomerName, src.Planet, src.Affiliation)
THEN
    UPDATE SET
        tgt.CustomerName = src.CustomerName
       ,tgt.Planet       = src.Planet
       ,tgt.Affiliation  = src.Affiliation
       ,tgt.TS           = DEFAULT
WHEN NOT MATCHED BY TARGET
THEN  
    INSERT (
             CustomerKey
            ,CustomerName
            ,Planet
            ,Affiliation
            ,TS
           )
    VALUES (
             src.CustomerKey
            ,src.CustomerName
            ,src.Planet
            ,src.Affiliation
            ,DEFAULT
           )
WHEN NOT MATCHED BY SOURCE 
THEN 
    DELETE
OUTPUT 
    $action
   ,deleted.*
   ,inserted.*
--INTO #MyTempTable
;
