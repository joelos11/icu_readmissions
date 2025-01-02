-- Create DATABASE
CREATE DATABASE icu_readmissions;
GO

USE icu_readmissions;
GO

-- Creación de tablas principales
------------------------------------------------------------------------------------------------------------------------------------------

-- Create table atenciones
--DROP TABLE IF EXISTS atenciones;
CREATE TABLE atenciones(
    identificador INT NOT NULL,
    consecutivo INT NOT NULL,
    fecha_ingreso DATETIME NOT NULL,
	fecha_egreso DATETIME NOT NULL,
    edad_años INT NOT NULL,
	fecha_fallece DATETIME NULL,
	dias_estancia FLOAT NOT NULL,
	CONSTRAINT PK_atenciones PRIMARY KEY(identificador, consecutivo)
);
-- Insert data en la tabla atenciones
INSERT INTO atenciones
SELECT IDENTIFICADORPROPIO, CONSECUTIVO, FECHAINGRESOT, FECHAEGRESOT, EDAD, FECHAFALLECE, DIASESTANCIA 
FROM hptu_eia_atenciones;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_atenciones;

-- Create table cie_10
--DROP TABLE IF EXISTS cie_10;
CREATE TABLE cie_10(
	id INT IDENTITY(1, 1),
	codigo_4 CHAR(4) PRIMARY KEY,
	descripcion_codigo_4 VARCHAR(255),
);
-- Insert data en la tabla cie_10
INSERT INTO cie_10
SELECT * FROM CIE10__act;
-- Eliminamos la tabla importada
DROP TABLE CIE10__act;

-- Create table diagnosticos
--DROP TABLE IF EXISTS diagnosticos;
CREATE TABLE diagnosticos(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	cod_diagnostico CHAR(4) NULL,
	tipo_diagnostico VARCHAR(20) NULL,
	CONSTRAINT FK_atenciones_diagnosticos FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo),
	CONSTRAINT FK_cie10_diagnosticos FOREIGN KEY (cod_diagnostico) REFERENCES cie_10(codigo_4)
);
-- Insert data en la tabla diagnosticos
INSERT INTO diagnosticos
SELECT * FROM hptu_eia_diagnosticos;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_diagnosticos;

-- Create table escalas
--DROP TABLE IF EXISTS escalas;
CREATE TABLE escalas(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	escala VARCHAR(100) NOT NULL,
	valor INT NOT NULL,
	CONSTRAINT FK_atenciones_escalas FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla escalas
INSERT INTO escalas
SELECT * FROM hptu_eia_escalas;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_escalas;

-- Create table glucometrias
--DROP TABLE IF EXISTS glucometrias;
CREATE TABLE glucometrias(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	valor VARCHAR(500) NULL,
	observaciones NVARCHAR(1000) NULL,
	fecha_registro DATETIME NULL,
	CONSTRAINT FK_atenciones_glucometrias FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla glucometrias
INSERT INTO glucometrias
SELECT * FROM hptu_eia_glucometrias;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_glucometrias;

-- Create table temperatura
--DROP TABLE IF EXISTS temperatura;
CREATE TABLE temperatura(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	temperatura FLOAT,
	CONSTRAINT FK_atenciones_temperatura FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla temperatura
INSERT INTO temperatura
SELECT * FROM hptu_eia_temperatura;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_temperatura;

-- Create table presion_arterial_media
--DROP TABLE IF EXISTS pam;
CREATE TABLE pam(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	pam FLOAT,
	CONSTRAINT FK_atenciones_pam FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla pam
INSERT INTO pam
SELECT * FROM hptu_eia_pam;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_pam;

-- Create table presion_arterial_sistolica
--DROP TABLE IF EXISTS pa_sistolica;
CREATE TABLE pa_sistolica(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	pa_sistolica FLOAT,
	CONSTRAINT FK_atenciones_pasistolica FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla pa_sistolica
INSERT INTO pa_sistolica
SELECT * FROM hptu_eia_pa_sistolica;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_pa_sistolica;

-- Create table presion_arterial_diastolica
--DROP TABLE IF EXISTS pa_diastolica;
CREATE TABLE pa_diastolica(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	pa_diastolica FLOAT,
	CONSTRAINT FK_atenciones_padiastolica FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla pa_diastolica
INSERT INTO pa_diastolica
SELECT * FROM hptu_eia_pa_diastolica;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_pa_diastolica;

-- Create table frecuencia_respiratoria
CREATE TABLE frec_respiratoria(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	frec_resp FLOAT,
	CONSTRAINT FK_atenciones_frec_respiratoria FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla frec_respiratoria
--DROP TABLE IF EXISTS frec_respiratoria;
INSERT INTO frec_respiratoria
SELECT * FROM hptu_eia_frec_respiratoria;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_frec_respiratoria;

-- Create table frecuencia_cardiaca
--DROP TABLE IF EXISTS frec_cardiaca;
CREATE TABLE frec_cardiaca(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	frec_card FLOAT,
	CONSTRAINT FK_atenciones_frec_cardiaca FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla frec_cardiaca
INSERT INTO frec_cardiaca
SELECT * FROM hptu_eia_frec_cardiaca;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_frec_cardiaca;

-- Create table concentracion_02_sangre
--DROP TABLE IF EXISTS spo2;
CREATE TABLE spo2(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	fecha_registro DATETIME NOT NULL,
	spo2 FLOAT,
	CONSTRAINT FK_atenciones_spo2 FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla spo2
INSERT INTO spo2
SELECT * FROM hptu_eia_spo2;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_spo2;

-- Create table laboratorio
--DROP TABLE IF EXISTS laboratorio;
CREATE TABLE laboratorio(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	codigo_examen VARCHAR(5) NOT NULL,
	examen VARCHAR(255) NOT NULL,
	resultado VARCHAR(50) NOT NULL,
	unidad VARCHAR(50) NULL,
	fecha_muestra DATETIME NULL,
	fecha_resultado DATETIME NULL,
	CONSTRAINT FK_atenciones_laboratorio FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla laboratorio
INSERT INTO laboratorio
SELECT * FROM hptu_eia_laboratorio;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_laboratorio;

-- Create table balance_liquidos
--DROP TABLE IF EXISTS balance_liquidos;
CREATE TABLE balance_liquidos(
	id INT PRIMARY KEY IDENTITY(1, 1),
	identificador INT NOT NULL,
	consecutivo INT NOT NULL,
	valor FLOAT NOT NULL,
	fecha_balance DATETIME NULL,
	CONSTRAINT FK_atenciones_balance_liq FOREIGN KEY (identificador, consecutivo) REFERENCES atenciones(identificador, consecutivo)
);
-- Insert data en la tabla balance_liquidos
INSERT INTO balance_liquidos
SELECT * FROM hptu_eia_balanceliquidos;
-- Eliminamos la tabla importada
DROP TABLE hptu_eia_balanceliquidos;