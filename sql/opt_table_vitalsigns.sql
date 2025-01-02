USE icu_readmissions;
GO

/*
Tabla atenciones después de limpiarla y preprocesarla. Se añadieron dos nuevas columnas: reingreso, define si posteriormente al 
caso hubo un reingreso o no; y dias_reingreso, la cantidad de días que demoró el paciente en reingresar (sólo 2 a 30 días).
*/
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- Create table reingresos
--DROP TABLE IF EXISTS reingresos;
CREATE TABLE reingresos(
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_ingreso DATETIME NOT NULL,
	fecha_egreso DATETIME NOT NULL,
	edad_anos INT NOT NULL,
	fecha_fallece DATETIME NULL,
	dias_estancia FLOAT NOT NULL,
	reingreso INT NOT NULL,
	dias_reingreso INT NULL,
	CONSTRAINT PK_reingresos PRIMARY KEY(identificador, consecutivo),
	CONSTRAINT check_reingreso CHECK (reingreso IN (0, 1))
);
-- Insert data en la tabla reingresos
INSERT INTO reingresos
SELECT identificador, consecutivo, fecha_ingreso, fecha_egreso, edad, fecha_fallece, dias_estancia, reingreso, LEFT(dias_reingreso, 2) 
FROM hptu_eia_reingresos;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_reingresos;


-- Optimización de las tablas de signos vitales
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

-- Tabla temperatura 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos de la temperatura dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS temperatura_opt;
SELECT t24h.identificador,
	   t24h.consecutivo,
	   ROUND(AVG(COALESCE(t24h.temperatura, 0)), 2) AS temp_avg,
	   MAX(COALESCE(t24h.temperatura, 0)) AS temp_max,
	   MIN(COALESCE(t24h.temperatura, 0)) AS temp_min,
	   ROUND(STDEV(COALESCE(t24h.temperatura, 0)), 3) AS temp_std
INTO temperatura_opt
FROM(
		SELECT t.identificador,
			   t.consecutivo,
			   fecha_registro,
			   temperatura FROM temperatura t 
		INNER JOIN reingresos r
		ON r.identificador = t.identificador and r.consecutivo = t.consecutivo
		WHERE DATEDIFF(HOUR, t.fecha_registro, r.fecha_egreso) < 24) AS t24h
GROUP BY t24h.identificador, t24h.consecutivo 
HAVING count(*) > 1;

-- Tabla spo2 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos del spo2 dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS spo2_opt;
SELECT spo224h.identificador,
	   spo224h.consecutivo,
	   ROUND(AVG(COALESCE(spo224h.spo2, 0)), 2) AS spo2_avg,
	   MAX(COALESCE(spo224h.spo2, 0)) AS spo2_max,
	   MIN(COALESCE(spo224h.spo2, 0)) AS spo2_min,
	   ROUND(STDEV(COALESCE(spo224h.spo2, 0)), 3) AS spo2_std
INTO spo2_opt
FROM(
		SELECT spo2.identificador,
			   spo2.consecutivo,
			   fecha_registro,
			   spo2 FROM spo2 
		INNER JOIN reingresos r
		ON r.identificador = spo2.identificador and r.consecutivo = spo2.consecutivo
		WHERE DATEDIFF(HOUR, spo2.fecha_registro, r.fecha_egreso) < 24) AS spo224h
GROUP BY spo224h.identificador, spo224h.consecutivo 
HAVING count(*) > 1;

-- Tabla pam 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos del pam dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS pam_opt;
SELECT pam24h.identificador,
	   pam24h.consecutivo,
	   ROUND(AVG(COALESCE(pam24h.pam, 0)), 2) AS pam_avg,
	   MAX(COALESCE(pam24h.pam, 0)) AS pam_max,
	   MIN(COALESCE(pam24h.pam, 0)) AS pam_min,
	   ROUND(STDEV(COALESCE(pam24h.pam, 0)), 3) AS pam_std
