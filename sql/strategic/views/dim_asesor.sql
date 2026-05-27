GO
CREATE OR ALTER VIEW gc_dim_asesor WITH ENCRYPTION AS

--- ###############
--- NOTAS
--- ###############

/*
Recuperados de tramo de mora superior al de un recuperador de agencia
se crean dentro de la agencia molino. Asi que hay que excluir a estos.
*/

--- ###############
--- PREAMBLE
--- ###############

--- ***************
--- CTEs
WITH
--- ***************

--- ===============
CTE_AUX_ASESOR AS (
--- ===============

------
SELECT
------

--- Periodo
	T_PRE.PERIODO AS Periodo,

--- ID Agencia

	CASE

	--- Distinguir agencia digital en agencia juliaca y agencia lima
		WHEN T_ANA.ID_AGE = '98' THEN
			CASE
				WHEN RIGHT(RTRIM(T_ANA.ID_USER), 1) = '6' THEN '06'
				WHEN RIGHT(RTRIM(T_ANA.ID_USER), 1) = '7' THEN '07'
			END

	--- Distinguir agencia wanchaq en agencia wanchaq y agencia magisterio
		WHEN T_ANA.ID_AGE = '01' THEN
			CASE
				WHEN RIGHT(RTRIM(T_ANA.ID_USER), 1) <> '9' THEN '01'
				WHEN RIGHT(RTRIM(T_ANA.ID_USER), 1) = '9' THEN '09'
			END

	--- Mantener mismo IdSAgencia para el resto de agencias
		ELSE T_ANA.ID_AGE

	END AS IdSAgencia,

--- ID asesor
	T_ANA.ID_USER AS IdSAsesor,

--- Nombre completo del asesor
	T_PER.RAZON AS AsesorNombresApellidos,

--- Cargo
	T_CAR.DESCRIP AS Cargo

------
FROM
------
	PREEC T_PRE
	INNER JOIN SEGURIDAD.DBO.ANAREC T_ANA
		ON	T_ANA.ID_ANAREC = T_PRE.ID_ANA AND
			T_ANA.FLAG_ANAREC = 'A'
	INNER JOIN SEGURIDAD.dbo.USUARIOS T_USU
		ON	T_USU.ID_USER = T_ANA.ID_USER
	INNER JOIN SEGURIDAD.dbo.GRUPOUSER T_GRU
		ON  T_GRU.ID_GRUPO = T_USU.ID_GRUPO
		AND T_GRU.NOM_GRUPO = 'CREDITOS'
    INNER JOIN SEGURIDAD.dbo.PERSONAL T_PER
		ON	T_PER.DNI = T_USU.DNI
    INNER JOIN SEGURIDAD.dbo.TCARGO_USER T_CAR
		ON	T_CAR.ID_CARGO  = T_PER.ID_CARGO
------
WHERE
------
	T_PRE.PERIODO  = '202605'

--- Considerar solo asesores vigentes
	AND T_PRE.SALDO_PRES > 0

--- Excluir casos excepcionales
	AND T_USU.ID_USER NOT IN (
	'PRECASTIGO' -- Cartera de castigos
	, 'RJULI6', 'RJULIACA', 'RLIMA7', 'RQUILLA3', 'RSICUA4' -- Carteras de recuperacion fuera de agencia
	, 'LHR5', 'HTEJ5', 'TKPN5', 'GHVJ5', 'OTA5', 'SDHF5', 'CMN5', 'HQND5' -- Recuperados de tramo de mora superior al de un recuperador de agencia
	)
)

--- ###############
--- MAIN
--- ###############

SELECT DISTINCT
	T.Periodo,
	T.IdSAgencia,
	T.IdSAsesor,
	T.AsesorNombresApellidos,
    T.Cargo,
	ColocacionNumMeta = 30
FROM
	CTE_AUX_ASESOR T
--ORDER BY
--	IdSAgencia ASC,
--	IdSAsesor  ASC
GO
