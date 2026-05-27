GO
CREATE OR ALTER VIEW gc_duracion WITH ENCRYPTION AS

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

--- Periodo
    T_PRE.PERIODO,
--- ID del asesor
    T_USU.ID_USER,
--- Varios
    SUM(T_DED.CAPITAL) AS VARIOS
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
    INNER JOIN PRE_DEDUCESOLI T_DED
        ON  T_PTM.PAGARE = T_DED.NRO_SOL
        AND GLOSA = 'Cursos-Capacitación'
------
WHERE
------
	T_PTM.TIPO_PROD <> '52' -- Producto "Castigado"
    AND FORMAT(T_PTM.OTORGA, 'yyyyMM') = '202605'
--------
GROUP BY
--------
    T_PRE.PERIODO,
    T_USU.ID_USER
--- =================
)
--- =================

--- #################
--- MAIN
--- #################

SELECT
    T.PERIODO AS Periodo,
    T.ID_USER AS IdSAsesor,
    T.VARIOS  AS Varios
FROM
    CTE_AUX_DURACION T
GO
