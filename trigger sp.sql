USE Cinema;
GO
-- ***************************************
-- TRIGGERS
-- CREA Y ACTUALIZA LA VISTA Movie.vw_MovieGenero
CREATE TRIGGER tr_vwGenero_Insert
	ON [Movie].[FG_MovieGenero]
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF OBJECT_ID('Movie.vw_MovieGenero') IS NOT NULL
	BEGIN
		DROP VIEW Movie.vw_MovieGenero;
	END

	-- VISTA MOVIE Y GENERO
	EXEC('
		CREATE VIEW Movie.vw_MovieGenero AS
		SELECT
			m.idMovie,
			m.Title,
			m.Descripcion,
			m.FechaLanzamiento,
			m.Puntuacion,
			m.Popularidad,
			g.idGen,
			g.Nombre
		FROM [Movie].[Movie] AS m
		INNER JOIN [Movie].[FG_MovieGenero] AS fg
			ON fg.idMovie=m.idMovie
		INNER JOIN Movie.Genero AS g
			ON fg.idGen=g.idGen
	');
	PRINT 'Vista "Movie.vw_MovieGenero" se ha actualizado';
END
GO


-- CREA Y ACTUALIZA LA VISTA Movie.vw_MovieReparto
CREATE TRIGGER tr_vwReparto_Actualizar
	ON [Movie].[FG_MovieReparto]
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF OBJECT_ID('Movie.vw_MovieReparto') IS NOT NULL
	BEGIN
		DROP VIEW Movie.vw_MovieGenero;
	END

	-- VISTA MOVIE Y GENERO
	EXEC('
		CREATE VIEW Movie.vw_MovieReparto AS
		SELECT
			m.idMovie,
			m.Title,
			r.idRep,
			r.Nombre,
			fg.Personaje,
			fg.Trabajo
		FROM [Movie].[Movie] AS m
		INNER JOIN [Movie].[FG_MovieReparto] AS fg
			ON fg.idMovie=m.idMovie
		INNER JOIN [Movie].[Reparto] AS r
			ON r.idRep = fg.idRep
	');
	PRINT 'Vista "Movie.vw_MovieReparto" se ha actualizado';
END
GO


-- CREA Y ACTUALIZA LA VISTA Movie.vw_MovieDetalle;
CREATE TRIGGER tr_vwMovieDetalles_Actualizar
	ON [Movie].[Movie]
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN
	IF OBJECT_ID('Movie.vw_MovieDetalles') IS NOT NULL
	BEGIN
		DROP VIEW Movie.vw_MovieDetalles;
	END

	-- VISTA MOVIE Y GENERO
	EXEC('
		CREATE VIEW Movie.vw_MovieDetalles AS
		SELECT
			m.idMovie,
			m.Title,
			m.Descripcion,
			m.FechaLanzamiento,
			m.Puntuacion,
			m.Popularidad,
			g.idGen,
			g.Nombre AS Genero,
			r.idRep,
			r.Nombre AS FullName,
			fg_r.Personaje,
			fg_r.Trabajo,
			e.idEmp,
			e.Nombre AS Empresa
		FROM [Movie].[Movie] AS m
		INNER JOIN [Movie].[FG_MovieGenero] AS fg_g
			ON fg_g.idMovie=m.idMovie
		INNER JOIN Movie.Genero AS g
			ON fg_g.idGen=g.idGen
		INNER JOIN [Movie].[FG_MovieReparto] AS fg_r
			ON fg_r.idMovie=m.idMovie
		INNER JOIN [Movie].[Reparto] AS r
			ON r.idRep = fg_r.idRep
		INNER JOIN [Movie].[FG_MovieEmpresa] AS fg_e
			ON fg_e.idMovie=m.idMovie
		INNER JOIN [Movie].[Empresa] AS e
			ON fg_e.idEmp=e.idEmp
	');
	PRINT 'Vista "Movie.vw_MovieDetalles" se ha actualizado';
END
GO


-- ***************************************
--------------------------------- PROCEDIMIENTOS ALMACENADOS
-- Buscar Peliculas
CREATE PROCEDURE Movie.sp_BuscarMovie
	@title VARCHAR(100)
AS
BEGIN
	IF OBJECT_ID('Movie.vw_MovieDetalles') IS NOT NULL
	BEGIN
		SELECT 
			idMovie,
			Title,
			Descripcion,
			FechaLanzamiento,
			Puntuacion,
			Popularidad,
			idGen,
			Genero,
			idRep,
			FullName,
			Personaje,
			Trabajo,
			idEmp,
			Empresa
		FROM (
			SELECT 
				ROW_NUMBER() OVER (PARTITION BY idMovie ORDER BY idMovie) AS Contador,
				*
			FROM Movie.vw_MovieDetalles 
		) AS  r
		WHERE 
			Contador=1
			AND Title LIKE CONCAT('%', @title, '%')
		;
	END
END
GO


-- Buscar generos
CREATE PROCEDURE Movie.sp_BuscarGenero
	@genre VARCHAR(20)
AS
BEGIN
	IF OBJECT_ID('Movie.vw_MovieGenero') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT idMovie FROM Movie.vw_MovieGenero WHERE Nombre = @genre)
		BEGIN
			PRINT 'Movie no encontrado';
			RETURN;
		END

		SELECT 
			*
		FROM Movie.vw_MovieGenero 
		WHERE Nombre = @genre
	END
END
GO


-- Buscar Persona
CREATE PROCEDURE Movie.sp_BuscarPersona
	@nombre VARCHAR(50)
AS
BEGIN
	IF OBJECT_ID('Movie.vw_MovieGenero') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT idRep FROM Movie.vw_MovieReparto WHERE Nombre LIKE CONCAT('%', @nombre, '%') OR Personaje LIKE CONCAT('%', @nombre, '%'))
		BEGIN
			PRINT 'Persona no encontrado';
			RETURN;
		END

		SELECT 
			*
		FROM Movie.vw_MovieReparto AS r
		WHERE 
			Nombre LIKE CONCAT('%', @nombre, '%')
			OR Personaje LIKE CONCAT('%', @nombre, '%')
	END
END
GO


-- ***************************************
---- EJEMPLOS
EXEC Movie.sp_BuscarMovie 'godzilla';

EXEC Movie.sp_BuscarGenero 'Drama';

EXEC Movie.sp_BuscarPersona 'Batman';
EXEC Movie.sp_BuscarPersona 'Ben Affleck';