# DataMart Estratégico

* [x] Crear base de datos `dm_gestion_cartera_strategic`.
* [x] Establecer el nombre de este DataMart como variable de entorno en `.env/`.

Nota. Dado que este DataMart es estratégico, las agrupaciones se harán a su primer nivel, en concreto al nivel de asesores de crédito. Los siguientes niveles de agrupación (agencia y cooperativa) se obtendrán agrupando a partir de esta primera agrupación.

## Tablas y Variables de Dimensiones

### Dimensión Asesor

**Tabla**

* Configuraciones: `conf\config.yaml`
    * [ ] `dim_asesor`

**Variables**

* SQL: `sql/dim_asesor.sql`
    * [x] `IdSAsesor`
    * [x] `AsesorNombresApellidos`
    * [x] `Cargo`
    * [x] `IdSAgencia`

* Python
    * [x] `Asesor`

## Tablas y Variables de Hechos

### Tablas

* Configuraciones: `conf\config.yaml`
    * [ ] `fct_flow_day_calcbl`
    * [ ] `fct_flow_day_manubl`
    * [ ] `fct_flow_month_manubl`
    * [ ] `fct_stock_month_calcbl`

### Variables

---

**Colocación**

*Respecto a la cantidad*

Vía programación:

* Colocación -> cantidad -> day -> real
    * [ ] `inital/__init__.py`
    * [ ] `incremental/__init__.py`
* Colocación -> cantidad -> month -> real
    * [ ] calculable en Power BI
* Colocación -> cantidad -> month -> proyectado
    * [ ] calculable en Power BI

Manualmente:

* [ ] Colocación -> cantidad -> day -> proyectado (manual en SQL Server)
* [ ] Colocación -> cantidad -> day -> meta (manual en SQL Server)
* [ ] Colocación -> cantidad -> month -> meta (manual en SQL Server)

*Respecto al monto*

Vía programación:

* Colocación -> monto -> day -> real
    * [ ] `inital/__init__.py`
    * [ ] `incremental/__init__.py`

* Colocación -> monto -> month -> real
    * calculable en Power BI
* Colocación -> monto -> month -> proyectado
    * calculable en Power BI

Manualmente:

* Colocación -> monto -> day -> proyectado
    * SQL Server
* Colocación -> monto -> day -> meta
    * SQL Server
* Colocación -> monto -> month -> meta
    * SQL Server

---

**Repago**

Vía programación:

* Repago -> monto -> day -> real
    * [ ] `inital/__init__.py`
    * [ ] `incremental/__init__.py`
* Repago -> monto -> day -> programado
    * [ ] `inital/__init__.py`
    * [ ] `incremental/__init__.py`
* Repago -> monto -> month -> real
    * calculable en Power BI
* Repago -> monto -> month -> programado
    * calculable en Power BI

---

**Mora**

Vía programación:

* Mora -> monto -> day   -> real (Nota. No necesario calcular la mora de cada día)
    - [ ] `day/__init__.py`
    - [ ] `month/__init__.py`
* Mora -> monto -> month -> real
    - [ ] `vars_stock/__init__.py`

Manualmente:

* Mora -> monto -> month -> meta
    - Power BI

---