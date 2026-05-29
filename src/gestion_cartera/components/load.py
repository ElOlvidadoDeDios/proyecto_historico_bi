from abc import ABC, abstractmethod
import pandas as pd
from gestion_cartera.core.utils import DatabaseConnection
from sqlalchemy import text
from enum import Enum
from typing import Literal
from sqlalchemy.types import Date  # <-- Importación centralizada para todo el archivo
from gestion_cartera.core.config import ConfigManager
from datetime import date


# Producto Base
class Loader(ABC):

    @abstractmethod
    def run(cls, df: pd.DataFrame, table: str):
        pass


# Estrategias Base


class StrategyLoaderStrategic(Loader, ABC):

    engine = DatabaseConnection.get_engine("downstream")

    @classmethod
    def run(cls, df: pd.DataFrame, table: str):
        pass


class StrategyLoaderOperational(Loader, ABC):

    # NOTA: Especificar obtención de 'engine' cuando se implemente la capa operativa
    @classmethod
    def run(cls, df: pd.DataFrame, table: str):
        pass


# Productos/Estrategias Concretas


class LoaderStrategicInitial(StrategyLoaderStrategic):

    @classmethod
    def run(cls, df: pd.DataFrame, table: str):
        dtypes = {}
        # Forzar tipo DATE nativo en SQL Server sin horas
        if "Fecha" in df.columns:
            df["Fecha"] = pd.to_datetime(df["Fecha"]).dt.date
            dtypes["Fecha"] = Date()

        df.to_sql(table, con=cls.engine, if_exists="replace", index=False, dtype=dtypes)
        cls.engine.dispose()


class LoaderStrategicVariational(StrategyLoaderStrategic):

    @classmethod
    def run(cls, df: pd.DataFrame, table: str):
        if "Periodo" not in df.columns:
            raise ValueError(f"Falta la columna 'Periodo' en {table}.")

        periodos_en_datos = df["Periodo"].unique()

        dtypes = {}
        # Forzar tipo DATE nativo en SQL Server sin horas
        if "Fecha" in df.columns:
            df["Fecha"] = pd.to_datetime(df["Fecha"]).dt.date
            dtypes["Fecha"] = Date()

        with cls.engine.begin() as conn:
            for periodo in periodos_en_datos:
                conn.execute(
                    text(f"DELETE FROM {table} WHERE Periodo = :periodo"),
                    {"periodo": str(periodo)},
                )

            df.to_sql(table, con=conn, if_exists="append", index=False, dtype=dtypes)


# Contexto para el Datamart Operativo (Placeholder estructural)
class LoaderOperational(StrategyLoaderOperational):
    @classmethod
    def run(cls, df: pd.DataFrame, table: str):
        pass


# Contexto Dinámico Estratégico
class LoaderStrategic(StrategyLoaderStrategic):

    def __init__(self, strategy: StrategyLoaderStrategic | None = None) -> None:
        self._strategy = strategy

    @property
    def strategy(self):
        return self._strategy

    @strategy.setter
    def strategy(self, strategy):
        self._strategy = strategy

    def run(self, df: pd.DataFrame, table: str) -> None:
        return self.strategy.run(df, table)


# Factory de BI
class BIType(Enum):
    strategic = "strategic"
    operational = "operational"


class LoaderFactory:
    @staticmethod
    def get_loader(bi_type: Literal["strategic", "operational"]) -> Loader:
        try:
            bi_type = BIType(bi_type)
        except ValueError:
            raise ValueError(f"Unsupported loader type: {bi_type}")

        if bi_type is BIType.strategic:
            return LoaderStrategic()
        elif bi_type is BIType.operational:
            return LoaderOperational()
