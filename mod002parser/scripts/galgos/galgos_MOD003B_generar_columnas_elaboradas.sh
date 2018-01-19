#!/bin/bash

source "/root/git/bdml/mod002parser/scripts/galgos/funciones.sh"

echo -e "Los galgos SEMILLAS deberian tener el SP (STARTING PRICE) si lo conocemos en el instante de la descarga" 2>&1 1>>${LOG_CE}


##########################################################################################
function calcularVariableX1 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X1: [(galgo) -> velocidad_max_going]" 2>&1 1>>${LOG_CE}

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x1a;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}x1a AS SELECT 1 AS distancia_tipo, MIN(vel_going_cortas_max) AS valor_min, MAX(vel_going_cortas_max) AS valor_max FROM datos_desa.tb_galgos_agregados UNION SELECT 2 AS distancia_tipo, MIN(vel_going_longmedias_max) AS valor_min, MAX(vel_going_longmedias_max) AS valor_max FROM datos_desa.tb_galgos_agregados UNION SELECT 3 AS distancia_tipo, MIN(vel_going_largas_max) AS valor_min, MAX(vel_going_largas_max) AS valor_max FROM datos_desa.tb_galgos_agregados ;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}x1a LIMIT 5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x1a FROM datos_desa.tb_ce_${sufijo}x1a LIMIT 5;" >>$LOG_CE

read -d '' CONSULTA_X1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x1b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x1b AS SELECT galgo_nombre, 

(vel_going_cortas_max - (select valor_min FROM datos_desa.tb_ce_${sufijo}x1a WHERE distancia_tipo=1) ) / (select valor_max FROM datos_desa.tb_ce_${sufijo}x1a WHERE distancia_tipo=1) AS vgcortas_max_norm, 

(vel_going_longmedias_max - (select valor_min FROM datos_desa.tb_ce_${sufijo}x1a WHERE distancia_tipo=2) ) / (select valor_max FROM datos_desa.tb_ce_${sufijo}x1a WHERE distancia_tipo=2) AS vgmedias_max_norm, 

(vel_going_largas_max - (select valor_min FROM datos_desa.tb_ce_${sufijo}x1a WHERE distancia_tipo=3) ) / (select valor_max FROM datos_desa.tb_ce_${sufijo}x1a WHERE distancia_tipo=3) AS vglargas_max_norm 

FROM datos_desa.tb_galgos_agregados;

SELECT * FROM datos_desa.tb_ce_${sufijo}x1b LIMIT 5;

SELECT count(*) as num_x1b FROM datos_desa.tb_ce_${sufijo}x1b LIMIT 5;
EOF

#echo -e "$CONSULTA_X1" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X1" >>$LOG_CE
}

##########################################################################################
function calcularVariableX2 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X2: [(carrera, galgo) ->experiencia]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x2a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x2a AS
SELECT id_carrera, galgo_nombre, anio,mes,dia,
CASE galgo_nombre 
  WHEN @curGalgoNombre THEN @curRow := @curRow + 1 
  ELSE (@curRow := 1 AND @curGalgoNombre := galgo_nombre )
END AS experiencia
FROM datos_desa.tb_galgos_historico GH,
(SELECT @curRow := 0, @curGalgoNombre := '') R
ORDER BY galgo_nombre ASC, anio ASC, mes ASC, dia ASC;

SELECT * FROM datos_desa.tb_ce_${sufijo}x2a LIMIT 5;

SELECT count(*) as num_x2a FROM datos_desa.tb_ce_${sufijo}x2a LIMIT 5;


set @min_experiencia=(select MIN(experiencia) FROM datos_desa.tb_ce_${sufijo}x2a);
set @max_experiencia=(select MAX(experiencia) FROM datos_desa.tb_ce_${sufijo}x2a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x2b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x2b AS 
SELECT id_carrera, galgo_nombre, anio, mes, dia, 
(experiencia - @min_experiencia)/(@max_experiencia - @min_experiencia) AS experiencia
FROM datos_desa.tb_ce_${sufijo}x2a;

SELECT * FROM datos_desa.tb_ce_${sufijo}x2b LIMIT 5;

SELECT count(*) as num_x2b FROM datos_desa.tb_ce_${sufijo}x2b LIMIT 5;
EOF

#echo -e "$CONSULTA_X2" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X2" >>$LOG_CE

}

