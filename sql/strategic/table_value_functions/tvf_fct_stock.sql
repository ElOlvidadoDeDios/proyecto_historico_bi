USE [TRANSACMIF]
GO
CREATE OR ALTER FUNCTION [gc].[tvf_fct_stock]
(
    @Periodo CHAR(6)
)
RETURNS TABLE
AS
RETURN
(
--- ####################################################
--- ####################################################
--- ####################################################

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
CTE_ASESOR AS (
--- ======================

SELECT * FROM gc.tvf_dim_asesor(@Periodo)

--- ======================
)
,
--- ======================

--- ======================
CTE_CARTERA_MORAS AS (
--- ======================

SELECT * FROM gc.tvf_cartera_moras(@Periodo)

--- ======================
)
,
--- ======================

--- ======================
CTE_DURACION AS (
--- ======================

SELECT * FROM gc.tvf_duracion(@Periodo)

--- ======================
)
,
--- ======================

--- ======================
CTE_TEA AS (
--- ======================

SELECT * FROM gc.tvf_tea(@Periodo)

--- ======================
),
--- ======================

--- ======================
CTE_SOCIOS AS (
--- ======================

SELECT * FROM gc.tvf_socios(@Periodo)

--- ======================
)
--- ======================


--- ######################
--- MAIN
--- ######################

------
SELECT
------
    T_CAR.Periodo,
	T_ASE.IdSAgencia,
    T_CAR.IdSAsesor,
    T_CAR.Cartera,
    T_CAR.Mora9,
    T_CAR.Mora31,
    T_CAR.Mora150,
    ISNULL(T_DUR.Varios, 0) AS Varios,
    ISNULL(T_TEA.TEA, 0) AS TEA,
    T_SOC.NroSocios
------
FROM
------
	CTE_ASESOR T_ASE
	INNER JOIN CTE_CARTERA_MORAS T_CAR
		ON  T_CAR.IdSAsesor = T_ASE.IdSAsesor
    LEFT JOIN CTE_DURACION T_DUR
        ON  T_DUR.Periodo = T_CAR.Periodo
        AND T_DUR.IdSAsesor = T_CAR.IdSAsesor
    LEFT JOIN CTE_TEA T_TEA
        ON  T_TEA.Periodo = T_CAR.Periodo
        AND T_TEA.IdSAsesor = T_CAR.IdSAsesor
    LEFT JOIN CTE_SOCIOS T_SOC
        ON  T_SOC.Periodo = T_CAR.Periodo
        AND T_SOC.IdSAsesor = T_CAR.IdSAsesor
--- ####################################################
--- ####################################################
--- ####################################################
);
