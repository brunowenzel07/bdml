#!/bin/bash

source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"


#### Limpiar LOG ###
rm -f $LOG_042


######################## PARAMETROS ############
if [ "$#" -ne 1 ]; then
    echo " MOD042_1st - Numero de parametros incorrecto!!!" 2>&1 1>>${LOG_042}
fi

TAG="${1}"

echo -e $(date +"%T")" | 042_1st | Modelos predictivos: 1st ($TAG) | INICIO" >>$LOG_070

echo -e "MOD042_1st ($TAG) --> LOG = "${LOG_042}


######################### CALCULO DEL SCORE ################
echo -e $(date +"%T")" Calculando SCORE a partir del dataset de VALIDATION..." 2>&1 1>>${LOG_042}

#SCORE: de las predichas que hayan quedado PRIMERO, veremos si en REAL quedaron PRIMERO. Y sacamos el porcentaje de acierto.

read -d '' CONSULTA_SCORE <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_val_1st_score_real_${TAG};

CREATE TABLE datos_desa.tb_val_1st_score_real_${TAG} AS
SELECT id_carrera, galgo_rowid, target_real,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_real
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_real FROM datos_desa.tb_val_${TAG} ORDER BY id_carrera ASC, target_real DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;

ALTER TABLE datos_desa.tb_val_1st_score_real_${TAG} ADD INDEX tb_val_1st_SR_${TAG}_idx(id_carrera, galgo_rowid);


DROP TABLE IF EXISTS datos_desa.tb_val_1st_score_predicho_${TAG};

CREATE TABLE datos_desa.tb_val_1st_score_predicho_${TAG} AS
SELECT id_carrera, galgo_rowid, target_predicho,
CASE id_carrera
  WHEN @curIdCarrera THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curIdCarrera := id_carrera )
END AS posicion_predicha
FROM (
  SELECT id_carrera, rowid AS galgo_rowid, target_predicho FROM datos_desa.tb_val_${TAG} ORDER BY id_carrera ASC, target_predicho DESC 
) dentro,
(SELECT @curRow := 0, @curIdCarrera := '') R;

ALTER TABLE datos_desa.tb_val_1st_score_predicho_${TAG} ADD INDEX tb_val_1st_SP_${TAG}_idx(id_carrera, galgo_rowid);


DROP TABLE IF EXISTS datos_desa.tb_1st_score_aciertos_${TAG};

CREATE TABLE datos_desa.tb_1st_score_aciertos_${TAG} AS
SELECT A.*, B.posicion_real,

CASE
  WHEN A.posicion_predicha IN (1) THEN true
  ELSE false
END AS predicha_1st,

CASE 
  WHEN (A.posicion_predicha IN (1) AND B.posicion_real IN (1)) THEN 1
  ELSE 0 
END as acierto

FROM datos_desa.tb_val_1st_score_predicho_${TAG} A
LEFT JOIN datos_desa.tb_val_1st_score_real_${TAG} B
ON (A.id_carrera=B.id_carrera AND A.galgo_rowid=B.galgo_rowid);

ALTER TABLE datos_desa.tb_1st_score_aciertos_${TAG} ADD INDEX tb_1st_SA_${TAG}_idx(galgo_rowid);


DROP TABLE IF EXISTS datos_desa.tb_val_1st_connombre_${TAG};

CREATE TABLE datos_desa.tb_val_1st_connombre_${TAG} AS
SELECT AB.*, @rowid:=@rowid+1 as rowid 
FROM (
  SELECT A.id_carrera, A.galgo_nombre_ix AS galgo_nombre
  FROM datos_desa.tb_dataset_con_ids_${TAG} A 
  RIGHT JOIN datos_desa.tb_dataset_ids_pasado_validation_${TAG} B
  ON (A.id_carrera=B.id_carrera)
) AB
, (SELECT @rowid:=0) R;

ALTER TABLE datos_desa.tb_val_1st_connombre_${TAG} ADD INDEX tb_val_1st_CN_${TAG}_idx(rowid);


DROP TABLE IF EXISTS datos_desa.tb_val_1st_aciertos_connombre_${TAG};

CREATE TABLE datos_desa.tb_val_1st_aciertos_connombre_${TAG} AS
SELECT A.*, B.galgo_nombre
FROM datos_desa.tb_1st_score_aciertos_${TAG} A
LEFT JOIN datos_desa.tb_val_1st_connombre_${TAG} B
ON (A.galgo_rowid=B.rowid);

