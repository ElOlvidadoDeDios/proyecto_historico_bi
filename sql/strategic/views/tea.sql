GO
CREATE OR ALTER VIEW gc_tea WITH ENCRYPTION AS

--- ############
--- NOTAS
--- ############

/*
- Sobre creditos extornados (improcedentes)
- Sobre creditos castigados
*/

--- ############
--- PREAMBULO
--- ############

--- ************
--- CTEs
WITH
--- ************

--- ============
CTE_AUX_TEA AS (
--- ============

------
SELECT
------
	T_PRE.PERIODO,
	T_PTM.CUENTA,
	T_PTM.OTORGA,
	T_PTM.PAGARE,
	T_PTM.TEA_INTERES,
	T_USU.ID_USER,
	T_PTM.MONTO_PRESTAMO
------
FROM
------
    PRESTAMO T_PTM
	INNER JOIN PREEC T_PRE
		ON  T_PRE.CUENTA = T_PTM.CUENTA
		AND T_PRE.OTORGA = T_PTM.OTORGA
		AND T_PRE.PAGARE = T_PTM.PAGARE
		AND T_PRE.PERIODO = '202605'
	INNER JOIN SEGURIDAD.dbo.ANAREC T_ANA
		ON  T_ANA.ID_ANAREC = T_PRE.ID_ANA
		AND T_ANA.FLAG_ANAREC = 'A'
	INNER JOIN SEGURIDAD.dbo.USUARIOS T_USU
		ON  T_USU.ID_USER = T_ANA.ID_USER
------
WHERE
------

--- Quitar creditos castigados
	T_PTM.TIPO_PROD <> '52'

--- De creditos otorgados el periodo actual
	AND FORMAT(T_PTM.OTORGA, 'yyyyMM') = '202605'

--- ============
)
--- ============


--- ############
--- MAIN
--- ############

SELECT
	T.PERIODO AS Periodo,
	T.ID_USER AS IdSAsesor,
	SUM(Monto_Prestamo * TEA_INTERES) / NULLIF(SUM(Monto_Prestamo), 0) AS TEA
FROM
	CTE_AUX_TEA T
GROUP BY
	T.PERIODO,
	T.ID_USER
--ORDER BY
--	T.Fecha,
--	T.ID_USER
GO
