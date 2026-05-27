import os
from dotenv import load_dotenv
from gestion_cartera.core.constants import PATH_ENV

# Carga las variables de tu .env
load_dotenv(PATH_ENV)


def verificar_conexion():
    upstream_db = os.getenv("DB_UPSTREAM_DATABASE")
    upstream_server = os.getenv("DB_UPSTREAM_SERVER")
    downstream_db = os.getenv("DB_DOWNSTREAM_DATABASE")
    downstream_server = os.getenv("DB_DOWNSTREAM_SERVER")

    print("--- DIAGNÓSTICO DE CONEXIÓN ---")
    print(f"FUENTE (Upstream): Servidor={upstream_server}, Base={upstream_db}")
    print(
        f"DESTINO (Downstream/Local): Servidor={downstream_server}, Base={downstream_db}"
    )
    print("-------------------------------")


if __name__ == "__main__":
    verificar_conexion()
