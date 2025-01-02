USE icu_readmissions;
GO

-- Optimización de las tablas de laboratorios
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

-- Tabla de volumen plaquetario medio
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS vpm;
WITH vpm_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(CASE
                                        WHEN resultado LIKE '-%' THEN NULL
                                        ELSE resultado
                                    END, '"', ''), '''', '') AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Volumen plaquetario medio'),
ultima_muestra_vpm AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM vpm_limp)
SELECT identificador,
       consecutivo,
       resultado AS vpm,
       fecha_muestra
INTO vpm
FROM ultima_muestra_vpm
WHERE fila = 1;

-- Tabla de volumen corpuscular medio
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS vcm;
WITH vcm_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Volumen corpuscular medio'),
ultima_muestra_vcm AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM vcm_limp)
SELECT identificador,
       consecutivo,
       resultado AS vcm,
       fecha_muestra
INTO vcm
FROM ultima_muestra_vcm
WHERE fila = 1;

-- Tabla de CO2 en sangre
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS tco2;
WITH tco2_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(CASE
										 WHEN resultado LIKE '"-%"' OR resultado LIKE '"M%"' THEN NULL
										 ELSE resultado
									END, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'TCO2'),
ultima_muestra_tco2 AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM tco2_limp)
SELECT identificador,
       consecutivo,
       resultado AS tco2,
       fecha_muestra
INTO tco2
FROM ultima_muestra_tco2
WHERE fila = 1;

-- Tabla de sodio en sangre
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS sodio;
WITH sodio_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN 100
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Sodio'),
ultima_muestra_sodio AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM sodio_limp)
SELECT identificador,
       consecutivo,
       resultado AS sodio,
       fecha_muestra
INTO sodio
FROM ultima_muestra_sodio
WHERE fila = 1;

-- Tabla de recuento de plaquetas
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS recuento_plaquetas;
WITH plaquetas_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Recuento de plaquetas'),
ultima_muestra_plaquetas AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM plaquetas_limp)
SELECT identificador,
       consecutivo,
       resultado AS num_plaquetas,
       fecha_muestra
INTO recuento_plaquetas
FROM ultima_muestra_plaquetas
WHERE fila = 1;

-- Tabla de recuento de leucocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS recuento_leucocitos;
WITH leucocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '0%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Recuento de leucocitos'),
ultima_muestra_leucocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM leucocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS num_leucocitos,
       fecha_muestra
INTO recuento_leucocitos
FROM ultima_muestra_leucocitos
WHERE fila = 1;

-- Tabla de recuento de eritrocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS recuento_eritrocitos;
WITH eritrocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Recuento de eritrocitos'),
ultima_muestra_eritrocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM eritrocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS num_eritrocitos,
       fecha_muestra
INTO recuento_eritrocitos
FROM ultima_muestra_eritrocitos
WHERE fila = 1;

-- Tabla de proteína C reactiva
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS proteina_c_reactiva;
WITH prot_c_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(REPLACE(REPLACE(resultado, '"', ''), '''', ''), '<', ''), '>', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Proteína C reactiva '),
ultima_muestra_prot_c AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM prot_c_limp)
SELECT identificador,
       consecutivo,
       resultado AS cant_proteina_c,
       fecha_muestra
INTO proteina_c_reactiva
FROM ultima_muestra_prot_c
WHERE fila = 1;

-- Tabla de potasio en sangre
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS potasio;
WITH potasio_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Potasio'),
ultima_muestra_potasio AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM potasio_limp)
SELECT identificador,
       consecutivo,
       resultado AS cant_potasio,
       fecha_muestra
INTO potasio
FROM ultima_muestra_potasio
WHERE fila = 1;

-- Tabla de policromatofilia
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS policromatofilia;
WITH policromatofilia_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN 0
				ELSE 1
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Policromatofilia'),
ultima_muestra_policromatofilia AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM policromatofilia_limp)
SELECT identificador,
       consecutivo,
       resultado AS policromatofilia,
       fecha_muestra
INTO policromatofilia
FROM ultima_muestra_policromatofilia
WHERE fila = 1;

-- Tabla de poiquilocitosis
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS poiquilocitosis;
WITH poiquilocitosis_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Poiquilocitosis'),
ultima_muestra_poiquilocitosis AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM poiquilocitosis_limp)
SELECT identificador,
       consecutivo,
       resultado AS poiquilocitosis,
       fecha_muestra
