/**
 * 
 */
package casa.mod002a.bolsamadrid;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

/**
 * @author can0000b
 *
 */
public class BM02Parser extends ParserDeDia {

	public BM02Parser() {
		super();
	}

	@Override
	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.BM + "02";
	}

	/**
	 * @param TAG_DIA
	 */
	@Override
	public void ejecutar(String TAG_DIA) {

		MY_LOGGER.info("Parser: INICIO");

		String bruto = "";
		String out = "";

		try {

			for (int i = 1; i <= 7; i++) {

				String pathEntrada = Constantes.PATH_DIR_DATOS_BRUTOS_BOLSA + getPathEntrada(TAG_DIA) + "_0" + i;
				bruto = readFile(pathEntrada, Charset.forName("ISO-8859-1"));

				// ACUMULAR DATOS
				out += parsear(TAG_DIA, bruto);
			}

			String pathSalida = Constantes.PATH_DIR_DATOS_LIMPIOS_BOLSA + getPathEntrada(TAG_DIA) + Constantes.OUT;

			MY_LOGGER.info("Escribiendo hacia " + pathSalida + " ...");
			Files.write(Paths.get(pathSalida), out.getBytes());

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("Parser: FIN");

	}

	@Override
	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");

		Document doc = Jsoup.parse(in);

		Node tablaBM02ConCabecera = doc.getElementsByClass("TblPort").get(0).childNode(1);

		String out = parsearTablaBM(tagDia, tablaBM02ConCabecera);

		return out;
	}

	/**
	 * @param tagDia
	 * @param tablaBM02ConCabecera
	 * @return
	 */
	public String parsearTablaBM(String tagDia, Node tablaBM02ConCabecera) {

		String out = "";

		// Nombre|Sector-Subsector|Mercado|Índices
		Node cabecera = tablaBM02ConCabecera.childNode(0);

		int numFilas = tablaBM02ConCabecera.childNodes().size();
		for (int i = 1; i < numFilas; i++) {

			if (tablaBM02ConCabecera.childNode(i) instanceof Element) {

				Node isin_nombre = tablaBM02ConCabecera.childNode(i).childNode(1).childNode(0);
				String a = isin_nombre.attr("href");
				String isin = a.substring(a.indexOf("ISIN=") + 5, a.length());
				String nombre = isin_nombre.childNode(0).toString().substring(0,
						Math.min(isin_nombre.childNode(0).toString().length(), STR_MAX));

				String sector_subsector = tablaBM02ConCabecera.childNode(i).childNode(2).childNode(0).toString();
				String sector = "";
				String subsector = "";
				if (sector_subsector != null && !sector_subsector.isEmpty()) {

					if (sector_subsector.contains("-")) {
						String[] partes = sector_subsector.split("-");
						sector = partes[0].substring(0, Math.min(partes[0].length(), STR_MAX));
						subsector = partes[1].substring(0, Math.min(partes[1].length(), STR_MAX));
					} else {
						sector = sector_subsector;
					}
				}

				out += tagDia + Constantes.SEPARADOR_CAMPO + isin + Constantes.SEPARADOR_CAMPO + nombre
						+ Constantes.SEPARADOR_CAMPO + sector + Constantes.SEPARADOR_CAMPO + subsector
						+ Constantes.SEPARADOR_FILA;

			}
		}

		return out;
	}

	@Override
	public String generarSqlCreateTable() {

		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_bm02 (tag_dia varchar(15), isin varchar(15), nombre varchar(20), sector varchar(20), subsector varchar(20)"
				+ ");";
	}

}