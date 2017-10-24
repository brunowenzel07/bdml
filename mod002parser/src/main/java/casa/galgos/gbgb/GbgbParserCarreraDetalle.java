/**
 * 
 */
package casa.galgos.gbgb;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import utilidades.Constantes;

/**
 * @author root
 *
 */
public class GbgbParserCarreraDetalle implements Serializable {

	private static final long serialVersionUID = 1L;

	public GbgbParserCarreraDetalle() {
		super();
	}

	private static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());

	/**
	 * @param pathIn
	 *            Path absoluto al fichero HTML de la pagina del BOE almacenado en
	 *            sistema de ficheros local.
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public GbgbCarreraDetalle ejecutar(String pathIn) {

		MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: INICIO");

		String bruto = "";
		GbgbCarreraDetalle out = null;

		try {
			bruto = GbgbParserCarreraDetalle.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto);
			MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: FIN");
		return out;
	}

	/**
	 * Lee fichero desde Sistema de ficheros local.
	 * 
	 * @param path
	 * @param encoding
	 * @return
	 * @throws IOException
	 */
	public static String readFile(String path, Charset encoding) throws IOException {

		MY_LOGGER.info("Leyendo " + path + " ...");
		byte[] encoded = Files.readAllBytes(Paths.get(path));
		return new String(encoded, encoding);
	}

	/**
	 * Extrae info util
	 * 
	 * @param in
	 * @return
	 */
	public static GbgbCarreraDetalle parsear(String in) {

		Document doc = Jsoup.parse(in);
		List<Node> contenedorInfo = doc.childNode(1).childNode(1).childNode(1).childNode(5).childNode(1).childNode(1)
				.childNode(1).childNode(5).childNode(1).childNode(3).childNode(1).childNode(0).childNode(0)
				.childNodes();

		GbgbCarreraDetalle out = new GbgbCarreraDetalle();
		// --------------------------
		List<Node> infoArriba = contenedorInfo.get(2).childNodes();
		rellenarPremios(((TextNode) infoArriba.get(11).childNode(0)).text(), out);

		// --------------------------
		List<Node> infoPosiciones = contenedorInfo.get(4).childNodes();
		for (int i = 3; i <= 33; i += 6) {
			rellenarPosicion((Element) infoPosiciones.get(i), (Element) infoPosiciones.get(i + 2),
					(Element) infoPosiciones.get(i + 4), out);
		}
		// --------------------------
		List<Node> infoAbajo = contenedorInfo.get(6).childNodes();
		String goingAllowanceStr = ((TextNode) ((Element) infoAbajo.get(1)).childNode(1)).text();
		out.going_allowance = (goingAllowanceStr != null && "S".equalsIgnoreCase(goingAllowanceStr));

		String fc = ((TextNode) infoAbajo.get(3).childNode(1)).text();// (2-1) £11.75 |
		String tc = ((TextNode) infoAbajo.get(3).childNode(3)).text();// (2-1-3) £23.19
		out.rellenarForecastyTricast(fc, tc);

		return out;
	}

	/**
	 * @param premiosStr
	 *            Cadena con este formato: "1st £43, Others £30 Race Total £193 "
	 * @param out
	 */
	public static void rellenarPremios(String premiosStr, GbgbCarreraDetalle out) {

		String[] partes = premiosStr.split("£");

		out.premio_primer_puesto = Integer.valueOf(partes[1].split(",")[0]);
		out.premio_otros = Integer.valueOf(partes[2].split(" ")[0]);
		out.premio_total_carrera = Integer.valueOf(partes[3].trim());
	}

	/**
	 * @param e1
	 *            Fin Greyhound Trap SP Time/Sec. Time/Distance
	 * @param e2
	 *            Sobre el galgo
	 * @param e3
	 *            Comentarios
	 */
	public static void rellenarPosicion(Element e1, Element e2, Element e3, GbgbCarreraDetalle out) {

		Short posicion = Short.valueOf(((TextNode) e1.childNode(1).childNode(0)).text());
		String galgo_nombre = ((TextNode) e1.childNode(3).childNode(1).childNode(0)).text();
		String url_galgo_historico = Constantes.GALGOS_GBGB + e1.childNode(3).childNode(1).attr("href");
		String trap = ((TextNode) e1.childNode(5).childNode(0)).text();
		String sp = ((TextNode) e1.childNode(7).childNode(0)).text();
		String time_sec = ((TextNode) e1.childNode(9).childNode(0)).text();
		String time_distance = ((TextNode) e1.childNode(11).childNode(0)).text();

		String padre_madre_nacimiento_peso = ((TextNode) e2.childNode(1).childNode(0)).text();
		String entrenador_nombre = ((TextNode) e2.childNode(3).childNode(2)).text().replace(")", "");

		String comment = ((TextNode) e3.childNode(1).childNode(1)).text().trim();

		// TODO Parsear (hay otros formatos!!!) "bk d Sparta Maestro - Buds Of May
		// Sep-2015 ( Weight: 30.7 )"

		String peso_galgo = padre_madre_nacimiento_peso.split("Weight")[1].replace(")", "").replace(":", "").trim();
		String galgo_padre = "";
		String galgo_madre = "";
		String nacimiento = "";

		// ----------------
		out.rellenarPuesto(posicion, galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
				galgo_padre, galgo_madre, nacimiento, comment, url_galgo_historico);

	}

}