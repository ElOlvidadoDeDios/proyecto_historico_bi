GO
CREATE OR ALTER VIEW gc_creditos_cancelados_no_renovados WITH ENCRYPTION AS

--- ######################
--- NOTAS
--- ######################

/*
- La ventana de renovacion depende de la ventana de cancelacion: ventana renovacion = 31 * ventana cancelacion
*/

--- ######################
--- PREAMBULO
--- ######################

--- **********************
--- CTEs
WITH
--- **********************

--- ======================
CTE_AUX AS (
--- ======================

------------
SELECT
------------
    CAST(FECHA_MOV AS DATE) AS Fecha_Movimiento,
    CUENTA,
    OTORGA,
    PAGARE,
    SUM(CAPITAL) AS Capital
------------
FROM
------------
    PREMOV
------------
WHERE
------------
--- Limite inferior de la ventana de cancelacion
    FECHA_MOV >= DATEFROMPARTS(
                    YEAR(DATEADD(MONTH, -5, GETDATE())), -- "-5" establece hace 6 meses
                    MONTH(DATEADD(MONTH, -5, GETDATE())), -- "-5" establece hace 6 meses
                    1
                )
--- Limite superior de la ventana de cancelacion
    AND FECHA_MOV < DATEADD(
                        MONTH, 1,
                        DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
                    )
------------
GROUP BY
------------
    FECHA_MOV
    , CUENTA
    , OTORGA
    , PAGARE

--- ======================
)
,
--- ======================

--- ======================
CTE_PRESTAMOS_ORDEN AS (
--- ======================

------------
SELECT
------------
    CUENTA,
    CAST(OTORGA AS DATE) AS OTORGA,
    PAGARE,
    LEAD(CAST(OTORGA AS DATE)) OVER (PARTITION BY CUENTA ORDER BY CAST(OTORGA AS DATE), PAGARE) AS Next_Otorga
------------
FROM
------------
    PRESTAMO

--- ======================
)
,
--- ======================

