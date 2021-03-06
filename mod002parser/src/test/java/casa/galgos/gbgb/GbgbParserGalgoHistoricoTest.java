package casa.galgos.gbgb;

import java.util.Calendar;
import java.util.Map;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class GbgbParserGalgoHistoricoTest {

	String galgo_nombre = "Awesome_Thing";

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile(
			"/" + "galgos_20171024_GBGB_bruto_galgohistorico_" + galgo_nombre + ".html");
	// public ResourceFile res = new ResourceFile("/" +
	// "historico_no_encontrado.html");
	// public ResourceFile res = new ResourceFile("/" + "historico_sin_filas.html");
	// public ResourceFile res = new ResourceFile("/" + "Adamant_Reagan.html");

	@Test
	public void testParsear() throws Exception {

		GbgbGalgoHistorico out = GbgbParserGalgoHistorico.parsear(res.getContent("ISO-8859-1"), galgo_nombre);

		Assert.assertTrue(out != null);
		Assert.assertTrue(out.galgo_nombre.equals(galgo_nombre));
		Assert.assertTrue(out.padre.equals("Daves Mentor"));
		Assert.assertTrue(out.madre.equals("Time Flies"));
		Assert.assertTrue(out.nacimiento.toString().equals("20131201"));
		Assert.assertTrue(out.entrenador.equals("S MAVRIAS"));

		Assert.assertTrue(!out.carrerasHistorico.isEmpty());
		Assert.assertTrue(out.carrerasHistorico.size() > 1);
		GbgbGalgoHistoricoCarrera hc = out.carrerasHistorico.get(0);

		Assert.assertTrue(hc.by.equals("1/2"));
		Assert.assertTrue(hc.calculatedTime.equals("16.74"));
		Assert.assertTrue(hc.clase.equals("D3"));
		Assert.assertTrue(hc.distancia.equals(265));
		Assert.assertTrue(hc.fecha.get(Calendar.YEAR) == 2017);
		Assert.assertTrue(hc.fecha.get(Calendar.MONTH) == (10 - 1));
		Assert.assertTrue(hc.fecha.get(Calendar.DAY_OF_MONTH) == 22);
		Assert.assertTrue(hc.galgo_primero_o_segundo.equals("Carrigeen Mastro"));
		Assert.assertTrue(hc.going.equals("N"));
		Assert.assertTrue(hc.id_campeonato.equals(151752L));
		Assert.assertTrue(hc.id_carrera.equals(2030316L));
		Assert.assertTrue(hc.posicion.equals("2"));
		Assert.assertTrue(hc.remarks.equals("EP,Ld1-RnIn"));
		Assert.assertTrue(hc.sp.equals(6F / 4F));
		// TODO Assert.assertTrue(hc.stmHcp.equals(" "));
		Assert.assertTrue(hc.trap.equals("1"));
		Assert.assertTrue(hc.venue.equals("Central Park"));
		Assert.assertTrue(hc.winTime.equals("16.70"));
		Assert.assertTrue(hc.edadEnDias.toString().equals("1391"));
	}

	@Test
	public void testCalcularVelocidadReal() {

		Integer distancia = 265;
		Float calculatedTime = Float.valueOf(16.74f);
		String goingAllowance = "N";
		Float out = GbgbParserGalgoHistorico.calcularVelocidadReal(distancia, calculatedTime.toString(),
				goingAllowance);
		Float esperado = Float.valueOf(distancia / calculatedTime);
		Assert.assertTrue(out.equals(esperado));

		Float goingAllowance2 = 30F;
		out = GbgbParserGalgoHistorico.calcularVelocidadReal(distancia, calculatedTime.toString(),
				goingAllowance2.toString());
		esperado = Float.valueOf(distancia / (calculatedTime - (goingAllowance2 / 100.0F)));
		Assert.assertTrue(out.equals(esperado));
	}

	@Test
	public void testCalcularVelocidadConGoing() {

		Integer distancia = 265;
		Float calculatedTime = Float.valueOf(16.74f);

		Float out = GbgbParserGalgoHistorico.calcularVelocidadConGoing(distancia, calculatedTime.toString());

		Float esperado = Float.valueOf(distancia / calculatedTime);
		Assert.assertTrue(out.equals(esperado));
	}

	@Test
	public void calcularScoringRemarksTest() {

		GbgbParserGalgoHistorico gpgh1 = new GbgbParserGalgoHistorico();
		Float out1 = gpgh1.calcularScoringRemarks("EP,Ld1-RnIn");
		Assert.assertTrue(out1.equals(0.0F));
		Map<String, Integer> remarksClavesSinTraduccion1 = gpgh1.remarksClavesSinTraduccion;
		Assert.assertTrue(remarksClavesSinTraduccion1.keySet().size() == 0);

		GbgbParserGalgoHistorico gpgh2 = new GbgbParserGalgoHistorico();
		Float out2 = gpgh1.calcularScoringRemarks("FinWell,LckEP,CrdRunUp,EPace");
		Map<String, Integer> remarksClavesSinTraduccion2 = gpgh2.remarksClavesSinTraduccion;
		Assert.assertTrue(remarksClavesSinTraduccion2.keySet().size() == 0);
	}

}