INTO poiquilocitosis
FROM ultima_muestra_poiquilocitosis
WHERE fila = 1;

-- Tabla de pO2 corregido por temperatura
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS po2_corr_temp;
WITH po2_corr_temp_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'pO2 corregido por temperatura'),
ultima_muestra_po2_corr_temp AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM po2_corr_temp_limp)
SELECT identificador,
       consecutivo,
       resultado AS po2_temp,
       fecha_muestra
INTO po2_corr_temp
FROM ultima_muestra_po2_corr_temp
WHERE fila = 1;

-- Tabla de pO2
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS po2;
WITH po2_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN 6
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '0%' THEN 6
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'pO2'),
ultima_muestra_po2 AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM po2_limp)
SELECT identificador,
       consecutivo,
       resultado AS po2,
       fecha_muestra
INTO po2
FROM ultima_muestra_po2
WHERE fila = 1;

-- Tabla de pH corregido por temperatura
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS ph_corr_temp;
WITH ph_corr_temp_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '1%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 74.42 THEN 7.44
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'pH corregido por temperatura'),
ultima_muestra_ph_corr_temp AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM ph_corr_temp_limp)
SELECT identificador,
       consecutivo,
       resultado AS ph_temp,
       fecha_muestra
INTO ph_corr_temp
FROM ultima_muestra_ph_corr_temp
WHERE fila = 1;

-- Tabla de pH
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS ph;
WITH ph_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '--%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'n%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 0 THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 1 THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '14%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 37.00 then 3.7
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '73%' then 7.3
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-6%' then 6.8
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '1%' then 6.8
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'pH'),
ultima_muestra_ph AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM ph_limp)
SELECT identificador,
       consecutivo,
       resultado AS ph,
       fecha_muestra
INTO ph
FROM ultima_muestra_ph
WHERE fila = 1;

-- Tabla de pCO2 corregido por temperatura
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pco2_corr_temp;
WITH pco2_corr_temp_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '>%' THEN 150
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'pCO2 corregido por temperatura'),
ultima_muestra_pco2_corr_temp AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM pco2_corr_temp_limp)
SELECT identificador,
       consecutivo,
       resultado AS pco2_temp,
       fecha_muestra
INTO pco2_corr_temp
FROM ultima_muestra_pco2_corr_temp
WHERE fila = 1;

-- Tabla de pCO2
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pco2;
WITH pco2_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '--%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '0.%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '>115' THEN 115.0
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '>125' THEN 125.0
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '>150' THEN 150.0
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'pCO2'),
ultima_muestra_pco2 AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM pco2_limp)
SELECT identificador,
       consecutivo,
       resultado AS pco2,
       fecha_muestra
INTO pco2
FROM ultima_muestra_pco2
WHERE fila = 1;

-- Tabla de nitrógeno ureico
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS nitrogeno_ureico;
WITH n_ureico_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN 2.0
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '>%' THEN 150.0
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Nitrógeno ureico'),
ultima_muestra_n_ureico AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM n_ureico_limp)
SELECT identificador,
       consecutivo,
       resultado AS cant_n_ureico,
       fecha_muestra
INTO nitrogeno_ureico
FROM ultima_muestra_n_ureico
WHERE fila = 1;

-- Tabla de porcentaje de neutrófilos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pcje_neutrofilos;
WITH pcje_neutrofilos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Neutrófilos %'),
ultima_muestra_pcje_neutrofilos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM pcje_neutrofilos_limp)
SELECT identificador,
       consecutivo,
       resultado AS pcje_neutrofilos,
       fecha_muestra
INTO pcje_neutrofilos
FROM ultima_muestra_pcje_neutrofilos
WHERE fila = 1;

-- Tabla de cantidad de neutrófilos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS num_neutrofilos;
WITH neutrofilos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
				    END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Neutrófilos'),
ultima_muestra_neutrofilos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM neutrofilos_limp)
SELECT identificador,
       consecutivo,
       resultado AS num_neutrofilos,
       fecha_muestra
INTO num_neutrofilos
FROM ultima_muestra_neutrofilos
WHERE fila = 1;

-- Tabla de porcentaje de monocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pcje_monocitos;
WITH monocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Monocitos %'),
ultima_muestra_monocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM monocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS pcje_monocitos,
       fecha_muestra
