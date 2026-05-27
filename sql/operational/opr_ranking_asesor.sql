WITH

CTE_fechas AS (
SELECT DISTINCT A.Fecha, 1 AS Llave FROM gc_repago A
),

CTE_asesores AS (
SELECT DISTINCT A.IdSAgencia, A.IdSAsesor, 1 AS Llave FROM gc_dim_asesor A WHERE A.Cargo = 'ANALISTA DE CREDITOS I'
),

CTE_producto_cartersiano AS (
SELECT
    CTE_fechas.Fecha,
    CTE_asesores.IdSAsesor,
    CTE_asesores.IdSAgencia
FROM CTE_fechas
    CROSS JOIN CTE_asesores
),

CTE_fct_flow AS (
SELECT
    CTE_PC.Fecha,
    FORMAT(CTE_PC.Fecha, 'yyyyMM')          As Periodo,
    CTE_PC.IdSAsesor,
    CTE_PC.IdSAgencia,
    ISNULL(NEXO_COL.ColocacionNumReal, 0)   AS ColocacionNumReal,
    ISNULL(NEXO_COL.ColocacionMontoReal, 0) As ColocacionMontoReal,
    ISNULL(NEXO_REP.RepagoReal, 0)          As RepagoReal
FROM
    CTE_producto_cartersiano      CTE_PC
    LEFT OUTER JOIN gc_colocacion NEXO_COL ON NEXO_COL.Fecha = CTE_PC.Fecha AND NEXO_COL.IdSAsesor = CTE_PC.IdSAsesor
    LEFT OUTER JOIN gc_repago     NEXO_REP ON NEXO_REP.Fecha = CTE_PC.Fecha AND NEXO_REP.IdSAsesor = CTE_PC.IdSAsesor
--ORDER BY
--    CTE_PC.Fecha ASC,
--    CTE_PC.IdSAgencia ASC,
--    CTE_PC.IdSAsesor ASC
),

CTE_Base AS (
SELECT
	T.IdSAsesor,
	SUM(T.ColocacionNumReal) AS ColocacionAtDate,

	-- 👇 Ajuste solo para VCVM restando 100000
	(CASE 
		WHEN T.IdSAsesor = 'VCVM' 
		THEN (SUM(T.ColocacionMontoReal) - SUM(T.RepagoReal)) - 100000
		ELSE (SUM(T.ColocacionMontoReal) - SUM(T.RepagoReal))
	 END) AS CrecimientoAtDate

FROM
	CTE_fct_flow T
GROUP BY
	T.IdSAsesor
),

-- 2) Cantidad de asesores en el set (N)
CTE_Nro_Asesores AS (
	SELECT COUNT(*) AS N
	FROM CTE_Base
),

-- 3) Rankings densos para cada metrica
CTE_Ranks AS (
	SELECT
		B.*,
		DENSE_RANK() OVER (ORDER BY B.ColocacionAtDate DESC) AS RankColocacion,
		DENSE_RANK() OVER (ORDER BY B.CrecimientoAtDate DESC) AS RankCrecimiento
	FROM
		CTE_Base B
),

-- 4) Puntajes por metrica y total
CTE_Scores AS (
	SELECT
		R.*,
		(N.N - R.RankColocacion + 1) AS Puntaje_Colocacion,
		(N.N - R.RankCrecimiento + 1) AS Puntaje_Crecimiento,
		(N.N - R.RankColocacion + 1) + (N.N - R.RankCrecimiento + 1) AS Puntaje_Total
	FROM CTE_Ranks R
	CROSS JOIN CTE_Nro_Asesores N
)

-- 5) Ranking final (denso) por puntaje total
SELECT
	--Asesor
    IdSAsesor                                         AS IdSAsesor,
	--Colocacion
    ColocacionAtDate                              AS Colocacion,
    RankColocacion                                 AS [Ranking Colocacion],
    Puntaje_Colocacion                              AS [Puntaje Colocacion],
	--Crecimiento
    CrecimientoAtDate                                AS Crecimiento,
    RankCrecimiento                                  AS [Ranking Crecimiento],
    Puntaje_Crecimiento                               AS [Puntaje Crecimiento],
	--Total
    Puntaje_Total                                     AS [Puntaje Total],
    DENSE_RANK() OVER (ORDER BY Puntaje_Total DESC)   AS [Ranking Final]
FROM CTE_Scores
ORDER BY [Ranking Final], IdSAsesor;