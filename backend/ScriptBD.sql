ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE DATABASE db_prueba31082022;
USE db_prueba31082022;

CREATE TABLE if not exists persona (
	p_id			INT	AUTO_INCREMENT 	NOT NULL,	CONSTRAINT pk_pid PRIMARY KEY(p_id),
	p_nombre       	VARCHAR(150) 		NOT NULL,
	p_apellido     	VARCHAR(150),
	p_telefono      VARCHAR(25),
	p_direccion    	VARCHAR(150),
	p_fechaNace    	VARCHAR(150),
	p_datPerRelv   	VARCHAR(250),
	p_usuario       VARCHAR(150), 		UNIQUE KEY p_usuario (p_usuario),
	p_password      VARCHAR(150)
);

CREATE TABLE if not exists logro_academico (
	l_id			INT	AUTO_INCREMENT 	NOT NULL,	CONSTRAINT pk_lid PRIMARY KEY(l_id),
	l_titulo      	VARCHAR(250),
	l_year     		INT,
	l_institucion   VARCHAR(250),
	l_infopertnt    VARCHAR(250)
);

CREATE TABLE if not exists area_desempenio (
	a_id			INT	AUTO_INCREMENT 	NOT NULL,	CONSTRAINT pk_aid PRIMARY KEY(a_id),
	a_nombre      	VARCHAR(250),		UNIQUE KEY a_nombre (a_nombre)
);

CREATE TABLE persona_logro (
    pl_id 	INT 	AUTO_INCREMENT NOT NULL,		CONSTRAINT pk_plid PRIMARY KEY(pl_id),
	pl_pid INT, CONSTRAINT fk_plpid FOREIGN KEY (pl_pid) REFERENCES persona(p_id),
    pl_lid INT, CONSTRAINT fk_pllid FOREIGN KEY (pl_lid) REFERENCES logro_academico(l_id)
);

CREATE TABLE persona_area (
    pa_id 	INT 	AUTO_INCREMENT NOT NULL,		CONSTRAINT pk_paid PRIMARY KEY(pa_id),
	pa_pid INT, CONSTRAINT fk_papid FOREIGN KEY (pa_pid) REFERENCES persona(p_id),
    pa_aid INT, CONSTRAINT fk_paaid FOREIGN KEY (pa_aid) REFERENCES area_desempenio(a_id)
);



# CREAR EL PROCEDIMIENTO REGISTRO FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS REGISTRO
(
    p_nombre       VARCHAR(150), p_apellido     VARCHAR(150), p_telefono     VARCHAR(25),
    p_direccion    VARCHAR(150), p_fechaNace    VARCHAR(25), p_datPerRelv   VARCHAR(250),
    p_usuario      VARCHAR(150), p_password     VARCHAR(150)
)
BEGIN
    INSERT INTO persona VALUES (p_id,p_nombre,p_apellido,p_telefono,p_direccion,p_fechaNace,p_datPerRelv,p_usuario,p_password);
END 

# CREAR EL PROCEDIMIENTO LOGUIN FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS LOGUIN
(
    p_usuario      VARCHAR(150), p_password     VARCHAR(150)
)
BEGIN
	DECLARE EXISTEUSER INT DEFAULT 0;
	SELECT  COUNT(p_usuario) INTO EXISTEUSER FROM  persona WHERE ((p_usuario  = persona.p_usuario) AND (p_password  = persona.p_password));
    SELECT EXISTEUSER;
END 

# CREAR EL PROCEDIMIENTO ACTUALIZAR DATOS PERSONALES FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS UDP
(
    p_nombre       VARCHAR(150), p_apellido     VARCHAR(150), p_telefono     VARCHAR(25),
    p_direccion    VARCHAR(150), p_fechaNace    VARCHAR(25), p_datPerRelv   VARCHAR(250),
    p_usuario      VARCHAR(150), p_password     VARCHAR(150)
)
BEGIN
	UPDATE persona AS P SET P.p_nombre = p_nombre, P.p_direccion = p_direccion, P.p_usuario = p_usuario,
		P.p_apellido = p_apellido, P.p_fechaNace = p_fechaNace, P.p_password = p_password, P.p_telefono = p_telefono,
		P.p_datPerRelv = p_datPerRelv  WHERE (P.p_usuario = p_usuario);
END 

# CREAR EL PROCEDIMIENTO AGREGAR LOGRO FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS ADDLOGRO
(
    p_usuario      VARCHAR(150), l_titulo		VARCHAR(250), l_year	INT,
    l_institucion  VARCHAR(250), l_infopertnt   VARCHAR(250)
)
BEGIN
	INSERT IGNORE INTO logro_academico VALUES (l_id,l_titulo,l_year,l_institucion,l_infopertnt);
	INSERT INTO persona_logro VALUES (
		pl_id,(SELECT p_id FROM persona WHERE persona.p_usuario = p_usuario),
		(SELECT l_id FROM logro_academico AS L WHERE (  (L.l_titulo  = l_titulo) AND (L.l_year = l_year) AND (L.l_institucion = l_institucion) ) )
	);
	SELECT * FROM logro_academico;
	SELECT * FROM persona_logro;
END  

# CREAR EL PROCEDIMIENTO ELIMINAR LOGRO FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS DELLOGRO
(
    p_usuario      VARCHAR(150), l_titulo		VARCHAR(250), l_year	INT,
    l_institucion  VARCHAR(250), l_infopertnt   VARCHAR(250)
)
BEGIN
	DELETE FROM persona_logro WHERE (
		( 	(SELECT p_id FROM persona WHERE persona.p_usuario = p_usuario) = persona_logro.pl_pid) AND
		(	(SELECT l_id FROM logro_academico AS L WHERE (  (L.l_titulo  = l_titulo) AND (L.l_year = l_year) AND (L.l_institucion = l_institucion) ) ) = persona_logro.pl_lid )
	);
	DELETE FROM logro_academico AS L WHERE (  (L.l_titulo  = l_titulo) AND (L.l_year = l_year) AND (L.l_institucion = l_institucion) );
	SELECT * FROM logro_academico;
	SELECT * FROM persona_logro;
