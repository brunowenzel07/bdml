package utilidades;

public class Constantes {

	public static final String PATH_DIR_DATOS_BRUTOS_BOLSA = "/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/";
	public static final String PATH_DIR_DATOS_LIMPIOS_BOLSA = "/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/";

	public static final String BOE_IN = "BOE_in";
	public static final String BOE_OUT = "BOE_out";

	public static final String GF = "_GOOGLEFINANCE_";
	public static final String BM = "_BOLSAMADRID_";
	public static final String INE = "_INE_";
	public static final String DATOSMACRO = "_DATOSMACRO_";

	public static final String OUT = "_OUT";

	public static final String PATH_DIR_DATOS_BRUTOS_GALGOS = "/home/carloslinux/Desktop/DATOS_BRUTO/galgos/";
	public static final String PATH_DIR_DATOS_LIMPIOS_GALGOS = "/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/";
	public static final String GALGOS_GBGB = "http://www.gbgb.org.uk";
	public static final String GALGOS_GBGB_CARRERAS = GALGOS_GBGB + "/Results.aspx";
	public static final String GALGOS_GBGB_CARRERA_DETALLE_PREFIJO = GALGOS_GBGB + "/resultsRace.aspx?id=";

	public static final String SEPARADOR_CAMPO = "|";
	public static final String SEPARADOR_FILA = "\n";

	public static final String[] DM_PAISES_INTERESANTES = { "España", "Alemania", "Francia", "Zona Euro",
			"Estados Unidos", "Brasil", "Rusia" };

	public static final int BM03_LONGITUD_TRUNCATE = 255;

	/**
	 * @param in
	 * @param longitudMax
	 * @return
	 */
	public static String truncar(String in, int longitudMax) {
		int maxLength = (in.length() < longitudMax) ? in.length() : longitudMax;
		return in.substring(0, maxLength);
	}

	/**
	 * @param in
	 * @param tipo
	 *            1-String, 2-Decimal
	 * @return
	 */
	public static String tratar(String in, int tipo) {
		if (tipo == 1) {
			return in.replace(Constantes.SEPARADOR_CAMPO, "").replace(Constantes.SEPARADOR_FILA, "");
		} else if (tipo == 2) {
			return in.replace(".", "").replace(",", ".").replace(Constantes.SEPARADOR_CAMPO, "")
					.replace(Constantes.SEPARADOR_FILA, "");
		} else {
			return in.replace(Constantes.SEPARADOR_CAMPO, "").replace(Constantes.SEPARADOR_FILA, "");
		}
	}

}