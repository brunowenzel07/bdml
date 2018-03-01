#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"


#Análisis de una carrera concreta extremo a extremo, que este en el dataset PASADO-VALIDATION y con 6 galgos, para ver si hay algun fallo:

FILE_TEMP="./temp_id_carrera_analisis"

mysql -u root --password=datos1986 -N --execute="SELECT A.id_carrera FROM datos_desa.tb_dataset_ids_pasado_validation_TOTAL A LEFT JOIN (SELECT id_carrera FROM datos_desa.tb_filtrada_carrerasgalgos_TOTAL GROUP BY id_carrera HAVING count(*)=6) B ON A.id_carrera=B.id_carrera LIMIT 1;" > ${FILE_TEMP}
id_carrera_analizada=$( cat ${FILE_TEMP})

########################################################################################################

read -d '' CONSULTA_ANTES_DE_PREDECIR <<- EOF
SELECT id_carrera FROM datos_desa.tb_filtrada_carreras_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT A.galgo_nombre FROM datos_desa.tb_filtrada_galgos_TOTAL A WHERE A.galgo_nombre IN (SELECT galgo_nombre FROM datos_desa.tb_filtrada_carrerasgalgos_TOTAL WHERE id_carrera=${id_carrera_analizada} ) 
LIMIT 10;

SELECT id_carrera, galgo_nombre, velocidad_con_going_norm FROM datos_desa.tb_filtrada_carrerasgalgos_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT * FROM datos_desa.tb_ds_pasado_validation_featuresytarget_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "\nAntes de predecir:\n" 2>&1 1>>${LOG_060_ENDTOEND}
echo -e "$CONSULTA_ANTES_DE_PREDECIR" 2>&1 1>>${LOG_060_ENDTOEND}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_ANTES_DE_PREDECIR" 2>&1 1>>${LOG_060_ENDTOEND}

########################################################################################################

read -d '' CONSULTA_DESPUES_DE_PREDECIR <<- EOF
SELECT * FROM datos_desa.tb_val_TOTAL_aux1 LIMIT 6;
SELECT * FROM datos_desa.tb_val_TOTAL_aux2 LIMIT 6;
SELECT * FROM datos_desa.tb_val_TOTAL_aux3 LIMIT 6;
SELECT * FROM datos_desa.tb_val_TOTAL_aux4 LIMIT 6;
SELECT * FROM datos_desa.tb_val_TOTAL_aux5 WHERE id_carrera=${id_carrera_analizada} LIMIT 6;

SELECT id_carrera, rowid, target_real, target_predicho FROM datos_desa.tb_val_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;

SELECT * FROM datos_desa.tb_val_score_real_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 6;
SELECT * FROM datos_desa.tb_val_score_predicho_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 6;
SELECT * FROM datos_desa.tb_score_aciertos_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 6;
SELECT * FROM datos_desa.tb_val_connombre_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 6;
SELECT * FROM datos_desa.tb_val_aciertos_connombre_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 6;

select * FROM datos_desa.tb_val_economico_TOTAL WHERE id_carrera=${id_carrera_analizada} LIMIT 10;
EOF

echo -e "\nDespues de predecir:\n" 2>&1 1>>${LOG_060_ENDTOEND}
echo -e "$CONSULTA_DESPUES_DE_PREDECIR" 2>&1 1>>${LOG_060_ENDTOEND}
mysql -u root --password=datos1986 -t --execute="$CONSULTA_DESPUES_DE_PREDECIR" 2>&1 1>>${LOG_060_ENDTOEND}

########################################################################################################

echo -e "\nATENCION: debo COMPROBAR que los galgos de ENTRADA sean los mismos que los de SALIDA y que tengan precio SP !!!!!!!!!\n\n" 2>&1 1>>${LOG_060_ENDTOEND}



