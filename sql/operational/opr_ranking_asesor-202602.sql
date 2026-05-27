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
CTE_COLOCACION_ATDATE AS (
--- ======================

SELECT
    IdSAsesor,
	SUM(ColocacionNumReal) AS ColocacionNum,
	SUM(ColocacionMontoReal) AS ColocacionMonto
FROM
    gc_colocacion
GROUP BY
	IdSAsesor

--- ======================
)
--SELECT * FROM CTE_FLOW_TO_ATDATE
,
--- ======================

--- ======================
CTE_REPAGO_ATDATE AS (
--- ======================

SELECT
    IdSAsesor,
	SUM(RepagoReal) AS Repago
FROM
	gc_repago
GROUP BY
	IdSAsesor

--- ======================
)
--SELECT * FROM CTE_FLOW_TO_ATDATE
,
--- ======================


--- ======================
CTE_STOCK_FLOW AS (
--- ======================

------
SELECT
------

    T_CAR.IdSAsesor,

--- Numero de operaciones
	T_COL.ColocacionNum,

--- Crecimiento neto 150
	T_COL.ColocacionMonto - T_REP.Repago - T_CAR.Mora150 AS CrecimientoNeto150,

--- Moras
	T_CAR.Mora9,
	T_CAR.Mora31

------
FROM
------
	gc_cartera_moras T_CAR
    INNER JOIN CTE_COLOCACION_ATDATE T_COL
		ON T_COL.IdSAsesor = T_CAR.IdSAsesor
	INNER JOIN CTE_REPAGO_ATDATE T_REP
		ON T_REP.IdSAsesor = T_CAR.IdSAsesor
--- ======================
)
--SELECT * FROM CTE_STOCK_FLOW
,
--- ======================


--- ======================
CTE_Ranks AS ( -- 3) Rankings densos para cada metrica
--- ======================
------
SELECT
------
	B.*,
	DENSE_RANK() OVER (ORDER BY B.ColocacionNum DESC) AS RankColocacion,
	DENSE_RANK() OVER (ORDER BY B.CrecimientoNeto150 DESC) AS RankCrecimiento
------
FROM
------
	CTE_STOCK_FLOW B

--- ======================
),
--- ======================

--- ======================
CTE_Scores AS ( -- 4) Puntajes por metrica y total
--- ======================

------
SELECT
------
	R.*,
	(100 - R.RankColocacion + 1) AS PuntajeColocacion,
	(100 - R.RankCrecimiento + 1) AS PuntajeCrecimiento,
	(100 - R.RankColocacion + 1) + (100 - R.RankCrecimiento + 1) AS PuntajeTotal
------
FROM
------
	CTE_Ranks R

--- ======================
)
--- ======================

--- ###################
--- MAIN
--- ###################

-- 5) Ranking final (denso) por puntaje total

------
SELECT
------

--- Asesor
    IdSAsesor,

--- Moras
	Mora9,
	Mora31,

--- Colocacion
    ColocacionNum,
    RankColocacion,
    PuntajeColocacion,

--- Crecimiento
    CrecimientoNeto150,
    RankCrecimiento,
    PuntajeCrecimiento,

--- Total
    PuntajeTotal,
    DENSE_RANK() OVER (ORDER BY PuntajeTotal DESC) AS [RankingFinal]
------
FROM
------
	CTE_Scores
------
ORDER BY
------
	[RankingFinal], IdSAsesor;