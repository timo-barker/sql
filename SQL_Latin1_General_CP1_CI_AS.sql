--Differences between SQL_Latin1_General_CI_AS and SQL_Latin1_General_CP1_CI_AS collation

DECLARE @Test TABLE (Col1 VARCHAR(10) NOT NULL);
INSERT INTO @Test VALUES ('aa');
INSERT INTO @Test VALUES ('ac');
INSERT INTO @Test VALUES ('ah');
INSERT INTO @Test VALUES ('AA');
INSERT INTO @Test VALUES ('ác');
INSERT INTO @Test VALUES ('am');
INSERT INTO @Test VALUES ('aka');
INSERT INTO @Test VALUES ('akc');
INSERT INTO @Test VALUES ('ar');
INSERT INTO @Test VALUES ('a-f');
INSERT INTO @Test VALUES ('a_e');
INSERT INTO @Test VALUES ('a''kb');
INSERT INTO @Test VALUES ('æ');
INSERT INTO @Test VALUES ('ae');
INSERT INTO @Test VALUES ('ß');
INSERT INTO @Test VALUES ('ss');

SELECT DISTINCT Col1 COLLATE SQL_Latin1_General_CP1_CI_AS AS Col1 FROM @Test ORDER BY Col1;
-- "String Sort" puts all punctuation ahead of letters.
-- 'æ' <> 'ae' and 'ß' <> 'ss'. Does not allow character expansion.

SELECT DISTINCT Col1 COLLATE Latin1_General_CI_AS AS Col1 FROM @Test ORDER BY Col1;
-- "Word Sort" mostly ignores dash and apostrophe. 
-- 'æ' = 'ae' and 'ß' = 'ss'. Allows for character expansion.

SELECT DISTINCT Col1 COLLATE SQL_Latin1_General_CP1_CS_AS AS Col1 FROM @Test ORDER BY Col1;
-- Case sensitive.

SELECT DISTINCT Col1 COLLATE SQL_Latin1_General_CP1_CI_AI AS Col1 FROM @Test ORDER BY Col1;
-- Accent insensitive

SELECT SERVERPROPERTY('collation');  

EXECUTE sp_helpsort;