##########################################################################################
function calcularVariableX3 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X3: [(carrera, galgo) -> (TRAP, trap_factor)]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x3a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x3a AS 
SELECT dentro.trap, SUM(dentro.contador) AS trap_suma 
FROM (select trap,posicion,count(*) as contador FROM datos_desa.tb_galgos_historico GROUP BY trap,posicion ORDER BY trap ASC, posicion ASC) dentro 
WHERE posicion IN (1,2) 
GROUP BY dentro.trap;

SELECT * FROM datos_desa.tb_ce_${sufijo}x3a LIMIT 5;

SELECT count(*) as num_x3a FROM datos_desa.tb_ce_${sufijo}x3a LIMIT 5;


set @min_trap_puntos=(select MIN(trap_suma) FROM datos_desa.tb_ce_${sufijo}x3a);
set @max_trap_puntos=(select MAX(trap_suma) FROM datos_desa.tb_ce_${sufijo}x3a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x3b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x3b AS 
SELECT trap, 
(trap_suma - @min_trap_puntos)/(@max_trap_puntos - @min_trap_puntos) AS trap_factor
FROM datos_desa.tb_ce_${sufijo}x3a;

SELECT * FROM datos_desa.tb_ce_${sufijo}x3b LIMIT 5;

SELECT count(*) as num_x3b FROM datos_desa.tb_ce_${sufijo}x3b LIMIT 5;
EOF

#echo -e "$CONSULTA_X3" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X3" >>$LOG_CE

}

##########################################################################################
function calcularVariableX4 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X4: [(carrera, galgo) -> (starting price)]" 2>&1 1>>${LOG_CE}

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x4;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}x4 AS SELECT id_carrera, galgo_nombre, sp FROM datos_desa.tb_galgos_historico GH;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}x4 LIMIT 5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x4 FROM datos_desa.tb_ce_${sufijo}x4 LIMIT 5;" >>$LOG_CE
}

##########################################################################################
function calcularVariableX5 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X5: [(carrera, galgo) -> (clase)]" 2>&1 1>>${LOG_CE}

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}x5 AS SELECT id_carrera, galgo_nombre, clase FROM datos_desa.tb_galgos_historico GH;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}x5 LIMIT 5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x5 FROM datos_desa.tb_ce_${sufijo}x5 LIMIT 5;" >>$LOG_CE
}

##########################################################################################
function calcularVariableX6 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X6 - POSICION media por experiencia en una clase. Un perro que corre en una carrera tiene X experiencia corriendo en esa clase. Asignamos la posición media que le correspondería tener a ese perro por tener esa experiencia X en esa clase. Agrupamos por rangos de experiencia (baja, media, alta) en función de unos umbrales calculados empiricamente." 2>&1 1>>${LOG_CE}

echo -e "X6: [(carrera, galgo) -> (posicion_media según su experiencia en esa clase)]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X6 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x6a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x6a AS 
SELECT galgo_nombre, clase, COUNT(posicion) AS experiencia_en_clase, AVG(posicion) AS posicion_media_en_clase 
FROM datos_desa.tb_galgos_historico 
GROUP BY galgo_nombre,clase;

SELECT * FROM datos_desa.tb_ce_${sufijo}x6a LIMIT 5;
SELECT count(*) as num_x6a FROM datos_desa.tb_ce_${sufijo}x6a LIMIT 5;


