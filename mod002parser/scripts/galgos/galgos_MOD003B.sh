#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#### Limpiar LOG ###
rm -f $LOG_CE_y_DS

echo -e $(date +"%T")"Modulo 003B - Generador de COLUMNAS ELABORADAS y DATASETS..." 2>&1 1>>${LOG_CE_y_DS}

echo -e $(date +"%T")"Generando COLUMNAS ELABORADAS..." 2>&1 1>>${LOG_CE_y_DS}
"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD003B_generar_columnas_elaboradas.sh" "" "pre"


echo -e $(date +"%T")"Generando DATASETS (usando las columnas elaboradas) - FEATURES..." 2>&1 1>>${LOG_CE_y_DS}
"/root/git/bdml/mod002parser/scripts/galgos/galgos_MOD003B_generar_datasets.sh" "" "pre"


echo -e $(date +"%T")"Modulo 003B - FIN\n\n" 2>&1 1>>${LOG_CE_y_DS}



