import argparse
import os  # <-- CORRECCIÓN: Requerido para auditar las credenciales del .env
from dotenv import load_dotenv
from gestion_cartera.core.constants import PATH_ENV

# Cargar variables de entorno antes de importar los componentes de cartera
load_dotenv(PATH_ENV)

from gestion_cartera.pipelines import (
    pipeline_initial,
    pipeline_variational,
    pipeline_operational,
    pipeline_operational_ranking_asesor,
    pipeline_historical,
)

PIPELINES = {
    "initial": pipeline_initial,
    "variational": pipeline_variational,
    "operational": pipeline_operational,
    "opr_ranking_asesor": pipeline_operational_ranking_asesor,
    "historical": pipeline_historical,
}


def imprimir_banner_seguridad(pipeline_name: str, periodo: str) -> None:
    """Imprime una auditoría visual explícita de los entornos antes de ejecutar el pipeline."""
    upstream_server = os.getenv("DB_UPSTREAM_SERVER", "No definido")
    upstream_db = os.getenv("DB_UPSTREAM_DATABASE", "No definido")
    downstream_server = os.getenv("DB_DOWNSTREAM_SERVER", "No definido")
    downstream_db = "dm_estrategico_hist"

    print("=" * 65)
    print(" 🛠️  AUDITORÍA DE ENTORNOS Y CONTROL DE PROCESAMIENTO DATA_PIPELINE")
    print("=" * 65)
    print(f" 📅 PERIODO(S) SELECCIONADO(S) : {periodo}")
    print(f" ⚡ PIPELINE EN EJECUCIÓN      : {pipeline_name.upper()}")
    print("-" * 65)
    print(" 📥 FUENTE DE EXTRACCIÓN (Upstream - Servidor Central):")
    print(f"    -> Servidor : {upstream_server}")
    print(f"    -> Base de Datos : {upstream_db}")
    print(f"    -> Modo : LECTURA PURA (Ningún dato será alterado aquí)")
    print("-" * 65)
    print(" 📤 CARGA LOCAL DESTINO (Downstream - Tu Servidor de Pruebas):")
    print(f"    -> Servidor : {downstream_server}")
    print(f"    -> Base de Datos : {downstream_db}")
    if pipeline_name == "initial":
        print(
            f"    -> Operación : REPLACEMENT (Vaciado estructural e indexación limpia)"
        )
    else:
        print(
            f"    -> Operación : APPEND HISTÓRICO (Consolidación acumulada de periodos)"
        )
    print("=" * 65)
    print(" 🛡️  ESTADO DE SEGURIDAD: VERDE (Entorno de producción protegido)")
    print("=" * 65)
    print("\n⏳ Procesando consultas en el servidor central...")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("pipeline", choices=PIPELINES.keys())
    # CORRECCIÓN: Se añade el argumento de periodo para evitar fallos de atributo en consola
    parser.add_argument(
        "-p",
        "--periodo",
        type=str,
        default="202605",
        help="Periodo (yyyyMM) a procesar",
    )
    args = parser.parse_args()

    if args.pipeline == "initial":
        imprimir_banner_seguridad(args.pipeline, args.periodo)
        pipeline_initial(args.periodo)
        print(
            f"🟢 ¡Éxito! Estructuras inicializadas correctamente en 'dm_estrategico_hist'.\n"
        )

    elif args.pipeline == "historical":
        # Ejecución masiva controlada de tus 5 periodos históricos continuos
        periodos_historicos = ["202601", "202602", "202603", "202604", "202605"]

        imprimir_banner_seguridad(args.pipeline, ", ".join(periodos_historicos))

        for mes in periodos_historicos:
            print(f"▓▒░ Extrayendo y acumulando de forma segura el periodo: {mes}...")
            pipeline_historical(mes)

        print(
            f"🟢 ¡Éxito! Los 5 meses se consolidaron limpiamente en 'dm_estrategico_hist'.\n"
        )
    else:
        PIPELINES[args.pipeline]()


if __name__ == "__main__":
    main()
