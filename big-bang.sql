USE master;
--------------- Base de Datos
DECLARE @dbname NVARCHAR(128)
SET @dbname = 'Cinema';

IF DB_ID(@dbname) IS NOT NULL
-- Eliminando conexiones existentes en la DB Cinema
BEGIN
	DECLARE @processid INT;
	SELECT  @processid = MIN(spid)
	FROM    master.dbo.sysprocesses
	WHERE   dbid = DB_ID('Cinema') 
	WHILE @processid IS NOT NULL 
		BEGIN 
			EXEC ('KILL ' + @processid) 
			SELECT  @processid = MIN(spid)
			FROM    master.dbo.sysprocesses
			WHERE   dbid = DB_ID(@dbname) 
		END
	-- Eliminando DB Cinema
	DROP DATABASE Cinema;
END

--------------- CREANDO DB Cinema
CREATE DATABASE Cinema;
GO
USE Cinema;
GO

-- SCHEMAS
CREATE SCHEMA Movie;
GO


-- Creacion de Usuario en DB Cinema
IF USER_ID('Consumidor') IS NULL
	CREATE USER Consumidor FOR LOGIN Quix
	WITH DEFAULT_SCHEMA = Media
;


--------- TABLAS
IF	OBJECT_ID('Movie.Movie') IS NULL
	AND OBJECT_ID('Movie.Reparto') IS NULL
	AND OBJECT_ID('Movie.Genero') IS NULL
	AND OBJECT_ID('Movie.Empresa') IS NULL
	AND OBJECT_ID('Movie.FG_MovieReparto') IS NULL
	AND OBJECT_ID('Movie.FG_MovieEmpresa') IS NULL
	AND OBJECT_ID('Movie.FG_MovieGenero') IS NULL
BEGIN
	CREATE TABLE Movie (
		idMovie INT PRIMARY KEY
		,Title VARCHAR(100) NOT NULL
		,Descripcion VARCHAR(500) NOT NULL
		,FechaLanzamiento DATE NOT NULL
		,Puntuacion FLOAT NOT NULL
		,Popularidad FLOAT NOT NULL
	);
	CREATE TABLE Reparto (
		idRep INT PRIMARY KEY
		,Nombre VARCHAR(100) NOT NULL
	);
	CREATE TABLE Genero (
		idGen INT PRIMARY KEY
		,Nombre VARCHAR(20) NOT NULL
	);
	CREATE TABLE Empresa (
		idEmp INT PRIMARY KEY 
		,Nombre VARCHAR(50) NOT NULL
	);


	-- ***************************************
	-- TRANSFIRIENDO DE SCHEMA
	ALTER SCHEMA Movie TRANSFER Movie;
	ALTER SCHEMA Movie TRANSFER Reparto;
	ALTER SCHEMA Movie TRANSFER Genero;
	ALTER SCHEMA Movie TRANSFER Empresa;


	-- ***************************************
	-- TABLAS FORANEAS
	CREATE TABLE Movie.FG_MovieReparto (
		idMovie INT FOREIGN KEY REFERENCES Movie.Movie(idMovie), 
		idRep INT FOREIGN KEY REFERENCES Movie.Reparto(idRep), 
		Trabajo VARCHAR(20),
		Personaje VARCHAR(100)
	);
	CREATE TABLE Movie.FG_MovieEmpresa (
		idMovie INT FOREIGN KEY REFERENCES Movie.Movie(idMovie), 
		idEmp INT FOREIGN KEY REFERENCES Movie.Empresa(idEmp)
	);
	CREATE TABLE Movie.FG_MovieGenero (
		idMovie INT FOREIGN KEY REFERENCES Movie.Movie(idMovie), 
		idGen INT FOREIGN KEY REFERENCES Movie.Genero(idGen)
	);


	-- ***************************************
	-- GENERANDO PERMISOS PARA EL USUARIO CONSUMIDOR
	GRANT SELECT ON Movie.Movie TO Consumidor;
	GRANT SELECT ON Movie.[Reparto] TO Consumidor;
	GRANT SELECT ON Movie.[Genero] TO Consumidor;
	GRANT SELECT ON Movie.[Empresa] TO Consumidor;

	PRINT 'Creacion de tablas ha sido exitosa';
END