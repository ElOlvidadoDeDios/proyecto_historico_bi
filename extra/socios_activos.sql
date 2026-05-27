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

CTE AS (
--CTE-INICIO

------
SELECT DISTINCT
------

--Unidad minima operativa
  T1.CUENTA,

--Variables de agrupacion
  --Identificador subrogado del asesor
  NEXO_ANA.ID_USER AS IdSAsesor

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
  T1.PERIODO        >= FORMAT(GETDATE(), 'yyyyMM') AND
  NEXO_GRU.ID_GRUPO IN ('04', '05') AND
  T1.SALDO_PRES > 0

--CTE-FIN
)

--==============
--MAIN
--==============

SELECT
  CTE.IdSAsesor,
  COUNT(*)
FROM
  CTE
  INNER JOIN
	gc_dim_asesor A
		ON A.IdSAsesor = CTE.IdSAsesor
WHERE A.IdSAgencia = '02'
GROUP BY
  CTE.IdSAsesor
--ORDER BY
--  IdSAsesor ASC