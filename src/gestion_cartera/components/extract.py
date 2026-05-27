import pandas as pd
from gestion_cartera.core.utils import DatabaseConnection
from gestion_cartera.core import constants
from sqlalchemy import text  # Importar text


class Extractor:
    @classmethod
    def run(cls, sql: str, params: dict = None) -> pd.DataFrame:
        engine = DatabaseConnection.get_engine("upstream")
        sql_query = text(sql)
        df = pd.read_sql(sql_query, engine, params=params)
        engine.dispose()
        return df


if __name__ == "__main__":
    # Ejemplo de uso: pasándole el periodo 202604
    df = Extractor.run(constants.SQL_CARTERA_MORAS, params={"periodo": "202604"})
    print(df.head())