INTO pcje_monocitos
FROM ultima_muestra_monocitos
WHERE fila = 1;

-- Tabla de microcitosis
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS microcitosis;
WITH microcitosis_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Microcitosis'),
ultima_muestra_microcitosis AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM microcitosis_limp)
SELECT identificador,
       consecutivo,
       resultado AS microcitosis,
       fecha_muestra
INTO microcitosis
FROM ultima_muestra_microcitosis
WHERE fila = 1;

-- Tabla de porcentaje de mielocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pcje_mielocitos;
WITH mielocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Mielocitos %'),
ultima_muestra_mielocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM mielocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS pcje_mielocitos,
       fecha_muestra
INTO pcje_mielocitos
FROM ultima_muestra_mielocitos
WHERE fila = 1;

-- Tabla de porcentaje de mielocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pcje_metamielocitos;
WITH metamielocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Metamielocitos %'),
ultima_muestra_metamielocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM metamielocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS pcje_metamielocitos,
       fecha_muestra
INTO pcje_metamielocitos
FROM ultima_muestra_metamielocitos
WHERE fila = 1;

-- Tabla de magnesio
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS magnesio;
WITH magnesio_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
		   TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN '0.6'
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '>%' THEN '7.07'
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Magnesio'),
ultima_muestra_magnesio AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM magnesio_limp)
SELECT identificador,
       consecutivo,
       resultado AS cant_magnesio,
       fecha_muestra
INTO magnesio
FROM ultima_muestra_magnesio
WHERE fila = 1;

-- Tabla de macrocitosis
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS macrocitosis;
WITH macrocitosis_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Macrocitosis'),
ultima_muestra_macrocitosis AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM macrocitosis_limp)
SELECT identificador,
       consecutivo,
       resultado AS macrocitosis,
       fecha_muestra
INTO macrocitosis
FROM ultima_muestra_macrocitosis
WHERE fila = 1;

-- Tabla de lactato
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS lactato;
WITH lactato_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN NULL
				ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
		   END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Lactato'),
ultima_muestra_lactato AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM lactato_limp)
SELECT identificador,
       consecutivo,
       resultado AS lactato,
       fecha_muestra
INTO lactato
FROM ultima_muestra_lactato
WHERE fila = 1;

-- Tabla de Indice PaO2/FiO2
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS indice_p_f;
WITH p_f_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
				ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
		   END AS INT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Indice P/F'),
ultima_muestra_p_f AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM p_f_limp)
SELECT identificador,
       consecutivo,
       resultado AS indice_p_f,
       fecha_muestra
INTO indice_p_f
FROM ultima_muestra_p_f
WHERE fila = 1;

-- Tabla de hipocromía
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS hipocromia;
WITH hipocromia_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Hipocromía'),
ultima_muestra_hipocromia AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM hipocromia_limp)
SELECT identificador,
       consecutivo,
       resultado AS hipocromia,
       fecha_muestra
INTO hipocromia
FROM ultima_muestra_hipocromia
WHERE fila = 1;

-- Tabla de hemoglobina
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS hemoglobina;
WITH hemoglobina_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
		   END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Hemoglobina'),
ultima_muestra_hemoglobina AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM hemoglobina_limp)
SELECT identificador,
       consecutivo,
       resultado AS hemoglobina,
       fecha_muestra
INTO hemoglobina
FROM ultima_muestra_hemoglobina
WHERE fila = 1;

-- Tabla de hemoglobina corpuscular media
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS hcm;
WITH hcm_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Hemoglobina corpuscular media '),
ultima_muestra_hcm AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM hcm_limp)
SELECT identificador,
       consecutivo,
       resultado AS hcm,
       fecha_muestra
INTO hcm
FROM ultima_muestra_hcm
WHERE fila = 1;

-- Tabla de hematocrito
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS hemoglobina;
WITH hematocrito_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
		   END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Hematocrito'),
ultima_muestra_hematocrito AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM hematocrito_limp)
SELECT identificador,
       consecutivo,
       resultado AS hematocrito,
       fecha_muestra
INTO hematocrito
FROM ultima_muestra_hematocrito
WHERE fila = 1;

-- Tabla de bicarabonato
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS bicarbonato;
WITH hco3_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
				ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
		   END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'HCO3'),
ultima_muestra_hco3 AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM hco3_limp)
SELECT identificador,
       consecutivo,
       resultado AS hco3,
       fecha_muestra
