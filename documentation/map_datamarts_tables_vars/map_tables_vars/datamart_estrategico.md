# Mapa de Tablas y de Variables en el DataMart Estratégico

## Unidad de Análisis

* Primera unidad de agrupamiento: asesor
* Segunda unidad de agrupamiento: agencia

## Variables del DataMart Estratégico

### Variables de Dimensiones

**Dimensión Asesor**

- Identificador del asesor
    - Proporcionado por nuestro core crediticio (SICOOP)
- Identificador del periodo
- Nombre completo
    - Nombles y apellidos del asesor
- Nombre corto del asesor
    - Alias del asesor
- Cargo
    - Dado que hay también recuperadores
- Identificador de la agencia del asesor

**Dimensión Agencia**

Dado que son pocas agencias, esta dimensión será implementada manualmente en Power BI.

**Dimensión Calendario**

### Variables de Hechos

**Variables de Flujo**

*Colocación*

Tanto en cantidad como en monto.

* Variable de hecho
* Variable de flujo
* Temporalidades:
    * day (on_date):
        - real: sí, calculable en SQL (calcblSQL)
        - proyectado: sí, manuable en SQL (manublSQL)
        - meta: sí, manuable en SQL (manublSQL)
    * month (at_date):
        - real: sí, calculable en Power BI (calcblPBI)
        - proyectado: sí, calculable en Power BI (calcblPBI)
        - meta: sí, manuable en SQL (manublSQL)

*Repago*

En monto.

* Variable de hecho
* Variable de flujo
* Temporalidades:
    * day (on_date):
        - real: sí, calculable en SQL (calcblSQL)
        - programado: sí, calculable en SQL (calcblSQL)
        - meta: no
    * month (at_date):
        - real: sí, calculable en Power BI (calcblPBI)
        - programado: sí, calculable en Power BI (calcblPBI)
        - meta: no

**Variables de Stock**

*Cartera*

En monto.

* Variable de hecho
* Variable de stock
* Naturaleza temporal:
    * month (at_date): intrínseca
        - real: sí -> calculable en SQL (calcbl_sql)
        - proyectado/programado: no
        - meta: no
    * day (on_date): extrínseca
        - real: sí -> calculable en Python (calcbl_python)
        - proyectado/programado: no
        - meta: no

*Mora*

En monto.

* Variable de hecho
* Variable de stock
* Naturaleza temporal:
    * month(at_date): intrínseca
        * real: sí, calculable en SQL (calcbl_sql)
        * programado/proyectado: no
        * meta: sí, manuable en Power BI (manubl_pbi)
    * day(on_date): extrínseca
        * real: sí, calculable en Python (calcbl_python)
        * programado/proyectado: no
        * meta: no

## Tablas del DataMart Estratégico

### Tablas de Dimensiones

- dim_asesor

### Tablas de Hechos

- fct_flow_day_calcbl
- fct_flow_day_manubl
- fct_flow_month_manubl

- fct_stock_month_calcbl