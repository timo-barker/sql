--=====================================================================================================================
--      Create the tax bracket table.
--      Note that this should be a permanent table. We''re creating it as a Temp Table just for demo purposes.
--      Be cautious because we drop this table to make reruns in SSMS easier.
--=====================================================================================================================
--===== If the table exists, drop the table to make reruns in SSMS easier.
   DROP TABLE IF EXISTS #TaxBracket
;
GO
--===== Create the table
 CREATE TABLE #TaxBracket
        (
         FilingStatus               VARCHAR(5)
        ,TaxYear                    INT           NOT NULL
        ,Local                      VARCHAR(20)
        ,IncomeCutoffLo             DECIMAL(19,4) NOT NULL -- 15 digits to the left of the decimal point should handle anything.
        ,IncomeCutoffHi             DECIMAL(19,4) NOT NULL -- 15 digits to the left of the decimal point should handle anything.
        ,BracketTaxRate             DECIMAL( 5,4) NOT NULL
        --,IncomeBracketRange         DECIMAL(19,4) NOT NULL -- For sanity checks only. Can remove for Prod or leave.
        --,MaxBracketRangeTax         DECIMAL(19,4) NOT NULL -- For sanity checks only. Can remove for Prod or leave.
        --,CumeMaxBracketRangeTax     DECIMAL(19,4) NOT NULL -- For sanity checks only. Can remove for Prod or leave.
        ,PrevCumeMaxBracketRangeTax DECIMAL(19,4) NOT NULL
        ,CONSTRAINT PK_TaxBracket   PRIMARY KEY CLUSTERED (IncomeCutoffLo,TaxYear,FilingStatus,Local)
        ,CONSTRAINT AK_TaxBracket   UNIQUE (IncomeCutoffHi,TaxYear,FilingStatus,Local)
        )
;
--===== Populate the table with new info for the Tax Year of 2019
   WITH ctePreAgg1 AS
(
 SELECT  v.*
        ,IncomeCutoffLo     = LAG(v.IncomeCutoffHi,1,0)                   OVER (partition by v.FilingStatus, v.TaxYear, v.Local ORDER BY v.IncomeCutoffHi)
        ,IncomeBracketRange = (v.IncomeCutoffHi-LAG(v.IncomeCutoffHi,1,0) OVER (partition by v.FilingStatus, v.TaxYear, v.Local ORDER BY v.IncomeCutoffHi))
        ,MaxBracketRangeTax = (v.IncomeCutoffHi-LAG(v.IncomeCutoffHi,1,0) OVER (partition by v.FilingStatus, v.TaxYear, v.Local ORDER BY v.IncomeCutoffHi)) 
                            * v.BracketTaxRate
   FROM (VALUES
         ('S'  ,2019,'NYS',8500   ,0.0400)
        ,('S'  ,2019,'NYS',11700  ,0.0450)
        ,('S'  ,2019,'NYS',13900  ,0.0525)
        ,('S'  ,2019,'NYS',21400  ,0.0590)
        ,('S'  ,2019,'NYS',80650  ,0.0621)
        ,('S'  ,2019,'NYS',215400 ,0.0649)
        ,('S'  ,2019,'NYS',1077550,0.0685)
        ,('S'  ,2019,'NYS',9999999,0.0882)
        ,('MFJ',2019,'NYS',17150  ,0.0400)
        ,('MFJ',2019,'NYS',23600  ,0.0450)
        ,('MFJ',2019,'NYS',27900  ,0.0525)
        ,('MFJ',2019,'NYS',43000  ,0.0590)
        ,('MFJ',2019,'NYS',161550 ,0.0609)
        ,('MFJ',2019,'NYS',323200 ,0.0641)
        ,('MFJ',2019,'NYS',2155350,0.0685)
        ,('MFJ',2019,'NYS',9999999,0.0882)
        ,('S'  ,2019,'NYC',12000  ,0.03078)
        ,('S'  ,2019,'NYC',25000  ,0.03762)
        ,('S'  ,2019,'NYC',50000  ,0.03819)
        ,('S'  ,2019,'NYC',9999999,0.03876)
        ,('MFJ',2019,'NYC',21600  ,0.03078)
        ,('MFJ',2019,'NYC',45000  ,0.03762)
        ,('MFJ',2019,'NYC',90000  ,0.03819)
        ,('MFJ',2019,'NYC',9999999,0.03876)
        ,('S'  ,2019,'CT' ,10000  ,0.0300)
        ,('S'  ,2019,'CT' ,50000  ,0.0500)
        ,('S'  ,2019,'CT' ,100000 ,0.0550)
        ,('S'  ,2019,'CT' ,200000 ,0.0600)
        ,('S'  ,2019,'CT' ,250000 ,0.0650)
        ,('S'  ,2019,'CT' ,500000 ,0.0690)
        ,('S'  ,2019,'CT' ,9999999,0.0699)
        ,('MFJ',2019,'CT' ,20000  ,0.0300)
        ,('MFJ',2019,'CT' ,100000 ,0.0500)
        ,('MFJ',2019,'CT' ,200000 ,0.0550)
        ,('MFJ',2019,'CT' ,400000 ,0.0600)
        ,('MFJ',2019,'CT' ,500000 ,0.0650)
        ,('MFJ',2019,'CT' ,1000000,0.0690)
        ,('MFJ',2019,'CT' ,9999999,0.0699)
        ,('S'  ,2019,'NJ' ,20000  ,0.0140)
        ,('S'  ,2019,'NJ' ,35000  ,0.0175)
        ,('S'  ,2019,'NJ' ,40000  ,0.0350)
        ,('S'  ,2019,'NJ' ,75000  ,0.0553)
        ,('S'  ,2019,'NJ' ,500000 ,0.0637)
        ,('S'  ,2019,'NJ' ,5000000,0.0897)
        ,('S'  ,2019,'NJ' ,9999999,0.1075)
        ,('MFJ',2019,'NJ' ,20000  ,0.0140)
        ,('MFJ',2019,'NJ' ,50000  ,0.0175)
        ,('MFJ',2019,'NJ' ,70000  ,0.0245)
        ,('MFJ',2019,'NJ' ,80000  ,0.0350)
        ,('MFJ',2019,'NJ' ,150000 ,0.0553)
        ,('MFJ',2019,'NJ' ,500000 ,0.0637)
        ,('MFJ',2019,'NJ' ,5000000,0.0897)
        ,('MFJ',2019,'NJ' ,9999999,0.1075)
        ,('S'  ,2019,'US' ,9950   ,0.1000)
        ,('S'  ,2019,'US' ,40525  ,0.1200)
        ,('S'  ,2019,'US' ,86375  ,0.2200)
        ,('S'  ,2019,'US' ,164925 ,0.2400)
        ,('S'  ,2019,'US' ,209425 ,0.3200)
        ,('S'  ,2019,'US' ,523600 ,0.3500)
        ,('S'  ,2019,'US' ,9999999,0.3700)
        ,('MFJ',2019,'US' ,19900  ,0.1000)
        ,('MFJ',2019,'US' ,81050  ,0.1200) 
        ,('MFJ',2019,'US' ,172750 ,0.2200)
        ,('MFJ',2019,'US' ,329850 ,0.2400)
        ,('MFJ',2019,'US' ,418850 ,0.3200)
        ,('MFJ',2019,'US' ,628300 ,0.3500)
        ,('MFJ',2019,'US' ,9999999,0.3700)
        --$ 163,197.00
        --999999999999999.9999 should always be the final IncomeCutoff for this table
        ) v (FilingStatus,TaxYear,Local,IncomeCutoffHi,BracketTaxRate)
)
,
        ctePreAgg2 AS