INTO bicarbonato
FROM ultima_muestra_hco3
WHERE fila = 1;

-- Tabla de FiO2
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS fio2;
WITH fio2_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '0%' THEN 0
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
				ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
		   END AS INTEGER) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'FIO2'),
ultima_muestra_fio2 AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM fio2_limp)
SELECT identificador,
       consecutivo,
       resultado AS fio2,
       fecha_muestra
INTO fio2
FROM ultima_muestra_fio2
WHERE fila = 1;

-- Tabla de fenómeno de rouleaux
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS fenomeno_rouleaux;
WITH f_r_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN 0
				ELSE 1
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Fenómeno de Rouleaux'),
ultima_muestra_f_r AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM f_r_limp)
SELECT identificador,
       consecutivo,
       resultado AS fenomeno_rouleaux,
       fecha_muestra
INTO fenomeno_rouleaux
FROM ultima_muestra_f_r
WHERE fila = 1;

-- Tabla de estomatocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS estomatocitos;
WITH estomatocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Estomatocitos'),
ultima_muestra_estomatocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM estomatocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS estomatocitos,
       fecha_muestra
INTO estomatocitos
FROM ultima_muestra_estomatocitos
WHERE fila = 1;

-- Tabla de esquistocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS esquistocitos;
WITH esquistocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Esquistocitos'),
ultima_muestra_esquistocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM esquistocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS esquistocitos,
       fecha_muestra
INTO esquistocitos
FROM ultima_muestra_esquistocitos
WHERE fila = 1;

-- Tabla de porcentaje de eosinófilos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS eosinofilos;
WITH eosinofilos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Eosinófilos %'),
ultima_muestra_eosinofilos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM eosinofilos_limp)
SELECT identificador,
       consecutivo,
       resultado AS pcje_eosinofilos,
       fecha_muestra
INTO eosinofilos
FROM ultima_muestra_eosinofilos
WHERE fila = 1;

-- Tabla de dianocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS dianocitos;
WITH dianocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Dianocitos'),
ultima_muestra_dianocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM dianocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS dianocitos,
       fecha_muestra
INTO dianocitos
FROM ultima_muestra_dianocitos
WHERE fila = 1;

-- Tabla de cuerpos de howell y jolly
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS howell_jolly;
WITH howell_jolly_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN 0
				ELSE 1
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Cuerpos de Howell Jolly'),
ultima_muestra_howell_jolly AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM howell_jolly_limp)
SELECT identificador,
       consecutivo,
       resultado AS howell_jolly,
       fecha_muestra
INTO howell_jolly
FROM ultima_muestra_howell_jolly
WHERE fila = 1;

-- Tabla de crenocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS crenocitos;
WITH crenocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
	   			WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN 0
				ELSE 1
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Crenocitos'),
ultima_muestra_crenocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM crenocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS crenocitos,
       fecha_muestra
INTO crenocitos
FROM ultima_muestra_crenocitos
WHERE fila = 1;

-- Tabla de creatinina
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS creatinina;
WITH creatinina_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Creatinina'),
ultima_muestra_creatinina AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM creatinina_limp)
SELECT identificador,
       consecutivo,
       resultado AS creatinina,
       fecha_muestra
INTO creatinina
FROM ultima_muestra_creatinina
WHERE fila = 1;

-- Tabla de concentración de hemoglobina corpuscular media
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS chcm;
WITH chcm_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Concentración de hemoglobina corpuscular media'),
ultima_muestra_chcm AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM chcm_limp)
SELECT identificador,
       consecutivo,
       resultado AS chcm,
       fecha_muestra
INTO chcm
FROM ultima_muestra_chcm
WHERE fila = 1;

-- Tabla de cloro
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS cloro;
WITH cloro_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Cloro'),
ultima_muestra_cloro AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM cloro_limp)
SELECT identificador,
       consecutivo,
       resultado AS cloro,
       fecha_muestra
INTO cloro
FROM ultima_muestra_cloro
WHERE fila = 1;

-- Tabla de calcio iónico
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS calcio_ionico;
WITH calcio_ion_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Calcio iónico'),
ultima_muestra_calcio_ion AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM calcio_ion_limp)
SELECT identificador,
       consecutivo,
       resultado AS calcio_ionico,
       fecha_muestra