INTO pam_opt
FROM(
		SELECT pam.identificador,
			   pam.consecutivo,
			   fecha_registro,
			   pam FROM pam 
		INNER JOIN reingresos r
		ON r.identificador = pam.identificador and r.consecutivo = pam.consecutivo
		WHERE DATEDIFF(HOUR, pam.fecha_registro, r.fecha_egreso) < 24) AS pam24h
GROUP BY pam24h.identificador, pam24h.consecutivo 
HAVING count(*) > 1;

-- Tabla pa_diastolica 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos de la pa_diastolica dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS pa_diastolica_opt;
SELECT pad24h.identificador,
	   pad24h.consecutivo,
	   ROUND(AVG(COALESCE(pad24h.pa_diastolica, 0)), 2) AS pa_diastolica_avg,
	   MAX(COALESCE(pad24h.pa_diastolica, 0)) AS pa_diastolica_max,
	   MIN(COALESCE(pad24h.pa_diastolica, 0)) AS pa_diastolica_min,
	   ROUND(STDEV(COALESCE(pad24h.pa_diastolica, 0)), 3) AS pa_diastolica_std
INTO pa_diastolica_opt
FROM(
		SELECT pad.identificador,
			   pad.consecutivo,
			   fecha_registro,
			   pa_diastolica FROM pa_diastolica pad
		INNER JOIN reingresos r
		ON r.identificador = pad.identificador and r.consecutivo = pad.consecutivo
		WHERE DATEDIFF(HOUR, pad.fecha_registro, r.fecha_egreso) < 24) AS pad24h
GROUP BY pad24h.identificador, pad24h.consecutivo 
HAVING count(*) > 1;

-- Tabla pa_sistolica 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos de la pa_sistolica dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS pa_sistolica_opt;
SELECT pas24h.identificador,
	   pas24h.consecutivo,
	   ROUND(AVG(COALESCE(pas24h.pa_sistolica, 0)), 2) AS pa_sistolica_avg,
	   MAX(COALESCE(pas24h.pa_sistolica, 0)) AS pa_sistolica_max,
	   MIN(COALESCE(pas24h.pa_sistolica, 0)) AS pa_sistolica_min,
	   ROUND(STDEV(COALESCE(pas24h.pa_sistolica, 0)), 3) AS pa_sistolica_std
INTO pa_sistolica_opt
FROM(
		SELECT pas.identificador,
			   pas.consecutivo,
			   fecha_registro,
			   pa_sistolica FROM pa_sistolica pas
		INNER JOIN reingresos r
		ON r.identificador = pas.identificador and r.consecutivo = pas.consecutivo
		WHERE DATEDIFF(HOUR, pas.fecha_registro, r.fecha_egreso) < 24) AS pas24h
GROUP BY pas24h.identificador, pas24h.consecutivo 
HAVING count(*) > 1;

-- Tabla frec_respiratoria 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos de la frec_respiratoria dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS frec_respiratoria_opt;
SELECT fr24h.identificador,
	   fr24h.consecutivo,
	   ROUND(AVG(COALESCE(fr24h.frec_resp, 0)), 2) AS frec_respiratoria_avg,
	   MAX(COALESCE(fr24h.frec_resp, 0)) AS frec_respiratoria_max,
	   MIN(COALESCE(fr24h.frec_resp, 0)) AS frec_respiratoria_min,
	   ROUND(STDEV(COALESCE(fr24h.frec_resp, 0)), 3) AS frec_respiratoria_std
INTO frec_respiratoria_opt
FROM(
		SELECT fr.identificador,
			   fr.consecutivo,
			   fecha_registro,
			   frec_resp FROM frec_respiratoria fr
		INNER JOIN reingresos r
		ON r.identificador = fr.identificador and r.consecutivo = fr.consecutivo
		WHERE DATEDIFF(HOUR, fr.fecha_registro, r.fecha_egreso) < 24) AS fr24h
GROUP BY fr24h.identificador, fr24h.consecutivo 
HAVING count(*) > 1;

