USE [dm_gestion_cartera]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Dimensión Calendario (diario)
CREATE OR ALTER PROCEDURE [dbo].[dim_calendario_on_date]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fecha_inicio date;
    DECLARE @fecha_fin date;
    DECLARE @anio INT;
    DECLARE @trimestre INT;
    DECLARE @periodo VARCHAR(6);
    DECLARE @mes_num INT;
    DECLARE @mes_corto VARCHAR(3);
    DECLARE @mes_largo VARCHAR(20);
    DECLARE @dia INT;

    -- Variables para Pascua/Semana Santa (Meeus)
    DECLARE @a INT, @b INT, @c INT, @d INT, @e INT, @f INT, @g INT, @h INT, @i INT, @k INT, @l INT, @m INT;
    DECLARE @mes_pascua INT, @dia_pascua INT;
    DECLARE @pascua DATE, @jueves_santo DATE, @viernes_santo DATE;

    CREATE TABLE #DIM_CALENDARIO
    (
        Fecha      date,
        Año        INT,
        Trimestre  INT,
        Periodo    VARCHAR(6),
        NumMes     INT,
        Mes        VARCHAR(3),
        MesLargo   VARCHAR(20),
        Dia        INT,
        EsDomingo  BIT,
        EsFeriado  BIT
    );

    SET @fecha_inicio = '2025-01-01';
    SELECT @fecha_fin = MAX(Fecha) FROM fct_flow;

    WHILE @fecha_inicio <= @fecha_fin
    BEGIN
        SET @anio       = YEAR(@fecha_inicio);
        SET @trimestre  = DATEPART(QUARTER, @fecha_inicio);
        SET @periodo    = FORMAT(@fecha_inicio, 'yyyyMM', 'es-PE');
        SET @mes_num    = MONTH(@fecha_inicio);
        SET @mes_corto  = FORMAT(@fecha_inicio, 'MM', 'es-PE');
        SET @mes_largo  = FORMAT(@fecha_inicio, 'MMMM', 'es-PE');
        SET @dia        = DAY(@fecha_inicio);

        /* Pascua (gregoriano, Meeus) para @anio */
        SET @a = @anio % 19;
        SET @b = @anio / 100;
        SET @c = @anio % 100;
        SET @d = @b / 4;
        SET @e = @b % 4;
        SET @f = (@b + 8) / 25;
        SET @g = (@b - @f + 1) / 3;
        SET @h = (19*@a + @b - @d - @g + 15) % 30;
        SET @i = @c / 4;
        SET @k = @c % 4;
        SET @l = (32 + 2*@e + 2*@i - @h - @k) % 7;
        SET @m = (@a + 11*@h + 22*@l) / 451;
        SET @mes_pascua = ( @h + @l - 7*@m + 114 ) / 31;
        SET @dia_pascua = (( @h + @l - 7*@m + 114 ) % 31) + 1;
        SET @pascua = DATEFROMPARTS(@anio, @mes_pascua, @dia_pascua);
        SET @jueves_santo  = DATEADD(DAY, -3, @pascua);
        SET @viernes_santo = DATEADD(DAY, -2, @pascua);

        INSERT INTO #DIM_CALENDARIO
        (
            Fecha, Trimestre, Periodo, Año, NumMes, Mes, MesLargo, Dia, EsDomingo, EsFeriado
        )
        SELECT
            @fecha_inicio,
            @trimestre,
            @periodo,
            @anio,
            @mes_num,
            @mes_corto,
            @mes_largo,
            @dia,
            -- Domingo (equivalente a WEEKDAY(Fecha, 2)=7)
            CASE WHEN ((DATEDIFF(DAY, '19000101', @fecha_inicio) % 7) + 1) = 7 THEN 1 ELSE 0 END,
            -- Feriados Perú (fijos + Semana Santa)
            CASE
                WHEN @fecha_inicio IN (
                    DATEFROMPARTS(@anio, 1, 1),   -- Año Nuevo
                    DATEFROMPARTS(@anio, 5, 1),   -- Día del Trabajo
                    DATEFROMPARTS(@anio, 6, 7),   -- Batalla de Arica y Día de la Bandera
                    DATEFROMPARTS(@anio, 6, 29),  -- San Pedro y San Pablo
                    DATEFROMPARTS(@anio, 7, 23),  -- Día de la Fuerza Aérea del Perú
                    DATEFROMPARTS(@anio, 7, 28),  -- Fiestas Patrias
                    DATEFROMPARTS(@anio, 7, 29),  -- Fiestas Patrias
                    DATEFROMPARTS(@anio, 8, 6),   -- Batalla de Junín
                    DATEFROMPARTS(@anio, 8, 30),  -- Santa Rosa de Lima
                    DATEFROMPARTS(@anio,10, 8),   -- Combate de Angamos
                    DATEFROMPARTS(@anio,11, 1),   -- Día de Todos los Santos
                    DATEFROMPARTS(@anio,12, 8),   -- Inmaculada Concepción
                    DATEFROMPARTS(@anio,12, 9),   -- Batalla de Ayacucho
                    DATEFROMPARTS(@anio,12,25)    -- Navidad
                )
                OR @fecha_inicio IN (@jueves_santo, @viernes_santo) -- Semana Santa
                THEN 1 ELSE 0
            END;

        SET @fecha_inicio = DATEADD(DAY, 1, @fecha_inicio);
    END;

    SELECT * FROM #DIM_CALENDARIO ORDER BY Fecha;
END
