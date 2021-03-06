package casa.galgos.gbgb;

import java.util.List;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class GbgbParserCarrerasSinFiltrarTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "carrera_bet365.html");

	@Test
	public void testParsear() throws Exception {

		List<GbgbCarrera> out = GbgbParserCarrerasSinFiltrar.parsear(res.getContent("ISO-8859-1"));

		// TODO rellenar
		Assert.assertTrue(out != null);
	}

}