set @min_experiencia_en_clase=(select MIN(experiencia_en_clase) FROM datos_desa.tb_ce_${sufijo}x6a);
set @max_experiencia_en_clase=(select MAX(experiencia_en_clase) FROM datos_desa.tb_ce_${sufijo}x6a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x6b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x6b AS 
SELECT clase, 
CASE WHEN experiencia_en_clase>=13 THEN 'alta' 
     WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media' 
     ELSE 'baja' 
END AS experiencia_cualitativo, 
AVG(posicion_media_en_clase) AS posicion_media_en_clase_por_experiencia 
FROM datos_desa.tb_ce_${sufijo}x6a 
GROUP BY clase, experiencia_cualitativo 
ORDER BY clase ASC, experiencia_cualitativo ASC;

SELECT * FROM datos_desa.tb_ce_${sufijo}x6b LIMIT 5;
SELECT count(*) as num_x6b FROM datos_desa.tb_ce_${sufijo}x6b LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x6c;

CREATE TABLE datos_desa.tb_ce_${sufijo}x6c AS
SELECT galgo_nombre, clase, id_carrera, count(*) AS experiencia_en_clase 
  FROM (
    SELECT galgo_nombre,clase, amd, amd2, id_carrera  
    FROM (
      SELECT GH.galgo_nombre, GH.id_carrera, GH.anio*10000+GH.mes*100+GH.dia AS amd, GH2.anio*10000+GH2.mes*100+GH2.dia AS amd2, GH.clase AS clase
      FROM datos_desa.tb_galgos_historico GH 
      LEFT JOIN datos_desa.tb_galgos_historico GH2 ON (GH.galgo_nombre=GH2.galgo_nombre AND GH.clase=GH2.clase)
    ) dentro
    WHERE dentro.amd >= dentro.amd2
  ) fuera
GROUP BY galgo_nombre, clase, id_carrera;

SELECT * FROM datos_desa.tb_ce_${sufijo}x6c LIMIT 5;
SELECT count(*) as num_x6c FROM datos_desa.tb_ce_${sufijo}x6c LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x6d;

CREATE TABLE datos_desa.tb_ce_${sufijo}x6d AS 
SELECT clase, 
MAX(experiencia_en_clase) AS experiencia_en_clase,
galgo_nombre,id_carrera
FROM datos_desa.tb_ce_${sufijo}x6c
GROUP BY galgo_nombre, clase, id_carrera;

SELECT * FROM datos_desa.tb_ce_${sufijo}x6d LIMIT 5;
SELECT count(*) as num_x6d FROM datos_desa.tb_ce_${sufijo}x6d LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x6e;

CREATE TABLE datos_desa.tb_ce_${sufijo}x6e AS 
SELECT  cruce1.clase, 
 
cruce1.experiencia_cualitativo,
(X6A.experiencia_en_clase - @min_experiencia_en_clase)/(@max_experiencia_en_clase - @min_experiencia_en_clase) AS experiencia_en_clase, 
X6B.posicion_media_en_clase_por_experiencia,

anio, mes, dia, 
cruce1.id_carrera, cruce1.galgo_nombre

FROM(
  SELECT GH.anio, GH.mes, GH.dia, GH.id_carrera, GH.galgo_nombre, GH.clase,  
  experiencia_en_clase,
  CASE WHEN experiencia_en_clase>=13 THEN 'alta' 
     WHEN (experiencia_en_clase>=5 AND experiencia_en_clase<13) THEN 'media'
     ELSE 'baja' 
  END AS experiencia_cualitativo

  FROM datos_desa.tb_galgos_historico GH 
  LEFT JOIN datos_desa.tb_ce_${sufijo}x6d X6D ON (GH.id_carrera=X6D.id_carrera AND GH.galgo_nombre=X6D.galgo_nombre)
) cruce1
LEFT JOIN datos_desa.tb_ce_${sufijo}x6a X6A ON (cruce1.galgo_nombre=X6A.galgo_nombre)
LEFT JOIN datos_desa.tb_ce_${sufijo}x6b X6B ON (cruce1.clase=X6B.clase AND cruce1.experiencia_cualitativo=X6B.experiencia_cualitativo)
;

SELECT * FROM datos_desa.tb_ce_${sufijo}x6e LIMIT 5;
SELECT count(*) as num_x6e FROM datos_desa.tb_ce_${sufijo}x6e LIMIT 5;
EOF

#echo -e "$CONSULTA_X6" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X6" >>$LOG_CE
}

##########################################################################################
function calcularVariableX7 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X7: peso del galgo en relacion al peso medio de los galgos que corren en esa distancia (centenas de metros). Toma valores NULL cuando no hemos descargado las filas de la tabla de posiciones en carrera (que es la que tiene el peso de cada galgo)." 2>&1 1>>${LOG_CE}

echo -e "X7: [(carrera, galgo) -> (diferencia respecto al peso medio en esa distancia_centenas)]" 2>&1 1>>${LOG_CE}

mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x7a;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}x7a AS SELECT PO.id_carrera, PO.posicion, PO.peso_galgo, GH.distancia, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas FROM datos_desa.tb_galgos_posiciones_en_carreras PO LEFT JOIN (select id_carrera, MAX(distancia) AS distancia FROM datos_desa.tb_galgos_historico GROUP BY id_carrera) GH ON PO.id_carrera=GH.id_carrera WHERE PO.posicion IN (1,2) ORDER BY PO.id_carrera ASC, PO.posicion ASC;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}x7a LIMIT 5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x7a FROM datos_desa.tb_ce_${sufijo}x7a LIMIT 5;" >>$LOG_CE


mysql -u root --password=datos1986 --execute="DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x7b;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="CREATE TABLE datos_desa.tb_ce_${sufijo}x7b AS SELECT distancia_centenas, AVG(peso_galgo) AS peso_medio, COUNT(*) FROM datos_desa.tb_ce_${sufijo}x7a GROUP BY distancia_centenas ORDER BY distancia_centenas ASC;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT * FROM datos_desa.tb_ce_${sufijo}x7b LIMIT 5;" >>$LOG_CE
mysql -u root --password=datos1986 --execute="SELECT count(*) as num_x7b FROM datos_desa.tb_ce_${sufijo}x7b LIMIT 5;" >>$LOG_CE

read -d '' CONSULTA_X7C <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x7c;

CREATE TABLE datos_desa.tb_ce_${sufijo}x7c AS 
SELECT id_carrera, galgo_nombre, dentro.distancia_centenas, dentro.distancia, ABS(dentro.peso_galgo - X7B.peso_medio) AS dif_peso  
FROM
(
  select GH.galgo_nombre, GH.id_carrera, (GH.distancia/100 - GH.distancia%100/100) AS distancia_centenas, GH.distancia, PO.peso_galgo 
  FROM datos_desa.tb_galgos_historico GH
  LEFT JOIN (SELECT galgo_nombre, MAX(peso_galgo) AS peso_galgo FROM datos_desa.tb_galgos_posiciones_en_carreras GROUP BY galgo_nombre) PO
  ON (GH.galgo_nombre=PO.galgo_nombre)
) dentro
LEFT JOIN datos_desa.tb_ce_${sufijo}x7b X7B 
ON (dentro.distancia_centenas=X7B.distancia_centenas)
ORDER BY id_carrera, galgo_nombre;

SELECT * FROM datos_desa.tb_ce_${sufijo}x7c LIMIT 5;
SELECT count(*) as num_x7c FROM datos_desa.tb_ce_${sufijo}x7c LIMIT 5;


set @min_dif_peso=(select MIN(dif_peso) FROM datos_desa.tb_ce_${sufijo}x7c);
set @max_dif_peso=(select MAX(dif_peso) FROM datos_desa.tb_ce_${sufijo}x7c);

DROP TABLE datos_desa.tb_ce_${sufijo}x7d;

CREATE TABLE datos_desa.tb_ce_${sufijo}x7d AS 
SELECT id_carrera, galgo_nombre, distancia_centenas, distancia,
(dif_peso - @min_dif_peso)/(@max_dif_peso - @min_dif_peso) AS dif_peso
FROM datos_desa.tb_ce_${sufijo}x7c;

SELECT * FROM datos_desa.tb_ce_${sufijo}x7d LIMIT 5;

SELECT count(*) as num_x3b FROM datos_desa.tb_ce_${sufijo}x7d LIMIT 5;
EOF

#echo -e "$CONSULTA_X7C" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X7C" >>$LOG_CE
}

##########################################################################################
function calcularVariableX8 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X8: [carrera -> (going_avg, going_std)]. \nIndica si el estadio tiene mucha correccion (going allowance), normalmente debido al viento, lluvia, etc." 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X8 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x8a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x8a AS 
SELECT track, STD(going_abs) AS venue_going_std, AVG(going_abs) AS venue_going_avg 
FROM (select track, ABS(going_allowance_segundos) AS going_abs FROM datos_desa.tb_galgos_carreras) dentro 
GROUP BY dentro.track
;
SELECT * FROM datos_desa.tb_ce_${sufijo}x8a LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_${sufijo}x8a LIMIT 5;

set @min_vgs=(select MIN(venue_going_std) FROM datos_desa.tb_ce_${sufijo}x8a);
set @max_vgs=(select MAX(venue_going_std) FROM datos_desa.tb_ce_${sufijo}x8a);
set @min_vga=(select MIN(venue_going_avg) FROM datos_desa.tb_ce_${sufijo}x8a);
set @max_vga=(select MAX(venue_going_avg) FROM datos_desa.tb_ce_${sufijo}x8a);

DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x8b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x8b AS 
SELECT track,
(venue_going_std - @min_vgs)/(@max_vgs - @min_vgs) AS venue_going_std,
(venue_going_avg - @min_vga)/(@max_vga - @min_vga) AS venue_going_avg
 FROM datos_desa.tb_ce_${sufijo}x8a
;
SELECT * FROM datos_desa.tb_ce_${sufijo}x8b LIMIT 5;
SELECT count(*) as num_x8a FROM datos_desa.tb_ce_${sufijo}x8b LIMIT 5;
EOF

#echo -e "$CONSULTA_X8" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X8" >>$LOG_CE
}

##########################################################################################
function calcularVariableX9 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X9: [entrenador -> puntos]. Calidad del ENTRENADOR" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X9 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x9a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x9a AS 
SELECT entrenador, AVG(posicion) AS posicion_avg, STD(posicion) AS posicion_std 
FROM datos_desa.tb_galgos_historico 
GROUP BY entrenador;

SELECT * FROM datos_desa.tb_ce_${sufijo}x9a LIMIT 5;
SELECT count(*) as num_x9a FROM datos_desa.tb_ce_${sufijo}x9a LIMIT 5;


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x9b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x9b AS 
SELECT entrenador, (6-posicion_avg)/5 AS entrenador_posicion_norm FROM datos_desa.tb_ce_${sufijo}x9a;

SELECT * FROM datos_desa.tb_ce_${sufijo}x9b LIMIT 5;
SELECT count(*) as num_x9b FROM datos_desa.tb_ce_${sufijo}x9b LIMIT 5;
EOF

#echo -e "$CONSULTA_X9" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X9" >>$LOG_CE
}

##########################################################################################
function calcularVariableX10 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X10: [(carrera, galgo) -> (edad_en_dias)]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X10 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x10a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x10a AS 
SELECT id_carrera, galgo_nombre, edad_en_dias
FROM datos_desa.tb_galgos_posiciones_en_carreras;

SELECT * FROM datos_desa.tb_ce_${sufijo}x10a LIMIT 5;
SELECT count(*) as num_x10a FROM datos_desa.tb_ce_${sufijo}x10a LIMIT 5;

set @min_eed=(select MIN(edad_en_dias) FROM datos_desa.tb_ce_${sufijo}x10a);
set @max_eed=(select MAX(edad_en_dias) FROM datos_desa.tb_ce_${sufijo}x10a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x10b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x10b AS 
SELECT id_carrera, galgo_nombre,
(edad_en_dias - @min_eed)/(@max_eed - @min_eed) AS eed_norm
FROM datos_desa.tb_ce_${sufijo}x10a;

SELECT * FROM datos_desa.tb_ce_${sufijo}x10b LIMIT 5;
SELECT count(*) as num_x10b FROM datos_desa.tb_ce_${sufijo}x10b LIMIT 5;
EOF

#echo -e "$CONSULTA_X10" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X10" >>$LOG_CE
}

##########################################################################################
function calcularVariableX11 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X11: [(galgo) -> (agregados normalizados del galgo)]" 2>&1 1>>${LOG_CE}

#vel_real_cortas_mediana | vel_real_cortas_max | vel_going_cortas_mediana | vel_going_cortas_max | 
#vel_real_longmedias_mediana | vel_real_longmedias_max | vel_going_longmedias_mediana | vel_going_longmedias_max | 
#vel_real_largas_mediana | vel_real_largas_max | vel_going_largas_mediana | vel_going_largas_max