--- ======================
CTE_MAIN AS (
--- ======================

------------
SELECT
------------
    CAST(T1.FEC_ULT_PAGO AS DATE) AS Fecha_Ultimo_Pago,
    T1.CUENTA,
    T1.PAGARE,
    CAST(T1.OTORGA AS DATE) AS Fecha_Otorgamiento,
    NEXO_ANA.ID_USER AS IdSAsesor,
    NEXO_SOC.RAZON_SOCIAL AS Socio,
    CAST(NEXO_PRE.FECHA_VCMTO AS DATE) AS Fecha_Vencimiento,
    CASE
        WHEN DATEDIFF(DAY, NEXO_PRE.FECHA_VCMTO, NEXO_PRE.FECHA_ULT_PAGO) < 0 THEN 'Cancelado con Anticipación'
        WHEN DATEDIFF(DAY, NEXO_PRE.FECHA_VCMTO, NEXO_PRE.FECHA_ULT_PAGO) = 0 THEN 'Cancelado a Tiempo'
        ELSE 'Cancelado con Retraso'
    END AS Tipo_Cancelacion,
    ABS(DATEDIFF(DAY, NEXO_PRE.FECHA_VCMTO, NEXO_PRE.FECHA_ULT_PAGO)) AS Diferencia_Dias,
    NEXO_PRE.PLAZO AS Nro_Cuotas,
    NEXO_PRE.PLAZO - CEILING(ABS(DATEDIFF(DAY, NEXO_PRE.FECHA_VCMTO, NEXO_PRE.FECHA_ULT_PAGO)) / NEXO_FRE.DIAS) AS Cuota_Cancelacion,
    NEXO_TIP.NOM_PROD AS Producto,
    NEXO_FRE.NOM_FRECUENCIA AS Tipo_Frecuencia,
    NEXO_PRE.MONTO_PRESTAMO,
    NEXO_AUX.Capital,
    NEXO_SOC.TLF_CEL1,
    NEXO_SOC.TLF_CEL2,
    NEXO_SOC.TLF_FIJO1,
    NEXO_SOC.TLF_FIJO2,
    PO.Next_Otorga
------------
FROM
------------
    PREEC T1
    INNER JOIN SEGURIDAD.dbo.ANAREC NEXO_ANA
        ON  NEXO_ANA.ID_ANAREC = T1.ID_ANA AND NEXO_ANA.FLAG_ANAREC = 'A'
    INNER JOIN SEGURIDAD.dbo.USUARIOS NEXO_USU
        ON  NEXO_USU.ID_USER = NEXO_ANA.ID_USER
    INNER JOIN SEGURIDAD.dbo.GRUPOUSER NEXO_GRU
        ON  NEXO_GRU.ID_GRUPO = NEXO_USU.ID_GRUPO
    INNER JOIN SEGURIDAD.dbo.PERSONAL NEXO_PER
        ON  NEXO_PER.DNI = NEXO_USU.DNI
    INNER JOIN SEGURIDAD.dbo.AGENCIA NEXO_AGE
        ON  NEXO_AGE.ID_AGE = NEXO_ANA.ID_AGE
    INNER JOIN SOCIOS NEXO_SOC
        ON  NEXO_SOC.CUENTA = T1.CUENTA
    INNER JOIN PRESTAMO NEXO_PRE
        ON  NEXO_PRE.CUENTA = T1.CUENTA
        AND NEXO_PRE.OTORGA = T1.OTORGA
        AND NEXO_PRE.PAGARE = T1.PAGARE
    INNER JOIN FRECUENCIA NEXO_FRE
        ON  NEXO_FRE.COD_FRECUENCIA = NEXO_PRE.COD_FRECUENCIA
    INNER JOIN TIPOPROD NEXO_TIP
        ON  NEXO_TIP.TIPO_PROD = NEXO_PRE.TIPO_PROD
    INNER JOIN CTE_AUX NEXO_AUX
        ON  NEXO_AUX.CUENTA = NEXO_PRE.CUENTA
        AND NEXO_AUX.OTORGA = NEXO_PRE.OTORGA
        AND NEXO_AUX.PAGARE = NEXO_PRE.PAGARE
        AND NEXO_AUX.Fecha_Movimiento = NEXO_PRE.FECHA_ULT_PAGO
    LEFT JOIN CTE_PRESTAMOS_ORDEN PO
        ON  PO.CUENTA = T1.CUENTA
        AND PO.PAGARE = T1.PAGARE
        AND PO.OTORGA = CAST(T1.OTORGA AS DATE)
------------
WHERE
------------
    T1.SALDO_PRES = 0
--- Limite inferior de la ventana de cancelacion
    AND CAST(T1.FEC_ULT_PAGO AS DATE) >= DATEFROMPARTS(
                                            YEAR(DATEADD(MONTH, -5, GETDATE())),
                                            MONTH(DATEADD(MONTH, -5, GETDATE())),
                                            1
                                        )

--- Limite superior de la ventana de cancelacion
    AND CAST(T1.FEC_ULT_PAGO AS DATE) < DATEADD(MONTH, 1, 
                                            DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
                                        )
--- ======================
)
--- ======================


--- ######################
--- MAIN
--- ######################

------------
SELECT
------------
    T.Fecha_Ultimo_Pago AS Fecha_Cancelacion,
    T.IdSAsesor,
    RIGHT(RTRIM(T.CUENTA), 6) AS Cuenta,
    T.Socio,
    T.PAGARE AS Pagare,
    T.Producto,
    T.Tipo_Frecuencia,
    T.MONTO_PRESTAMO AS Prestamo,
    T.Capital AS Saldo_Cancelacion,
    T.Fecha_Otorgamiento,
    T.Tipo_Cancelacion,
    T.Diferencia_Dias,
    CASE
        WHEN T.Tipo_Cancelacion = 'Cancelado con Anticipación'
            THEN ' ' + CAST(T.Cuota_Cancelacion AS varchar(10)) + '/' + CAST(T.Nro_Cuotas AS VARCHAR(10))
        ELSE '---'
    END AS Cuota_de_Cancelacion_Aprox,
    T.TLF_CEL1  AS Telefono_celular_1,
    T.TLF_CEL2  AS Telefono_celular_2,
    T.TLF_FIJO1 AS Telefono_fijo_1,
    T.TLF_FIJO2 AS Telefono_fijo_2
------------
FROM
------------
    CTE_MAIN T
------------
WHERE
------------
    T.Next_Otorga IS NULL
    OR T.Next_Otorga > DATEADD(DAY, 186, T.Fecha_Ultimo_Pago)  -- 186 días = ventana de renovación
GO
