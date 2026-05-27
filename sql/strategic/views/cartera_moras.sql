GO
CREATE OR ALTER VIEW gc_cartera_moras WITH ENCRYPTION AS

--- ######################
--- NOTAS
--- ######################

--- ######################
--- PREAMBULO
--- ######################

--- **********************
--- CTEs
WITH
--- **********************

--- ======================
CTE_AUX_CARTERA_MORAS AS (
--- ======================

------------
SELECT
------------

--- Periodo
	T_PRE.PERIODO,

--- Unidad minima operativa
	T_PRE.CUENTA,
	T_PRE.OTORGA,
	T_PRE.PAGARE,

--- Variables de agrupacion
	--- Identificador subrogado del asesor
	T_ANA.ID_USER,

--Variables a ser agrupadas

	--- Saldo capital que conforma la cartera
	T_PRE.SALDO_PRES AS SaldoCapital,

	--- Saldo capital en Mora CPP
	CASE
		WHEN T_PRE.DIAS_REALES >= 9 THEN T_PRE.SALDO_PRES
		ELSE 0
	END AS Mora9_SaldoCapital,

	--Saldo capital en Mora Deficiente
	CASE
		WHEN T_PRE.DIAS_REALES >= 31 THEN T_PRE.SALDO_PRES
		ELSE 0
	END AS Mora31_SaldoCapital,

	--Saldo capital en Mora mayor a 150 dias
	CASE
		WHEN T_PRE.DIAS_REALES >= 151 THEN T_PRE.SALDO_PRES
		ELSE 0
	END AS Mora150_SaldoCapital
------------
FROM
------------
    PREEC T_PRE
    INNER JOIN SEGURIDAD.DBO.ANAREC T_ANA
		ON  T_ANA.ID_ANAREC = T_PRE.ID_ANA
		AND T_ANA.FLAG_ANAREC = 'A'
    INNER JOIN SEGURIDAD.dbo.USUARIOS T_USU
		ON  T_USU.ID_USER = T_ANA.ID_USER
    INNER JOIN SEGURIDAD.dbo.GRUPOUSER T_GRU
		ON  T_GRU.ID_GRUPO = T_USU.ID_GRUPO
		AND T_GRU.NOM_GRUPO =  'CREDITOS'
------------
WHERE
------------
	T_PRE.PERIODO = '202604'
)

--- ######################
--- MAIN
--- ######################

------------
SELECT
------------
	T.PERIODO                   AS Periodo,
	T.ID_USER                   AS IdSAsesor,
	SUM(T.SaldoCapital)         AS Cartera,
	SUM(T.Mora9_SaldoCapital)   AS Mora9,
	SUM(T.Mora31_SaldoCapital)  AS Mora31,
	SUM(T.Mora150_SaldoCapital) AS Mora150
------------
FROM
------------
	CTE_AUX_CARTERA_MORAS T
------------
GROUP BY
------------
	T.PERIODO,
	T.ID_USER
GO