read -d '' CONSULTA_X11 <<- EOF
set @min_vrc_med=(select MIN(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vrc_med=(select MAX(vel_real_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vrc_max=(select MIN(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vrc_max=(select MAX(vel_real_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @min_vgc_med=(select MIN(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vgc_med=(select MAX(vel_going_cortas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vgc_max=(select MIN(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vgc_max=(select MAX(vel_going_cortas_max) FROM datos_desa.tb_galgos_agregados);

set @min_vrlm_med=(select MIN(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vrlm_med=(select MAX(vel_real_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vrlm_max=(select MIN(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @max_vrlm_max=(select MAX(vel_real_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @min_vglm_med=(select MIN(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vglm_med=(select MAX(vel_going_longmedias_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vglm_max=(select MIN(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados);
set @max_vglm_max=(select MAX(vel_going_longmedias_max) FROM datos_desa.tb_galgos_agregados);

set @min_vrl_med=(select MIN(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vrl_med=(select MAX(vel_real_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vrl_max=(select MIN(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vrl_max=(select MAX(vel_real_largas_max) FROM datos_desa.tb_galgos_agregados);
set @min_vgl_med=(select MIN(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @max_vgl_med=(select MAX(vel_going_largas_mediana) FROM datos_desa.tb_galgos_agregados);
set @min_vgl_max=(select MIN(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados);
set @max_vgl_max=(select MAX(vel_going_largas_max) FROM datos_desa.tb_galgos_agregados);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x11;

CREATE TABLE datos_desa.tb_ce_${sufijo}x11 AS 
SELECT galgo_nombre, 

vel_real_cortas_mediana,
(vel_real_cortas_mediana - @min_vrc_med)/(@max_vrc_med - @min_vrc_med) AS vel_real_cortas_mediana_norm,
vel_real_cortas_max,
(vel_real_cortas_max - @min_vrc_max)/(@max_vrc_max - @min_vrc_max) AS vel_real_cortas_max_norm,
vel_going_cortas_mediana,
(vel_going_cortas_mediana - @min_vgc_med)/(@max_vgc_med - @min_vgc_med) AS vel_going_cortas_mediana_norm,
vel_going_cortas_max,
(vel_going_cortas_max - @min_vgc_max)/(@max_vgc_max - @min_vgc_max) AS vel_going_cortas_max_norm,

vel_real_longmedias_mediana,
(vel_real_longmedias_mediana - @min_vrlm_med)/(@max_vrlm_med - @min_vrlm_med) AS vel_real_longmedias_mediana_norm,
vel_real_longmedias_max,
(vel_real_longmedias_max - @min_vrlm_max)/(@max_vrlm_max - @min_vrlm_max) AS vel_real_longmedias_max_norm,
vel_going_longmedias_mediana,
(vel_going_longmedias_mediana - @min_vglm_med)/(@max_vglm_med - @min_vglm_med) AS vel_going_longmedias_mediana_norm,
vel_going_longmedias_max,
(vel_going_longmedias_max - @min_vglm_max)/(@max_vglm_max - @min_vglm_max) AS vel_going_longmedias_max_norm,

vel_real_largas_mediana,
(vel_real_largas_mediana - @min_vrl_med)/(@max_vrl_med - @min_vrl_med) AS vel_real_largas_mediana_norm,
vel_real_largas_max,
(vel_real_largas_max - @min_vrl_max)/(@max_vrl_max - @min_vrl_max) AS vel_real_largas_max_norm,
vel_going_largas_mediana,
(vel_going_largas_mediana - @min_vgl_med)/(@max_vgl_med - @min_vgl_med) AS vel_going_largas_mediana_norm,
vel_going_largas_max,
(vel_going_largas_max - @min_vgl_max)/(@max_vgl_max - @min_vgl_max) AS vel_going_largas_max_norm

FROM datos_desa.tb_galgos_agregados;

SELECT * FROM datos_desa.tb_ce_${sufijo}x11 LIMIT 5;
SELECT count(*) as num_x11 FROM datos_desa.tb_ce_${sufijo}x11 LIMIT 5;
EOF

#echo -e "$CONSULTA_X11" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X11" >>$LOG_CE
}

##########################################################################################
function calcularVariableX12 ()
{
filtro_galgos="${1}"
sufijo="${2}"
echo -e "\n---- X12: [ carrera -> (propiedades normalizadas de la carrera)]" 2>&1 1>>${LOG_CE}

echo -e "PENDIENTE Leer el track (pista) y sacar las caracteristicas de su ubicacion fisica (norte, sur, cerca del mar, altitud, numero de espectadores presenciales, tamaño de la pista...)" 2>&1 1>>${LOG_CE}

echo -e "PENDIENTE Leer la clase (tipo de competición) y crear categorias (boolean): tipo A, OR, S... --> SELECT DISTINCT clase FROM datos_desa.tb_galgos_carreras LIMIT 100;" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_X12 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x12a;

CREATE TABLE datos_desa.tb_ce_${sufijo}x12a AS 
SELECT
id_carrera,
CASE WHEN (mes <=7) THEN (-1/6 + mes/6) WHEN (mes >7) THEN (5/12 - 5*mes/144) ELSE 0.5 END AS mes,
hora,
num_galgos,
premio_primero, premio_segundo, premio_otros, premio_total_carrera,
going_allowance_segundos,
fc_1, fc_2, fc_pounds, tc_1, tc_2, tc_3, tc_pounds
FROM datos_desa.tb_galgos_carreras;

SELECT * FROM datos_desa.tb_ce_${sufijo}x12a LIMIT 5;
SELECT count(*) as num_x12a FROM datos_desa.tb_ce_${sufijo}x12a LIMIT 5;


set @min_hora=(select MIN(hora) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_hora=(select MAX(hora) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_num_galgos=(select MIN(num_galgos) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_num_galgos=(select MAX(num_galgos) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_premio_primero=(select MIN(premio_primero) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_premio_primero=(select MAX(premio_primero) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_premio_segundo=(select MIN(premio_segundo) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_premio_segundo=(select MAX(premio_segundo) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_premio_otros=(select MIN(premio_otros) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_premio_otros=(select MAX(premio_otros) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_premio_total_carrera=(select MIN(premio_total_carrera) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_premio_total_carrera=(select MAX(premio_total_carrera) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_going_allowance_segundos=(select MIN(going_allowance_segundos) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_going_allowance_segundos=(select MAX(going_allowance_segundos) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_fc_1=(select MIN(fc_1) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_fc_1=(select MAX(fc_1) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_fc_2=(select MIN(fc_2) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_fc_2=(select MAX(fc_2) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_fc_pounds=(select MIN(fc_pounds) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_fc_pounds=(select MAX(fc_pounds) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_tc_1=(select MIN(tc_1) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_tc_1=(select MAX(tc_1) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_tc_2=(select MIN(tc_2) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_tc_2=(select MAX(tc_2) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_tc_3=(select MIN(tc_3) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_tc_3=(select MAX(tc_3) FROM datos_desa.tb_ce_${sufijo}x12a);
set @min_tc_pounds=(select MIN(tc_pounds) FROM datos_desa.tb_ce_${sufijo}x12a);
set @max_tc_pounds=(select MAX(tc_pounds) FROM datos_desa.tb_ce_${sufijo}x12a);


DROP TABLE IF EXISTS datos_desa.tb_ce_${sufijo}x12b;

CREATE TABLE datos_desa.tb_ce_${sufijo}x12b AS 
SELECT 
id_carrera,
mes,
(hora - @min_hora)/(@max_hora - @min_hora) AS hora_norm,
(num_galgos - @min_num_galgos)/(@max_num_galgos - @min_num_galgos) AS num_galgos_norm,
(premio_primero - @min_premio_primero)/(@max_premio_primero - @min_premio_primero) AS premio_primero_norm,
(premio_segundo - @min_premio_segundo)/(@max_premio_segundo - @min_premio_segundo) AS premio_segundo_norm,
(premio_otros - @min_premio_otros)/(@max_premio_otros - @min_premio_otros) AS premio_otros_norm,
(premio_total_carrera - @min_premio_total_carrera)/(@max_premio_total_carrera - @min_premio_total_carrera) AS premio_total_carrera_norm,
(going_allowance_segundos - @min_going_allowance_segundos)/(@max_going_allowance_segundos - @min_going_allowance_segundos) AS going_allowance_segundos_norm,
(fc_1 - @min_fc_1)/(@max_fc_1 - @min_fc_1) AS fc_1_norm,
(fc_2 - @min_fc_2)/(@max_fc_2 - @min_fc_2) AS fc_2_norm,
(fc_pounds - @min_fc_pounds)/(@max_fc_pounds - @min_fc_pounds) AS fc_pounds_norm,
(tc_1 - @min_tc_1)/(@max_tc_1 - @min_tc_1) AS tc_1_norm,
(tc_2 - @min_tc_2)/(@max_tc_2 - @min_tc_2) AS tc_2_norm,
(tc_3 - @min_tc_3)/(@max_tc_3 - @min_tc_3) AS tc_3_norm,
(tc_pounds - @min_tc_pounds)/(@max_tc_pounds - @min_tc_pounds) AS X_norm
FROM datos_desa.tb_ce_${sufijo}x12a;

SELECT * FROM datos_desa.tb_ce_${sufijo}x12b LIMIT 5;
SELECT count(*) as num_x12b FROM datos_desa.tb_ce_${sufijo}x12b LIMIT 5;
EOF

#echo -e "$CONSULTA_X12" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_X12" >>$LOG_CE
}


################ TABLAS PREPARADAS (con columnas elaboradas) ####################################################################################
function generarTablasElaboradas ()
{
echo -e "\n\n---- TABLA ELABORADA 1: [ carrera -> columnas ]" 2>&1 1>>${LOG_CE}

read -d '' CONSULTA_ELAB1 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carreras;

CREATE TABLE datos_desa.tb_elaborada_carreras AS 
SELECT 

















;

SELECT * FROM datos_desa.tb_elaborada_carreras LIMIT 5;
SELECT count(*) as num_elab_carreras FROM datos_desa.tb_elaborada_carreras LIMIT 5;
EOF

#echo -e "$CONSULTA_ELAB1" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_ELAB1" >>$LOG_CE


echo -e "\n\n---- TABLA ELABORADA 2: [ galgo -> columnas ]" 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_ELAB2 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_galgos;

CREATE TABLE datos_desa.tb_elaborada_galgos AS 
SELECT ;

SELECT * FROM datos_desa.tb_elaborada_galgos LIMIT 5;
SELECT count(*) as num_elab_galgos FROM datos_desa.tb_elaborada_galgos LIMIT 5;
EOF

#echo -e "$CONSULTA_ELAB2" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_ELAB2" >>$LOG_CE


echo -e "\n\n---- TABLA ELABORADA 3: [ carrera+galgo -> columnas ]" 2>&1 1>>${LOG_CE}
read -d '' CONSULTA_ELAB3 <<- EOF
DROP TABLE IF EXISTS datos_desa.tb_elaborada_carrerasgalgos;

CREATE TABLE datos_desa.tb_elaborada_carrerasgalgos AS 
SELECT ;

SELECT * FROM datos_desa.tb_elaborada_carrerasgalgos LIMIT 5;
SELECT count(*) as num_elab_cg FROM datos_desa.tb_elaborada_carrerasgalgos LIMIT 5;
EOF

#echo -e "$CONSULTA_ELAB3" 2>&1 >&1
mysql -u root --password=datos1986 --execute="$CONSULTA_ELAB3" >>$LOG_CE

}



################################################ MAIN ###########################################################################################

#filtro_galgos=""
#filtro_galgos="WHERE galgo_nombre IN (${filtro_galgos_nombres})"
filtro_galgos="${1}"

#sufijo="_pre"
#sufijo="_post"
sufijo="${2}"

#### Limpiar LOG ###
rm -f $LOG_CE

echo -e "Generador de COLUMNAS ELABORADAS: INICIO" 2>&1 1>>${LOG_CE}

echo -e "\n---- Variables: X1, X2..." 2>&1 1>>${LOG_CE}
calcularVariableX1 ${filtro_galgos} ${sufijo}
calcularVariableX2 ${filtro_galgos} ${sufijo}
calcularVariableX3 ${filtro_galgos} ${sufijo}
calcularVariableX4 ${filtro_galgos} ${sufijo}
calcularVariableX5 ${filtro_galgos} ${sufijo}
calcularVariableX6 ${filtro_galgos} ${sufijo}
calcularVariableX7 ${filtro_galgos} ${sufijo}
calcularVariableX8 ${filtro_galgos} ${sufijo}
calcularVariableX9 ${filtro_galgos} ${sufijo}
calcularVariableX10 ${filtro_galgos} ${sufijo}
calcularVariableX11 ${filtro_galgos} ${sufijo}
calcularVariableX12 ${filtro_galgos} ${sufijo}

echo -e "\n---- Tablas finales con COLUMNAS ELABORADAS (se usarán para crear datasets)..." 2>&1 1>>${LOG_CE}
generarTablasElaboradas

echo -e "Generador de COLUMNAS ELABORADAS: FIN\n\n" 2>&1 1>>${LOG_CE}





