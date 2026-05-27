GO
CREATE OR ALTER VIEW gc_repago WITH ENCRYPTION AS

--- #################
--- NOTAS
--- #################

--- #################
--- PREAMBULO
--- #################

--- *****************
--- CTEs
WITH
--- *****************

--- =================
CTE_AUX_DURACION AS (
--- =================

------
SELECT
------
	T_MOV.FECHA_MOV,
	T_MOV.CUENTA,
	T_MOV.PAGARE,
	T_MOV.OTORGA,
	T_USU.ID_USER,
	T_MOV.CAPITAL
------
FROM
------
	PREMOV T_MOV
	INNER JOIN PREEC T_PRE
		ON  T_PRE.CUENTA = T_MOV.CUENTA
		AND T_PRE.OTORGA = T_MOV.OTORGA
		AND T_PRE.PAGARE = T_MOV.PAGARE
		AND T_PRE.PERIODO = '202605'
	INNER JOIN SEGURIDAD.dbo.ANAREC T_ANA
		ON  T_ANA.ID_ANAREC = T_PRE.ID_ANA
		AND T_ANA.FLAG_ANAREC  = 'A'
	INNER JOIN SEGURIDAD.dbo.USUARIOS T_USU
		ON  T_USU.ID_USER = T_ANA.ID_USER
------
WHERE
------

--- Repagos del periodo actual
	FORMAT(T_MOV.FECHA_MOV, 'yyyyMM') = '202605'

--- Movimiento que no sea por apertura
	AND T_MOV.TIPO_MOV != '0001'

--- Tipo de documento: VOUCHER ING. (01), NOTA DE ABONO (03)
	AND T_MOV.TIPO_DOC IN ('01','03')

--- ¿?
	AND NOT EXISTS (
		SELECT 1
		FROM PREMOV A
		WHERE
			A.FECHA_MOV = T_MOV.FECHA_MOV AND
			A.COD_AGE   = T_MOV.COD_AGE   AND
			A.COD_CAJA  = T_MOV.COD_CAJA  AND
			A.TIPO_DOC  = T_MOV.TIPO_DOC  AND
			A.NRO_DOC   = T_MOV.NRO_DOC   AND
			LEFT(A.TIPO_MOV, 2) = '01'
	)

--- =================
)
--- =================


--- #################
--- MAIN
--- #################

SELECT
	CAST(T.FECHA_MOV AS DATE) AS Fecha,
	T.ID_USER                 AS IdSAsesor,
	SUM(T.CAPITAL)            AS RepagoReal
FROM CTE_AUX_DURACION T
GROUP BY
	T.FECHA_MOV,
	T.ID_USER
--ORDER BY
--	Fecha    ASC,
--	IdSAsesor ASC
GO
