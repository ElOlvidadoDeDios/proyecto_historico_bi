from dotenv import load_dotenv
from gestion_cartera.core.constants import PATH_ENV

load_dotenv(PATH_ENV)
import argparse
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
    "historical": "bucle",
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("pipeline", choices=PIPELINES.keys())
    args = parser.parse_args()

    if args.pipeline == "historical":
        for mes in ["202601", "202602", "202603", "202604", "202605"]:
            print(f"Cargando periodo {mes}...")
            pipeline_historical(mes)
    else:
        PIPELINES[args.pipeline]()


if __name__ == "__main__":
    main()
