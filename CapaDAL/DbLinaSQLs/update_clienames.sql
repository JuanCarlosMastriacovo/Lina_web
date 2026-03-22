
-- Script SQL para capitalizar la inicial de cada palabra y dejar siglas como GR en mayúsculas
-- Ejecutar directamente en consola o desde Workbench

-- Paso 1: Capitalizar la inicial de cada palabra (MySQL 8+)

-- Detectar la longitud máxima de cliename
-- Reemplaza 100 por la longitud real de la columna si es diferente
SET @maxlen := 40;



-- Capitalizar la inicial de cada palabra usando REGEXP_REPLACE (MySQL 8.0.17+)
-- Esta expresión pone en mayúscula la primera letra de cada palabra y el resto en minúscula
UPDATE linaclie
SET cliename = LEFT(
	TRIM(
		REGEXP_REPLACE(
			LOWER(cliename),
			'((^|[[:space:][:punct:]])([a-záéíóúñ]))',
			UPPER(SUBSTRING('\\3',1,1))
		)
	),
	@maxlen
)
WHERE cliename IS NOT NULL AND cliename <> '';

-- Paso 2: Reemplazar siglas GR en mayúsculas en cualquier posición
UPDATE linaclie
SET cliename = REGEXP_REPLACE(cliename, '\\bGr\\b', 'GR')
WHERE cliename IS NOT NULL AND cliename <> '';
-- update_clienames.sql
-- Normaliza el campo cliename de linaclie según la política de mayúsculas utilizada en los comentarios de tablas.
-- Aplica la normalización a todos los registros existentes.

-- NOTA: Este script solo actualiza los datos existentes. Para mantener la normalización en el futuro, se recomienda crear un TRIGGER BEFORE INSERT/UPDATE.


-- Capitaliza la inicial de cada palabra y deja siglas como GR en mayúsculas
-- Esta lógica asume que las siglas GR están separadas por espacios o son palabras completas


-- NOTA: MySQL no tiene una función nativa para capitalizar cada palabra ni para detectar siglas fácilmente.
-- Si tienes muchas siglas, deberías agregar más REPLACE para cada una o usar una función definida por el usuario (UDF) o procedimiento almacenado.
-- Para lógica avanzada, se recomienda un procedimiento almacenado que recorra palabra por palabra.

-- Si la política es más compleja (por ejemplo, capitalizar cada palabra), reemplaza la lógica anterior por la adecuada.
-- Ejemplo para capitalizar cada palabra (solo para MySQL 8+):
-- UPDATE linaclie
-- SET cliename = INITCAP(cliename)
-- WHERE cliename IS NOT NULL AND cliename <> '';
