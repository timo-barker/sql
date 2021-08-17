use MyDatabase;

drop table if exists #transcript;

create table #transcript
  (
    RowID              int identity(1,1)
   ,InvoiceNumber      varchar(50)
   ,AccountNumber      varchar(50)
   ,GroupCode          char(3)
   ,TransactionDate    date
   ,TransactionSystem  varchar(50)
   ,index ix_transcript_001 unique CLUSTERED  
      (
        InvoiceNumber
       ,AccountNumber
       ,GroupCode
       ,TransactionDate
       ,TransactionSystem
      )
   ,index ix_transcript_002 nonclustered
      (
        TransactionSystem
      )
    INCLUDE
      (
        InvoiceNumber
       ,AccountNumber  
      )
  );

SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     tempdb.sys.indexes ind 
INNER JOIN 
     tempdb.sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     tempdb.sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     tempdb.sys.tables t ON ind.object_id = t.object_id 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.is_included_column, ic.key_ordinal;
