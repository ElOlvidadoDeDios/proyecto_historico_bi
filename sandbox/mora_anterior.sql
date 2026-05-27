GO
--CREATE OR ALTER VIEW gc_cartera_moras WITH ENCRYPTION AS

--=============
--NOTAS
--=============

--=============
--PREAMBULO
--=============

---------------
--CTEs
WITH
---------------

CTE_AUX AS (

------
SELECT
------
--Periodo
  T1.PERIODO,
--Unidad minima operativa
  T1.PAGARE,

--Variables de agrupacion
  --Identificador subrogado del asesor
  NEXO_ANA.ID_USER AS IdSAsesor,

--Variables a ser agrupadas

  --Saldo capital que conforma la cartera
  T1.SALDO_PRES AS SaldoCapital,

  --Saldo capital en Mora CPP
  CASE
    WHEN T1.DIAS_REALES >= 9 THEN T1.SALDO_PRES
    ELSE 0
  END AS Mora9_SaldoCapital,

  --Saldo capital en Mora Deficiente
  CASE
    WHEN T1.DIAS_REALES >= 31 THEN T1.SALDO_PRES
    ELSE 0
  END AS Mora31_SaldoCapital,

  --Saldo capital en Mora mayor a 150 dias
  CASE
    WHEN T1.DIAS_REALES >= 151 THEN T1.SALDO_PRES
    ELSE 0
  END AS Mora150_SaldoCapital

------
FROM
------
    PREEC                                   T1
    INNER JOIN SEGURIDAD.DBO.ANAREC         NEXO_ANA ON NEXO_ANA.ID_ANAREC = T1.ID_ANA         AND NEXO_ANA.FLAG_ANAREC = 'A'
        INNER JOIN SEGURIDAD.dbo.USUARIOS   NEXO_USU ON NEXO_USU.ID_USER   = NEXO_ANA.ID_USER
    INNER JOIN SEGURIDAD.dbo.GRUPOUSER      NEXO_GRU ON NEXO_GRU.ID_GRUPO  = NEXO_USU.ID_GRUPO
------
WHERE
------
  T1.PERIODO        >= FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyyMM') AND
  NEXO_GRU.ID_GRUPO =  '04'

),

CTE_RESUMEN AS (

SELECT
	PERIODO,
	IdSAsesor,
	SUM(SaldoCapital)         AS Cartera,
	SUM(Mora9_SaldoCapital)   AS Mora9,
	SUM(Mora31_SaldoCapital)  AS Mora31,
	SUM(Mora150_SaldoCapital) AS Mora150
FROM
	CTE_AUX
GROUP BY
	PERIODO,
	IdSAsesor
),
--SELECT * FROM CTE_RESUMEN ORDER BY IdSAsesor, PERIODO

--==============
--MAIN
--==============
CTE_MAIN AS (
SELECT
	PERIODO AS Periodo,
	IdSAsesor,
	Cartera,
	Mora9,
	Mora31,
	Mora150,
	ISNULL(LAG(Mora31) OVER (PARTITION BY IdSAsesor ORDER BY PERIODO), 0) AS Mora31_PeriodoAnterior
FROM
	CTE_RESUMEN
--ORDER BY
--  IdSAsesor ASC
)

SELECT
	*
FROM
	CTE_MAIN
WHERE
	PERIODO = FORMAT(GETDATE(), 'yyyyMM')
--ORDER BY
--  IdSAsesor ASC

GO