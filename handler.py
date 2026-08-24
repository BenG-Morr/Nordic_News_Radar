"""Temporärer Lambda-Handler für den Infrastruktur-Schritt von Phase 2.

Die eigentliche Feed-/Bedrock-Verarbeitung wird im nächsten Umsetzungsschritt
in dieser Datei ergänzt. Der Stub hält die Terraform-Bereitstellung bereits
vollständig reproduzierbar, ohne versehentlich Kosten durch Modellaufrufe zu erzeugen.
"""

import logging

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, context):
    LOGGER.info("Nordic News Radar infrastructure smoke test. Event: %s", event)
    return {
        "statusCode": 200,
        "message": "Infrastructure deployed; application backend not implemented yet.",
    }
