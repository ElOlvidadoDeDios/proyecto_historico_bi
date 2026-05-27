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
CTE_FECHAS AS (
--- ======================

SELECT DISTINCT
	T.Fecha,
	1 AS Llave
FROM
	gc_repago T

--- ======================
)
,
--- ======================

--- ======================
CTE_ASESORES AS (
--- ======================

SELECT DISTINCT
	T.IdSAgencia,
	T.IdSAsesor,
	1 AS Llave
FROM
	gc_dim_asesor T

--- ======================
)
,
--- ======================

--- ======================
CTE_PRODUCTO_CARTESIANO AS (
--- ======================

SELECT
    T_FEC.Fecha,
    T_ASE.IdSAsesor,
    T_ASE.IdSAgencia
FROM
	CTE_FECHAS T_FEC
    CROSS JOIN CTE_ASESORES T_ASE

--- ======================
)
--- ======================


--- ######################
--- MAIN
--- ######################


--------
SELECT
--------
    T_PC.Fecha,
    FORMAT(T_PC.Fecha, 'yyyyMM')            As Periodo,
    T_PC.IdSAsesor,
    T_PC.IdSAgencia,
    ISNULL(T_COL.ColocacionNumReal, 0)   AS ColocacionNumReal,
    ISNULL(T_COL.ColocacionMontoReal, 0) As ColocacionMontoReal,
    ISNULL(T_REP.RepagoReal, 0)          As RepagoReal
--------
FROM
--------

--- Fecha x Asesor (y Agencia)
    CTE_PRODUCTO_CARTESIANO T_PC

--- Colocacion: numero y monto
    LEFT OUTER JOIN gc_colocacion T_COL
		ON  T_COL.Fecha = T_PC.Fecha
		AND T_COL.IdSAsesor = T_PC.IdSAsesor

--- Repago
    LEFT OUTER JOIN gc_repago T_REP
		ON  T_REP.Fecha = T_PC.Fecha
		AND T_REP.IdSAsesor = T_PC.IdSAsesor
--------
ORDER BY
--------
    T_PC.Fecha ASC,
    T_PC.IdSAgencia ASC,
    T_PC.IdSAsesor ASC
--------
;