-- Tabla frec_cardiaca 
--------------------------------------------------------------------------------------------------------------------------------------
-- Tabla optimizada con valores estadísticos de la frec_cardiaca dentro las últimas 24 horas antes del egreso
--DROP TABLE IF EXISTS frec_cardiaca_opt;
SELECT fc24h.identificador,
	   fc24h.consecutivo,
	   ROUND(AVG(COALESCE(fc24h.frec_card, 0)), 2) AS frec_cardiaca_avg,
	   MAX(COALESCE(fc24h.frec_card, 0)) AS frec_cardiaca_max,
	   MIN(COALESCE(fc24h.frec_card, 0)) AS frec_cardiaca_min,
	   ROUND(STDEV(COALESCE(fc24h.frec_card, 0)), 3) AS frec_cardiaca_std
INTO frec_cardiaca_opt
FROM(
		SELECT fc.identificador,
			   fc.consecutivo,
			   fecha_registro,
			   frec_card FROM frec_cardiaca fc
		INNER JOIN reingresos r
		ON r.identificador = fc.identificador and r.consecutivo = fc.consecutivo
		WHERE DATEDIFF(HOUR, fc.fecha_registro, r.fecha_egreso) < 24) AS fc24h
GROUP BY fc24h.identificador, fc24h.consecutivo 
HAVING count(*) > 1;

-- Selección de la escala a utilizar
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- Creación de la tabla con la escala APACHEII
SELECT *
INTO apache2
FROM escalas
WHERE escala = 'APACHEII';

-- Optimización de las tablas de balance de líquidos
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
SELECT identificador,
	   consecutivo,
	   SUM(valor) AS sum_liq,
	   CASE
			WHEN SUM(valor) > 0 THEN 'hipervolémico'
			WHEN SUM(valor) < 0 THEN 'hipovolémico'
			ELSE 'euvolémico'
	   END AS balance
INTO balance_liquidos_opt
FROM balance_liquidos
GROUP BY identificador, consecutivo
HAVING COUNT(*) > 1;

-- Actualización de las tablas de glucometrias
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
SELECT identificador,
	   consecutivo,
	   CAST(REPLACE(
		    REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(CASE
	   					WHEN valor LIKE 'h%' OR valor LIKE 'E%' OR valor like '"H%"' OR valor LIKE 'H%' OR
					         valor LIKE '"l%"' OR valor LIKE '"L%"' OR valor like 'r%' OR valor LIKE 'L%' OR
							 valor LIKE 'l%' OR valor LIKE 't%' OR valor like 'o%' OR valor LIKE '.' OR
							 valor LIKE 'R%' OR valor LIKE 'c%' OR valor like '}%' OR valor LIKE '%mar' THEN NULL
						WHEN valor LIKE '1oo' THEN '"100"'
						WHEN valor LIKE '200%'  THEN '200'
						WHEN valor LIKE '185o' THEN '"185"'
						WHEN valor LIKE 'v119' THEN '119'
						WHEN valor LIKE '128/' THEN '128'
						WHEN valor LIKE 'G126' THEN '126'
						WHEN valor LIKE '12o' THEN '120'
						WHEN valor LIKE '12g6' THEN '126'
						WHEN valor LIKE '108 mg' THEN '108'
						WHEN valor LIKE '96s' THEN '96'
						WHEN valor LIKE '*96' THEN '96'
						WHEN valor LIKE '16/' THEN '167'
						WHEN valor LIKE '32 8' THEN '328'
						ELSE valor
	   				END, 'mg/dl', ''), ',','.'), '|', ''), '+', ''),'"','') as float) as valor,
	   fecha_registro
INTO glucometrias_act
FROM glucometrias;

-- Optimización de la tabla de glucometrías
WITH ultima_muestra_gluco AS (
    SELECT identificador,
           consecutivo,
           valor,
           fecha_registro,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_registro DESC) AS fila
    FROM glucometrias_act)
SELECT identificador,
       consecutivo,
       valor AS glucometria,
       fecha_registro
INTO glucometria_opt
FROM ultima_muestra_gluco
WHERE fila = 1;

-- Selección de sólo el diagnóstico principal de las tablas de diagnóstico
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
SELECT * 
INTO diagnostico_ppal
FROM diagnosticos
WHERE tipo_diagnostico = 'PRINCIPAL';