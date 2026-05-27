from dotenv import load_dotenv
from gestion_cartera.core.constants import PATH_ENV

load_dotenv(PATH_ENV)
import argparse
from gestion_cartera.pipelines import (
    pipeline_initial,
    pipeline_variational,
    pipeline_operational,
    pipeline_operational_ranking_asesor,
)


PIPELINES = {
    "initial": pipeline_initial,
    "variational": pipeline_variational,
    "operational": pipeline_operational,
    "opr_ranking_asesor": pipeline_operational_ranking_asesor,
}


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Ejecutar pipelines de gestión de cartera."
    )
    parser.add_argument(
        "pipeline",
        choices=PIPELINES.keys(),
        help="Pipeline a ejecutar: 'initial, 'variational', 'operational' o 'opr_ranking_asesor'.",
    )
    args = parser.parse_args()

    PIPELINES[args.pipeline]()


if __name__ == "__main__":
    main()
