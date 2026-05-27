import os
from sqlalchemy import create_engine
from ensure import ensure_annotations
import yaml
from box.exceptions import BoxValueError
from box import ConfigBox
from pathlib import Path

class DatabaseConnection:
    @classmethod
    def _get_env(cls, stream: str) -> tuple[str]:
        if stream == 'upstream':
            user = os.getenv('DB_UPSTREAM_USER')
            password = os.getenv('DB_UPSTREAM_PASSWORD')
            server = os.getenv('DB_UPSTREAM_SERVER')
            database = os.getenv('DB_UPSTREAM_DATABASE')
            return user, password, server, database

        if stream == 'downstream':
            server = os.getenv('DB_DOWNSTREAM_SERVER')
            database = os.getenv('DB_DOWNSTREAM_DATABASE')
            return None, None, server, database 
    
    @classmethod
    def _get_conn(cls, stream:str, user, password, server, database) -> str:
        if stream == 'upstream':
            conn = f'mssql+pyodbc://{user}:{password}@{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server'
            return conn

        if stream == 'downstream':
            conn = f'mssql+pyodbc://{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server'
            return conn
    
    @classmethod
    def _get_engine(cls, conn:str):
        return create_engine(conn)
    
    @classmethod
    def get_engine(cls, stream:str):
        user, password, server, database = cls._get_env(stream)
        conn = cls._get_conn(stream, user, password, server, database)
        engine = cls._get_engine(conn)
        return engine


@ensure_annotations
def read_yaml(path_to_yaml: Path) -> ConfigBox:
    try:
        with open(path_to_yaml, 'r') as file_yaml:
            content = yaml.safe_load(file_yaml)
            if not content:
                raise ValueError('YAML file is empty.')
            return ConfigBox(content)
    except BoxValueError:
        raise ValueError('YAML file is empty.')
    except Exception as e:
        raise e


if __name__ == '__main__':
    print(DatabaseConnection.engine('downstream'))