(
 SELECT  pa1.*
        ,CumeMaxBracketRangeTax = SUM(pa1.MaxBracketRangeTax)     OVER (partition by pa1.FilingStatus, pa1.TaxYear, pa1.Local ORDER BY pa1.IncomeCutoffHi)
   FROM ctePreAgg1 pa1
)
 INSERT INTO #TaxBracket WITH (TABLOCK)
        (
         FilingStatus
        ,TaxYear 
        ,Local              
        ,IncomeCutoffLo          
        ,IncomeCutoffHi          
        ,BracketTaxRate        
        --,IncomeBracketRange         -- For sanity checks only. Can remove for Prod or leave.
        --,MaxBracketRangeTax         -- For sanity checks only. Can remove for Prod or leave.
        --,CumeMaxBracketRangeTax     -- For sanity checks only. Can remove for Prod or leave.
        ,PrevCumeMaxBracketRangeTax
        )
 SELECT  FilingStatus 
        ,TaxYear   
        ,Local            
        ,IncomeCutoffLo
        ,IncomeCutoffHi          
        ,BracketTaxRate        
        --,IncomeBracketRange         -- For sanity checks only. Can remove for Prod or leave.
        --,MaxBracketRangeTax         -- For sanity checks only. Can remove for Prod or leave.
        --,CumeMaxBracketRangeTax     -- For sanity checks only. Can remove for Prod or leave.
        ,PrevCumeMaxBracketRangeTax = LAG(pa2.CumeMaxBracketRangeTax,1,0.00) OVER (partition by pa2.FilingStatus, pa2.TaxYear, pa2.Local ORDER BY pa2.IncomeCutoffHi)
   FROM ctePreAgg2 pa2
;
--===== Let''s see what we''ve created
-- SELECT * FROM #TaxBracket
--;

DROP TABLE IF EXISTS #TestData
;
 SELECT TOP (100)
         ID         = IDENTITY(INT,1,1)
        ,TaxYear    = 2019
        ,Income     = CONVERT(DECIMAL(19,4),RAND(CHECKSUM(NEWID()))*1000000)
   INTO #TestData
   FROM      sys.all_columns ac1 
  CROSS JOIN sys.all_columns ac2
;

DROP TABLE IF EXISTS #Results
;
 SELECT tb.FilingStatus, tb.TaxYear, tb.[Local]
       ,BracketTaxRate = format(tb.BracketTaxRate,'#,##0.000%')
       ,td.ID
       ,Income = format(td.Income,'#,##0.00')
       ,TaxDue = format((td.Income-tb.IncomeCutoffLo) * tb.BracketTaxRate + tb.PrevCumeMaxBracketRangeTax,'#,##0.00')
        --,*                                          -- For sanity checks only. Can remove for Prod or leave.
        --,(@Income-IncomeCutoffLo)                   -- For sanity checks only. Can remove for Prod or leave.
        --,(@Income-IncomeCutoffLo) * BracketTaxRate  -- For sanity checks only. Can remove for Prod or leave.
        --,PrevCumeMaxBracketRangeTax                 -- For sanity checks only. Can remove for Prod or leave.
   --INTO #Results
   
   FROM #TaxBracket tb
   JOIN #TestData td 
     ON tb.TaxYear = td.TaxYear
    AND td.Income >  tb.IncomeCutoffLo
    AND td.Income <= tb.IncomeCutoffHI
 where tb.FilingStatus = 'mfj'
 --and tb.local not in ('nyc')
 order by td.Income, 7
;
--SELECT Income = format(Income,'#,##0.00')
--      ,TaxDue = format(TaxDue,'#,##0.00')
--      ,*
--FROM #Results
--;