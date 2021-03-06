#!/bin/bash
 
source "/home/carloslinux/git/bdml/mod002parser/scripts/galgos/funciones.sh"

#Borrar log
rm -f "${LOG_014_STATS}"

echo -e $(date +"%T")" | 014 | Estadistica sobre columnas no transformadas | INICIO" >>$LOG_070
echo -e "MOD014 --> LOG = "${LOG_014_STATS}

######################################################################################################
echo -e "-------------- CG Semillas FUTURAS SPORTIUM --------------" >> "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_cg_semillas_sportium" "${LOG_014_STATS}"

######################################################################################################
echo -e "-------------- TABLAS BRUTAS (pasadas + futuras) --------------" >> "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_carreras" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_posiciones_en_carreras" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_historico" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_galgos_agregados" "${LOG_014_STATS}"


#echo -e "Exportando BRUTOS a ficheros external..." >> "${LOG_014_STATS}"
#exportarTablaAFichero "datos_desa" "tb_galgos_carreras" "${PATH_MYSQL_PRIV_SECURE}014_bruto_carreras.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_bruto_carreras.txt"
#exportarTablaAFichero "datos_desa" "tb_galgos_posiciones_en_carreras" "${PATH_MYSQL_PRIV_SECURE}014_bruto_pec.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_bruto_pec.txt"
#exportarTablaAFichero "datos_desa" "tb_galgos_historico" "${PATH_MYSQL_PRIV_SECURE}014_bruto_gh.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_bruto_gh.txt"
#exportarTablaAFichero "datos_desa" "tb_galgos_agregados" "${PATH_MYSQL_PRIV_SECURE}014_bruto_ga.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_bruto_ga.txt"

#####################################################################################################
echo -e "-------------- TABLAS con columnas no transformadas --------------" >> "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_elaborada_carreras" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_elaborada_galgos" "${LOG_014_STATS}"
analizarTabla "datos_desa" "tb_elaborada_carrerasgalgos" "${LOG_014_STATS}"


stats_completitud=$(cat "${LOG_014_STATS}" | grep '_velocidad_con_going')
echo -e "\nMETRICA de COMPLETITUD de los datos historicos --> (tabla datos_desa.tb_elaborada_carrerasgalgos, campo _velocidad_con_going ): ${stats_completitud}\n" >>$LOG_070
echo -e "MAX|MIN|AVG|STD|NO_NULOS|NULOS --> El ratio NULOS/No_nulos debe ser bajo.\n" >>$LOG_070

#echo -e "Exportando ELABORADOS (limpios) a ficheros external..." >> "${LOG_014_STATS}"
#exportarTablaAFichero "datos_desa" "tb_elaborada_carreras" "${PATH_MYSQL_PRIV_SECURE}014_elab_c.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_elab_c.txt"
#exportarTablaAFichero "datos_desa" "tb_elaborada_galgos" "${PATH_MYSQL_PRIV_SECURE}014_elab_g.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_elab_g.txt"
#exportarTablaAFichero "datos_desa" "tb_elaborada_carrerasgalgos" "${PATH_MYSQL_PRIV_SECURE}014_elab_cg.txt" "${LOG_014_STATS}" "${EXTERNAL_014}014_elab_cg.txt"

#####################################################################################################
echo -e "Analizando con KNIME..." >> "${LOG_014_STATS}"

#Borrar graficos previos
rm -Rf '/home/carloslinux/Desktop/LOGS/014_graficos/'
mkdir '/home/carloslinux/Desktop/LOGS/014_graficos/'

PATH_KNIME_WFLOW="/root/knime-workspace/workflow_galgos/"
#sudo "/home/carloslinux/Desktop/PROGRAMAS/knime/knime" -batch -reset -workflowFile="${PATH_KNIME_WFLOW}galgos_014_analisis" &
#sudo "/home/carloslinux/Desktop/PROGRAMAS/knime/knime" -consoleLog -nosplash -noexit -application org.knime.product.KNIME_BATCH_APPLICATION -workflowFile="${PATH_KNIME_WFLOW}galgos_014_analisis"  > "/home/carloslinux/Desktop/LOGS/014_knime_log.txt"



#####################################################################################################


echo -e $(date +"%T")" | 014 | Estadistica sobre columnas no transformadas | FIn" >>$LOG_070



