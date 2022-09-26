CREATE FUNCTION dbo.udf_string_split
  (
    @udf_INPUT     nvarchar(4000)
   ,@udf_DELIMETER nchar(1)  
  )
RETURNS @udf_LIST TABLE
  (
    ID nvarchar(15)
  )
AS
BEGIN
    -- Replica of the String_Split() function from SQL Server 2016 (compatability 130).
    -- For use in SQL Server 2014 (compatability 120) or older.
    -- USe: select * from dbo.udf_string_split('The,quick,brown,fox,jumps,over,the,lazy,dog.',',')
    DECLARE @udf_OUTPUT nvarchar(20);
    DECLARE @udf_TRIMSPACE bit = 1;
    WHILE LEN(@udf_INPUT) > 0
        BEGIN
            SET @udf_OUTPUT = LEFT(@udf_INPUT,ISNULL(NULLIF(CHARINDEX(@udf_DELIMETER,@udf_INPUT)-1,-1),LEN(@udf_OUTPUT)));
            SET @udf_INPUT  = SUBSTRING(@udf_INPUT,ISNULL(NULLIF(CHARINDEX(@udf_DELIMETER,@udf_INPUT),0),LEN(@udf_INPUT))+1,LEN(@udf_INPUT));
            IF @udf_TRIMSPACE = 1 SET @udf_OUTPUT = LTRIM(RTRIM(@udf_OUTPUT));
            INSERT INTO @udf_LIST(ID) VALUES (@udf_OUTPUT);
        END;
    RETURN;
END;
GO
