BEGIN TRY print 1/0; END TRY BEGIN CATCH print 'Line Number: ' + CAST(ERROR_LINE() AS nvarchar(20)); END CATCH;
