/**
 * 
 */
package casa.mod002a.datosmacro;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class DM05Parser extends ParserDeDia {

	public DM05Parser() {
		super();
	}

	@Override
	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.DATOSMACRO + "05";
	}

	@Override
	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");
		Document doc = Jsoup.parse(in);
		// TODO
		return null;
	}

	@Override
	public String generarSqlCreateTable() {

		return null;
	}

}