ALTER TABLE datos_desa.tb_val_1st_aciertos_connombre_${TAG} ADD INDEX tb_val_1st_aciertos_connombre_${TAG}_idx(id_carrera, galgo_nombre);


DROP TABLE IF EXISTS datos_desa.tb_val_1st_riesgo_${TAG};

CREATE TABLE datos_desa.tb_val_1st_riesgo_${TAG} AS
SELECT * 
FROM (
  select 
  A.*, 
  -- RIESGO: cuanta mas diferencia entre el 1º y el 2º, mas efectiva sera la prediccion
  100*(A.target_predicho - B.target_predicho) AS fortaleza
  FROM datos_desa.tb_val_1st_aciertos_connombre_${TAG}  A
  LEFT JOIN datos_desa.tb_val_1st_aciertos_connombre_${TAG} B
  ON (A.id_carrera=B.id_carrera)
  WHERE A.posicion_predicha=1 and B.posicion_predicha=2
) C
ORDER BY fortaleza DESC;

ALTER TABLE datos_desa.tb_val_1st_riesgo_${TAG} ADD INDEX tb_val_1st_riesgo_${TAG}_idx(id_carrera, galgo_nombre);
EOF

echo -e "$CONSULTA_SCORE" 2>&1 1>>${LOG_042}
mysql -t --execute="$CONSULTA_SCORE" 2>&1 1>>${LOG_042}


#FILE_TEMP="./temp_numero_MOD042"
#Numeros: SOLO pongo el dinero en las que el sistema me predice 1st, pero no en las otras predichas.
#mysql -N --execute="SELECT SUM(acierto) as num_aciertos FROM datos_desa.tb_val_1st_riesgo_${TAG} LIMIT 1;" > ${FILE_TEMP}
#numero_aciertos=$(cat ${FILE_TEMP})

#mysql -N --execute="SELECT count(*) as num_predicciones_1st FROM datos_desa.tb_val_1st_riesgo_${TAG} WHERE predicha_1st = true LIMIT 1;" > ${FILE_TEMP}
#numero_predicciones_1st=$(cat ${FILE_TEMP})

#echo -e "MOD042_1st numero_aciertos = ${numero_aciertos}" 2>&1 1>>${LOG_042}
#echo -e "MOD042_1st numero_predicciones_1st = ${numero_predicciones_1st}" 2>&1 1>>${LOG_042}

#SCORE_FINAL=$(echo "scale=2; $numero_aciertos / $numero_predicciones_1st" | bc -l)
#echo -e "MOD042_1st|DS_PASADO_VALIDATION|${TAG}|Sin_filtro_SP|ACIERTOS=${numero_aciertos}|CASOS_1st=${numero_predicciones_1st}|SCORE = ${SCORE_FINAL}" 2>&1 1>>${LOG_042}


echo -e "MOD042_1st Ejemplos de filas PREDICHAS (dataset PASADO_VALIDATION):" 2>&1 1>>${LOG_042}
mysql -t --execute="SELECT id_carrera, galgo_nombre, posicion_real, posicion_predicha, predicha_1st, acierto, fortaleza FROM datos_desa.tb_val_1st_riesgo_${TAG} LIMIT 3;" 2>&1 1>>${LOG_042}


##################### CALCULO ECONÓMICO y salida hacia SCRIPT PADRE ################

#span=0.50
calculoEconomicoPasado "1st" "1" "1.00" "1.50" "SP100150" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "1.50" "2.00" "SP150200" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "2.00" "2.50" "SP200250" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "2.50" "3.00" "SP250300" "${TAG}" "1" "${LOG_042}"
#span=1.00
calculoEconomicoPasado "1st" "1" "1.00" "2.00" "SP100200" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "1.50" "2.50" "SP150250" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "2.00" "3.00" "SP200300" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "2.50" "3.50" "SP250350" "${TAG}" "1" "${LOG_042}"
#span=infinito
calculoEconomicoPasado "1st" "1" "3.00" "999.00" "SP30099900" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "1.00" "999.00" "SP10099900" "${TAG}" "1" "${LOG_042}"
calculoEconomicoPasado "1st" "1" "2.00" "999.00" "SP20099900" "${TAG}" "1" "${LOG_042}"

##############################################################

echo -e $(date +"%T")" | 042_1st | Modelos predictivos: 1st | FIN" >>$LOG_070


