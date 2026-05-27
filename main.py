from dotenv import load_dotenv
from gestion_cartera.core.constants import PATH_ENV

load_dotenv(PATH_ENV)
import argparse
from gestion_cartera.pipelines import (
    pipeline_initial,
    pipeline_variational,
    pipeline_operational,
    pipeline_operational_ranking_asesor,
    pipeline_historical,  # <--- NUEVA
)

PIPELINES = {
    "initial": pipeline_initial,
    "variational": pipeline_variational,
    "operational": pipeline_operational,
    "opr_ranking_asesor": pipeline_operational_ranking_asesor,
    "historical": "bucle_historico",  # <--- NUEVA
}


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Ejecutar pipelines de gestión de cartera."
    )
    parser.add_argument(
        "pipeline",
        choices=PIPELINES.keys(),
        help="Pipeline a ejecutar: 'initial', 'variational', 'operational', 'opr_ranking_asesor' o 'historical'.",
    )
    args = parser.parse_args()

    # Lógica especial si elige el histórico
    if args.pipeline == "historical":
        meses_historicos = ["202601", "202602", "202603", "202604", "202605"]
        print(f"Iniciando carga histórica en la base de datos de pruebas...")
        for mes in meses_historicos:
            print(f"Procesando periodo: {mes}")
            pipeline_historical(mes)
        print("¡Carga histórica completada con éxito!")
    else:
        PIPELINES[args.pipeline]()


if __name__ == "__main__":
    main()