END  

# CREAR EL PROCEDIMIENTO AGREGAR AREA FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS ADDAREA
(
    p_usuario      VARCHAR(150), a_nombre      	VARCHAR(250)
)
BEGIN
	INSERT IGNORE INTO area_desempenio VALUES (a_id,a_nombre);
	INSERT INTO persona_area VALUES (
		pa_id,(SELECT p_id FROM persona WHERE persona.p_usuario = p_usuario),
		(SELECT a_id  FROM area_desempenio AS A WHERE (A.a_nombre  = a_nombre) )
	);
	SELECT * FROM area_desempenio;
	SELECT * FROM persona_area;
END 

# CREAR EL PROCEDIMIENTO ELIMINAR AREA FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS DELLAREA
(
    p_usuario      VARCHAR(150), a_nombre      	VARCHAR(250)
)
BEGIN
	DELETE FROM persona_area WHERE (
		( 	(SELECT p_id FROM persona WHERE persona.p_usuario = p_usuario) = persona_area.pa_pid) AND
		(	(SELECT a_id FROM area_desempenio AS A WHERE (A.a_nombre = a_nombre) ) = persona_area.pa_aid )
	);
	SELECT * FROM area_desempenio;
	SELECT * FROM persona_area;
END 

# CREAR EL PROCEDIMIENTO AREAS FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS CONSAREAS()
BEGIN
	SELECT pa_aid AS 'COD. AREA', 
		(SELECT a_nombre FROM area_desempenio AS a WHERE pa_aid = a.a_id) AS 'AREA REGISTRADA', 
		COUNT(pa_pid) AS 'CANTIDAD DE PERSONAS' FROM persona_area GROUP BY pa_aid;
END

# CREAR EL PROCEDIMIENTO GRADO FUNCIONALIDAD--------------------------------------------------------------------------
CREATE PROCEDURE IF NOT EXISTS CONSGRADO()
BEGIN
	SELECT pl_pid, p_usuario,p_nombre,p_apellido, pl_lid,l_titulo,l_year,l_institucion,l_infopertnt
		FROM persona_logro AS pl, persona AS p, logro_academico AS l
		WHERE (pl_pid = p.p_id) AND (pl_lid = l.l_id) 
		ORDER BY l_year DESC;
END 

ALTER TABLE persona ADD INDEX (p_usuario);
ALTER TABLE persona ADD INDEX (p_password);
	
# Loguin: user y password
# Actualizar datos personales
# Agregar o quitar logros academicos
# Agregar o quitar area de desempenio
# Actualizar datos academicos
# Actualizar area de desempenio

# Vista: pesonas registradas y ultimo grado academico con info de grado
# Vista: areas registradas y numero de personas en cada area

DROP TABLE users; 
CREATE TABLE users (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  email varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  password varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY email (email)
 ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS persona_logro;
DROP TABLE IF EXISTS persona_area;
DROP TABLE IF EXISTS persona;
DROP TABLE IF EXISTS logro_academico;
DROP TABLE IF EXISTS area_desempenio;
DROP PROCEDURE IF EXISTS REGISTRO;
DROP PROCEDURE IF EXISTS LOGUIN;
DROP PROCEDURE IF EXISTS UDP;
DROP PROCEDURE IF EXISTS ADDLOGRO;
DROP PROCEDURE IF EXISTS DELLOGRO;
DROP PROCEDURE IF EXISTS ADDAREA;
DROP PROCEDURE IF EXISTS DELLAREA;
DROP PROCEDURE IF EXISTS CONSGRADO;
DROP PROCEDURE IF EXISTS CONSAREAS;

CALL REGISTRO("a", "aa", "12345678", "direccion 1", "01/01/2020", "dato personal 1", "us1", "pass1"); 
CALL REGISTRO("b", "bb", "00000000", "direccion 2", "02/01/2020", "dato personal 2", "us2", "pass1"); 
CALL REGISTRO("c", "cc", "87654321", "direccion 3", "03/01/2020", "dato personal 3", "us3", "pass1"); 
SELECT * FROM persona;

CALL LOGUIN("us1", "pass1");

CALL UDP("b", "bb", "00000000", "direccion 2", "02/01/2020", "dato personal 2", "us2", "pass2"); 
SELECT * FROM persona;

CALL ADDLOGRO("us1", "Inge1", 2001, "USAC", "info");
CALL ADDLOGRO("us1", "Inge2", 2002, "USAC", "info");
CALL ADDLOGRO("us2", "Lic1", 2001, "USAC", "info");
CALL ADDLOGRO("us3", "Lic1", 2002, "USAC", "info");
CALL ADDLOGRO("us2", "Inge1", 2003, "USAC", "info");
SELECT * FROM logro_academico;
SELECT * FROM persona_logro;

CALL DELLOGRO("us2", "Inge1", 2003, "USAC", "info");
SELECT * FROM logro_academico;
SELECT * FROM persona_logro;

CALL ADDAREA("us1", "pscicologo1"); 
CALL ADDAREA("us1", "pscicologo2");
CALL ADDAREA("us1", "pscicologo3");
CALL ADDAREA("us2", "pscicologo2");
CALL CONSAREAS();

CALL DELLAREA("us2", "pscicologo2"); 
CALL CONSAREAS();

CALL CONSAREAS(); 

CALL CONSGRADO(); 


