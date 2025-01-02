USE icu_readmissions;
GO

/*
Joins de cada una de las tablas utilizadas para la creación de la tabla que se va a preprocesar en Python para el desarrollo
de los modelos de Machine Learning
*/
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- Reingresos, balance_liquidos, signos_vitales, diagnosticos, laboratorio
SELECT r.identificador,
	   r.consecutivo,
	   r.edad_anos,
	   cie_10.descripcion_codigo_4,
	   liq.sum_liq,
	   liq.balance,
	   a2.valor AS apache_2,
	   gluco.glucometria,
	   t.temp_avg,
	   spo2.spo2_avg,
	   pam.pam_avg,
	   sis.pa_sistolica_avg,
	   dia.pa_diastolica_avg,
	   fc.frec_cardiaca_avg,
	   fr.frec_respiratoria_avg,
	   t.temp_max,
	   spo2.spo2_max,
	   pam.pam_max,
	   sis.pa_sistolica_max,
	   dia.pa_diastolica_max,
	   fc.frec_cardiaca_max,
	   fr.frec_respiratoria_max,
	   t.temp_min,
	   spo2.spo2_min,
	   pam.pam_min,
	   sis.pa_sistolica_min,
	   dia.pa_diastolica_min,
	   fc.frec_cardiaca_min,
	   fr.frec_respiratoria_min,
	   t.temp_std,
	   spo2.spo2_std,
	   pam.pam_std,
	   sis.pa_sistolica_std,
	   dia.pa_diastolica_std,
	   fc.frec_cardiaca_std,
	   fr.frec_respiratoria_std,
	   vpm.vpm,
	   vcm.vcm,
	   co2.tco2,
	   na.sodio,
	   plaq.num_plaquetas,
	   leu.num_leucocitos,
	   eri.num_eritrocitos,
	   rdw.rdw,
	   prot_c.cant_proteina_c,
	   k.cant_potasio,
	   poi.poiquilocitosis,
	   po2_t.po2_temp,
	   po2.po2,
	   ph_t.ph_temp,
	   ph.ph,
	   pco2_t.pco2_temp,
	   pco2.pco2,
	   n_ure.cant_n_ureico,
	   neut_pcje.pcje_neutrofilos,
	   neut.num_neutrofilos,
	   mono.pcje_monocitos,
	   miel.pcje_mielocitos,
	   micro.microcitosis,
	   meta.pcje_metamielocitos,
	   mg.cant_magnesio,
	   macro.macrocitosis,
	   lac.lactato,
	   pf.indice_p_f,
	   hj.howell_jolly,
	   hipo.hipocromia,
	   hcm.hcm,
	   h.hemoglobina,
	   ht.hematocrito,
	   fio2.fio2,
	   frx.fenomeno_rouleaux,
	   est.estomatocitos,
	   esq.esquistocitos,
	   eo.pcje_eosinofilos,
	   dian.dianocitos,
	   cre.crenocitos,
	   crea.creatinina,
	   cl.cloro,
	   chcm.chcm,
	   cai.calcio_ionico,
	   ca.calcio,
	   hco3.hco3,
	   bt.bilirrubina_total,
	   bd.bilirrubina_directa,
	   baso.pcje_basofilos,
	   ani.anisocitosis,
	   aa.a_aDO2,
	   aca.acantocitos,
	   r.dias_estancia,
	   r.reingreso,
	   r.dias_reingreso
