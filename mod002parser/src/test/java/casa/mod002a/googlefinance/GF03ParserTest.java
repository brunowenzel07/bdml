/**
 * 
 */
package casa.mod002a.googlefinance;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class GF03ParserTest extends PadreTest {

	GF03Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new GF03Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

		Assert.assertTrue(out.startsWith(TAG_DIA_TEST
				+ "|IKM|||707460621158239|1nkemia IUCT Group SA|20.70|0.71|0.02|0.54|64.63|37.97|37.97|35.22|20.70|35.22|64.63\n"
				+ TAG_DIA_TEST));
		Assert.assertTrue(out.contains("\n" + TAG_DIA_TEST + "|ACS"));
	}

}