INTO calcio_ionico
FROM ultima_muestra_calcio_ion
WHERE fila = 1 AND (resultado < 20 OR resultado IS NULL);


-- Tabla de calcio 
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS calcio;
WITH calcio_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Calcio'),
ultima_muestra_calcio AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM calcio_limp)
SELECT identificador,
       consecutivo,
       resultado AS calcio,
       fecha_muestra
INTO calcio
FROM ultima_muestra_calcio
WHERE fila = 1;

-- Tabla de bilirrubina directa 
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS bilirrubina_directa;
WITH bilirrubina_d_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN '0.1'
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Bilirrubina directa'),
ultima_muestra_bilirrubina_d AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM bilirrubina_d_limp)
SELECT identificador,
       consecutivo,
       resultado AS bilirrubina_directa,
       fecha_muestra
INTO bilirrubina_directa
FROM ultima_muestra_bilirrubina_d
WHERE fila = 1;

-- Tabla de bilirrubina total
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS bilirrubina_total;
WITH bilirrubina_t_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '<%' THEN '0.09'
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Bilirrubina total'),
ultima_muestra_bilirrubina_t AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM bilirrubina_t_limp)
SELECT identificador,
       consecutivo,
       resultado AS bilirrubina_total,
       fecha_muestra
INTO bilirrubina_total
FROM ultima_muestra_bilirrubina_t
WHERE fila = 1;

-- Tabla de porcentaje de basófilos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS pcje_basofilos;
WITH pcje_basofilos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Basófilos %'),
ultima_muestra_pcje_basofilos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM pcje_basofilos_limp)
SELECT identificador,
       consecutivo,
       resultado AS pcje_basofilos,
       fecha_muestra
INTO pcje_basofilos
FROM ultima_muestra_pcje_basofilos
WHERE fila = 1;

-- Tabla de anisocitosis
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS anisocitosis;
WITH anisocitosis_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
	   			WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+++' THEN 3
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '-%' THEN NULL
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Anisocitosis'),
ultima_muestra_anisocitosis AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM anisocitosis_limp)
SELECT identificador,
       consecutivo,
       resultado AS anisocitosis,
       fecha_muestra
INTO anisocitosis
FROM ultima_muestra_anisocitosis
WHERE fila = 1;

-- Tabla de ancho de distribución eritrocitario (rdw)
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS rdw;
WITH rdw_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(REPLACE(REPLACE(resultado, '"', ''), '''', '') AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Ancho de distribución eritrocitario'),
ultima_muestra_rdw AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM rdw_limp)
SELECT identificador,
       consecutivo,
       resultado AS rdw,
       fecha_muestra
INTO rdw
FROM ultima_muestra_rdw
WHERE fila = 1;

-- Tabla de acantocitos
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS acantocitos;
WITH acantocitos_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           CASE
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '++' THEN 2
				WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '+' THEN 1
				ELSE 0
		   END AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'Acantocitos'),
ultima_muestra_acantocitos AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM acantocitos_limp)
SELECT identificador,
       consecutivo,
       resultado AS acantocitos,
       fecha_muestra
INTO acantocitos
FROM ultima_muestra_acantocitos
WHERE fila = 1;

-- Tabla de A-aDO2
--------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS A-aDO2;
WITH a_aDO2_limp AS (
    SELECT identificador,
           consecutivo,
           CAST(codigo_examen AS INT) AS codigo_examen,
           TRY_CAST(CASE
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE 'M%' THEN NULL
						WHEN REPLACE(REPLACE(resultado, '"', ''), '''', '') LIKE '--%' THEN NULL
						ELSE REPLACE(REPLACE(resultado, '"', ''), '''', '')
					END AS FLOAT) AS resultado,
           REPLACE(REPLACE(LOWER(unidad), '"', ''), '''', '') AS unidad,
           fecha_muestra,
           fecha_resultado
    FROM laboratorio
    WHERE examen = 'A-aDO2'),
ultima_muestra_a_aDO2 AS (
    SELECT identificador,
           consecutivo,
           resultado,
           fecha_muestra,
           ROW_NUMBER() OVER (PARTITION BY identificador, consecutivo ORDER BY fecha_muestra DESC) AS fila
    FROM a_aDO2_limp)
SELECT identificador,
       consecutivo,
       resultado AS a_aDO2,
       fecha_muestra
INTO a_aDO2
FROM ultima_muestra_a_aDO2
WHERE fila = 1;