INTO readmisiones_uci
FROM reingresos r
LEFT JOIN temperatura_opt t ON r.identificador = t.identificador AND r.consecutivo = t.consecutivo
LEFT JOIN spo2_opt spo2 ON r.identificador = spo2.identificador AND r.consecutivo = spo2.consecutivo
LEFT JOIN pam_opt pam ON r.identificador = pam.identificador AND r.consecutivo = pam.consecutivo
LEFT JOIN pa_sistolica_opt sis ON r.identificador = sis.identificador AND r.consecutivo = sis.consecutivo
LEFT JOIN pa_diastolica_opt dia ON r.identificador = dia.identificador AND r.consecutivo = dia.consecutivo
LEFT JOIN frec_cardiaca_opt fc ON r.identificador = fc.identificador AND r.consecutivo = fc.consecutivo
LEFT JOIN frec_respiratoria_opt fr ON r.identificador = fr.identificador AND r.consecutivo = fr.consecutivo
LEFT JOIN diagnostico_ppal dp ON r.identificador = dp.identificador AND r.consecutivo = dp.consecutivo
LEFT JOIN cie_10 ON cie_10.codigo_4 = dp.cod_diagnostico
LEFT JOIN apache2 a2 ON r.identificador = a2.identificador AND r.consecutivo = a2.consecutivo
LEFT JOIN glucometria_opt gluco ON r.identificador = gluco.identificador AND r.consecutivo = gluco.consecutivo
LEFT JOIN balance_liquidos_opt liq ON r.identificador = liq.identificador AND r.consecutivo = liq.consecutivo
LEFT JOIN vpm ON r.identificador = vpm.identificador AND r.consecutivo = vpm.consecutivo
LEFT JOIN vcm ON r.identificador = vcm.identificador AND r.consecutivo = vcm.consecutivo
LEFT JOIN tco2 co2 ON r.identificador = co2.identificador AND r.consecutivo = co2.consecutivo
LEFT JOIN sodio na ON r.identificador = na.identificador AND r.consecutivo = na.consecutivo
LEFT JOIN recuento_plaquetas plaq ON r.identificador = plaq.identificador AND r.consecutivo = plaq.consecutivo
LEFT JOIN recuento_leucocitos leu ON r.identificador = leu.identificador AND r.consecutivo = leu.consecutivo
LEFT JOIN recuento_eritrocitos eri ON r.identificador = eri.identificador AND r.consecutivo = eri.consecutivo
LEFT JOIN rdw ON r.identificador = rdw.identificador AND r.consecutivo = rdw.consecutivo
LEFT JOIN proteina_c_reactiva prot_c ON r.identificador = prot_c.identificador AND r.consecutivo = prot_c.consecutivo
LEFT JOIN potasio k ON r.identificador = k.identificador AND r.consecutivo = k.consecutivo
LEFT JOIN policromatofilia poli ON r.identificador = poli.identificador AND r.consecutivo = poli.consecutivo
LEFT JOIN poiquilocitosis poi ON r.identificador = poi.identificador AND r.consecutivo = poi.consecutivo
LEFT JOIN po2_corr_temp po2_t ON r.identificador = po2_t.identificador AND r.consecutivo = po2_t.consecutivo
LEFT JOIN po2 ON r.identificador = po2.identificador AND r.consecutivo = po2.consecutivo
LEFT JOIN ph_corr_temp ph_t ON r.identificador = ph_t.identificador AND r.consecutivo = ph_t.consecutivo
LEFT JOIN ph ON r.identificador = ph.identificador AND r.consecutivo = ph.consecutivo
LEFT JOIN pco2_corr_temp pco2_t ON r.identificador = pco2_t.identificador AND r.consecutivo = pco2_t.consecutivo
LEFT JOIN pco2 ON r.identificador = pco2.identificador AND r.consecutivo = pco2.consecutivo
LEFT JOIN nitrogeno_ureico n_ure ON r.identificador = n_ure.identificador AND r.consecutivo = n_ure.consecutivo
LEFT JOIN pcje_neutrofilos neut_pcje ON r.identificador = neut_pcje.identificador AND r.consecutivo = neut_pcje.consecutivo
LEFT JOIN num_neutrofilos neut ON r.identificador = neut.identificador AND r.consecutivo = neut.consecutivo
LEFT JOIN pcje_monocitos mono ON r.identificador = mono.identificador AND r.consecutivo = mono.consecutivo
LEFT JOIN pcje_mielocitos miel ON r.identificador = miel.identificador AND r.consecutivo = miel.consecutivo
LEFT JOIN microcitosis micro ON r.identificador = micro.identificador AND r.consecutivo = micro.consecutivo
LEFT JOIN pcje_metamielocitos meta ON r.identificador = meta.identificador AND r.consecutivo = meta.consecutivo
LEFT JOIN magnesio mg ON r.identificador = mg.identificador AND r.consecutivo = mg.consecutivo
LEFT JOIN macrocitosis macro ON r.identificador = macro.identificador AND r.consecutivo = macro.consecutivo
LEFT JOIN lactato lac ON r.identificador = lac.identificador AND r.consecutivo = lac.consecutivo
LEFT JOIN indice_p_f pf ON r.identificador = pf.identificador AND r.consecutivo = pf.consecutivo
LEFT JOIN howell_jolly hj ON r.identificador = hj.identificador AND r.consecutivo = hj.consecutivo
LEFT JOIN hipocromia hipo ON r.identificador = hipo.identificador AND r.consecutivo = hipo.consecutivo
LEFT JOIN hcm ON r.identificador = hcm.identificador AND r.consecutivo = hcm.consecutivo
LEFT JOIN hemoglobina h ON r.identificador = h.identificador AND r.consecutivo = h.consecutivo
LEFT JOIN hematocrito ht ON r.identificador = ht.identificador AND r.consecutivo = ht.consecutivo
LEFT JOIN fio2 ON r.identificador = fio2.identificador and r.consecutivo = fio2.consecutivo
LEFT JOIN fenomeno_rouleaux frx ON r.identificador = frx.identificador AND r.consecutivo = frx.consecutivo
LEFT JOIN estomatocitos est ON r.identificador = est.identificador AND r.consecutivo = est.consecutivo
LEFT JOIN esquistocitos esq ON r.identificador = esq.identificador AND r.consecutivo = esq.consecutivo
LEFT JOIN eosinofilos eo ON r.identificador = eo.identificador AND r.consecutivo = eo.consecutivo
LEFT JOIN dianocitos dian ON r.identificador = dian.identificador AND r.consecutivo = dian.consecutivo
LEFT JOIN crenocitos cre ON r.identificador = cre.identificador AND r.consecutivo = cre.consecutivo
LEFT JOIN creatinina crea ON r.identificador = crea.identificador AND r.consecutivo = crea.consecutivo
LEFT JOIN cloro cl ON r.identificador = cl.identificador AND r.consecutivo = cl.consecutivo
LEFT JOIN chcm ON r.identificador = chcm.identificador AND r.consecutivo = chcm.consecutivo
LEFT JOIN calcio_ionico cai ON r.identificador = cai.identificador AND r.consecutivo = cai.consecutivo
LEFT JOIN calcio ca ON r.identificador = ca.identificador AND r.consecutivo = ca.consecutivo
LEFT JOIN bilirrubina_total bt ON r.identificador = bt.identificador AND r.consecutivo = bt.consecutivo
LEFT JOIN bilirrubina_directa bd ON r.identificador = bd.identificador AND r.consecutivo = bd.consecutivo
LEFT JOIN bicarbonato hco3 ON r.identificador = hco3.identificador AND r.consecutivo = hco3.consecutivo
LEFT JOIN pcje_basofilos baso ON r.identificador = baso.identificador AND r.consecutivo = baso.consecutivo
LEFT JOIN anisocitosis ani ON r.identificador = ani.identificador AND r.consecutivo = ani.consecutivo
LEFT JOIN alv_art_gradiente aa ON r.identificador = aa.identificador AND r.consecutivo = aa.consecutivo
LEFT JOIN acantocitos aca on r.identificador = aca.identificador AND r.consecutivo = aca.consecutivo
;

/*
Se exporta la tabla creada
*/