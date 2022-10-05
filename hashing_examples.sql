DECLARE @HashThis NVARCHAR(32);  
SET @HashThis = CONVERT(NVARCHAR(36),newid());  

SELECT 'MD2'     , @HashThis, HASHBYTES('MD2'     , @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('MD2'     , @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('MD2'     , @HashThis), 2))
SELECT 'MD4'     , @HashThis, HASHBYTES('MD4'     , @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('MD4'     , @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('MD4'     , @HashThis), 2))
SELECT 'MD5'     , @HashThis, HASHBYTES('MD5'     , @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('MD5'     , @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('MD5'     , @HashThis), 2))
SELECT 'SHA'     , @HashThis, HASHBYTES('SHA'     , @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('SHA'     , @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('SHA'     , @HashThis), 2))
SELECT 'SHA1'    , @HashThis, HASHBYTES('SHA1'    , @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('SHA1'    , @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('SHA1'    , @HashThis), 2))
SELECT 'SHA2_256', @HashThis, HASHBYTES('SHA2_256', @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('SHA2_256', @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('SHA2_256', @HashThis), 2))
SELECT 'SHA2_512', @HashThis, HASHBYTES('SHA2_512', @HashThis), CONVERT(VARCHAR(8000), HASHBYTES('SHA2_512', @HashThis), 2), LEN(CONVERT(VARCHAR(8000), HASHBYTES('SHA2_512', @HashThis), 2))
   
SELECT 'CHECKSUM', @HashThis, CHECKSUM(@HashThis)             , CONVERT(VARCHAR(8000), CHECKSUM(@HashTHis)             , 2), LEN(CONVERT(VARCHAR(8000), CHECKSUM(@HashTHis)             , 2))
SELECT 'BINARY_CHECKSUM', @HashThis, BINARY_CHECKSUM(@HashThis), CONVERT(VARCHAR(8000), BINARY_CHECKSUM(@HashTHis)     , 2), LEN(CONVERT(VARCHAR(8000), BINARY_CHECKSUM(@HashTHis)      , 2))

-- Create a column in which to store the encrypted data.  
DROP TABLE IF EXISTS #CreditCard;
CREATE TABLE #CreditCard ( 
    CreditCardID int identity
   ,CardNumber nvarchar(25)
   ,CardNumber_EncryptedbyPassphrase VARBINARY(256)
) 
insert into #CreditCard (CardNumber) values ('1234567890123456')
select * from #CreditCard
-- First get the passphrase from the user.  
DECLARE @PassphraseEnteredByUser NVARCHAR(128);  
SET @PassphraseEnteredByUser   
    = 'P@ssw0rd';  
  
-- Update the record for the user's credit card.  
-- In this case, the record is number 3681.  
UPDATE #CreditCard  
SET CardNumber_EncryptedbyPassphrase = EncryptByPassPhrase(@PassphraseEnteredByUser  
    , CardNumber, 1, CONVERT(varbinary, CreditCardID))  
--WHERE CreditCardID = '1';  
select * from #CreditCard

-- Decrypt the encrypted record.  
SELECT CreditCardID, CardNumber, CardNumber_EncryptedbyPassphrase   
    AS 'Encrypted card number', CONVERT(varchar,  
    DecryptByPassphrase(@PassphraseEnteredByUser, CardNumber_EncryptedbyPassphrase, 1   
    , CONVERT(varbinary, CreditCardID)))  
    AS 'Decrypted card number' FROM #CreditCard   
   -- WHERE CreditCardID = '1';  

   SELECT CRYPT_GEN_RANDOM(16) ;  
