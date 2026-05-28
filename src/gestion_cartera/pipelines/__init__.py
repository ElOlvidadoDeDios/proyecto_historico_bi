from gestion_cartera.core.config import ConfigManager
from gestion_cartera.core.constants import SQL
from gestion_cartera.components.extract import Extractor
from gestion_cartera.components.transform import TransformerFactory
from gestion_cartera.components.load import (
    LoaderFactory,
    LoaderStrategicInitial,
    LoaderStrategicVariational,
)
import pandas as pd
from enum import Enum
from typing import Literal, Optional, Callable
from dataclasses import dataclass
from box import Box


class Variant(Enum):
    INITIAL = "initial"
    VARIATIONAL = "variational"
    OPERATIONAL = "operational"


STRATEGY_BY_VARIANT = {
    Variant.INITIAL: LoaderStrategicInitial,
    Variant.VARIATIONAL: LoaderStrategicVariational,
    Variant.OPERATIONAL: LoaderStrategicInitial,
}


@dataclass(frozen=True)
class ConfigSubject:
    sql: str
    table: object
    transformer_key: Optional[str] = None


def _get_transformer(transformer_key: Optional[str]) -> Callable:
    if not transformer_key:
        return lambda df: df

    transformer = TransformerFactory().get_transformer(transformer_key)
    return lambda df: transformer.run(df=df)


SUBJECTS = Box(
    {
        "strategic": {
            "dim_asesor": ConfigSubject(
                sql=SQL.STRATEGIC.DIM_ASESOR,
                table=ConfigManager.table.dim.asesor,
                transformer_key="dim_asesor",
            ),
            "fct_stock": ConfigSubject(
                sql=SQL.STRATEGIC.FCT_STOCK,
                table=ConfigManager.table.fct.stock,
                transformer_key=None,
            ),
            "fct_flow": ConfigSubject(
                sql=SQL.STRATEGIC.FCT_FLOW,
                table=ConfigManager.table.fct.flow,
                transformer_key=None,
            ),
        },
        "operational": {
            "creditos_cancelados_no_renovados": ConfigSubject(
                sql=SQL.OPERATIONAL.CREDITOS_CANCELADOS_NO_RENOVADOS,
                table=ConfigManager.table.opr.creditos_cancelados_no_renovados,
                transformer_key=None,
            ),
            "ranking_asesor": ConfigSubject(
                sql=SQL.OPERATIONAL.RANKING_ASESOR,
                table=ConfigManager.table.opr.ranking_asesor,
                transformer_key=None,
            ),
            "avance_cartera": ConfigSubject(
                sql=SQL.OPERATIONAL.AVANCE_CARTERA,
                table=ConfigManager.table.opr.avance_cartera,
                transformer_key=None,
            ),
        },
    }
)

Domain = Literal["strategic", "operational"]
SubjectStrategic = Literal["dim_asesor", "fct_stock", "fct_flow"]
SubjectOperational = Literal[
    "creditos_cancelados_no_renovados", "ranking_asesor", "avance_cartera"
]


# 1. Añade el parámetro 'periodo' a la firma de la función
def pipeline(
    domain: Domain,
    subject: SubjectStrategic | SubjectOperational,
    variant: Variant,
    periodo: str = None,
) -> None:

    try:
        cfg: ConfigSubject = SUBJECTS[domain][subject]
    except KeyError as e:
        disponibles = (
            list(SUBJECTS[domain].keys())
            if domain in SUBJECTS
            else list(SUBJECTS.keys())
        )
        raise KeyError(
            f"No existe SUBJECT '{subject}' bajo dominio '{domain}'. Disponibles: {disponibles}"
        ) from e

    # 2. PREPARA Y PASA EL PARÁMETRO AL EXTRACTOR
    params = {"periodo": periodo} if periodo else None
    df_extracted = Extractor.run(cfg.sql, params=params)

    # Transform
    transform = _get_transformer(cfg.transformer_key)
    df_transformed = transform(df_extracted)

    # Load
    loader = LoaderFactory.get_loader("strategic")
    loader.strategy = STRATEGY_BY_VARIANT[variant]
    loader.run(df=df_transformed, table=cfg.table)

    try:
        cfg: ConfigSubject = SUBJECTS[domain][subject]
    except KeyError as e:
        raise KeyError(f"Error: {e}")

    params = {"periodo": periodo} if periodo else None
    df_extracted = Extractor.run(cfg.sql, params=params)

    transform = _get_transformer(cfg.transformer_key)
    df_transformed = transform(df_extracted)

    loader = LoaderFactory.get_loader("strategic")
    loader.strategy = STRATEGY_BY_VARIANT[variant]
    loader.run(df=df_transformed, table=cfg.table)


# 3. Crea una nueva función orquestadora para la carga histórica
def pipeline_historical(periodo: str) -> None:
    pipeline("strategic", "dim_asesor", Variant.VARIATIONAL, periodo)
    pipeline("strategic", "fct_stock", Variant.VARIATIONAL, periodo)
    pipeline("strategic", "fct_flow", Variant.VARIATIONAL, periodo)


def pipeline_initial() -> None:
    pipeline("strategic", "dim_asesor", Variant.INITIAL)
    pipeline("strategic", "fct_stock", Variant.INITIAL)
    pipeline("strategic", "fct_flow", Variant.INITIAL)


def pipeline_variational() -> None:
    # ANTES: Llamaba a Variant.INITIAL (reemplazaba todo)
    # AHORA: Llama a la estrategia Variational (Añade el mes sin borrar la historia)
    pipeline("strategic", "dim_asesor", Variant.VARIATIONAL)
    pipeline("strategic", "fct_stock", Variant.VARIATIONAL)
    pipeline("strategic", "fct_flow", Variant.VARIATIONAL)


def pipeline_operational() -> None:
    pipeline("operational", "creditos_cancelados_no_renovados", Variant.INITIAL)
    pipeline("operational", "avance_cartera", Variant.INITIAL)
    pipeline("operational", "ranking_asesor", Variant.OPERATIONAL)


def pipeline_operational_ranking_asesor() -> None:
    pipeline("operational", "ranking_asesor", Variant.INITIAL)


if __name__ == "__main__":
    pipeline_variational()
