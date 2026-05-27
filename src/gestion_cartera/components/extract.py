import pandas as pd
from gestion_cartera.core.utils import DatabaseConnection

from gestion_cartera.core import constants

class Extractor:
    @classmethod
    def run(cls, sql) -> pd.DataFrame:
        engine = DatabaseConnection.get_engine('upstream')
        df = pd.read_sql(sql, engine)
        engine.dispose()
        return df


if __name__ == '__main__':
    df = Extractor.run(constants.SQL_CARTERA_MORAS)
    print(df.head())