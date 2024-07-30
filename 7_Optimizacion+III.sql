/*1.Microsoft Search ,Contains y Freetext*/
/*Es un predicado que se utiliza para buscar en columnas que contengan tipos de datos de 
tipo car�cter coincidencias exactas o aproximadas con palabras o frases.*/
SET STATISTICS IO ON
SET STATISTICS TIME ON

--DROP INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos
--CREATE INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos (NOM_PROD) WITH (DROP_EXISTING=ON)
SELECT * FROM tblProductos tp  WHERE tp.NOM_PROD LIKE '%carne%'
SELECT * FROM tblProductos tp  WHERE CONTAINS(tp.NOM_PROD,'carne')
SELECT * FROM tblProductos tp  WHERE CONTAINS(tp.NOM_PROD,N'"carne*"')

/*Se utiliza para buscar en columnas de tipo car�cter valores que coincidan con el significado 
 de la condici�n de b�squeda. Cuando se utiliza FREETEXT se separa la cadena buscada 
 internamente en palabras que son t�rminos de b�squeda y se asigna a cada uno de los t�rminos
 un peso y se buscan las coincidencias.*/
 SELECT * FROM tblProductos tp  WHERE FREETEXT(tp.NOM_PROD,'carne')
 SELECT * FROM tblProductos tp  WHERE FREETEXT(tp.NOM_PROD,'carne OR res')

SET STATISTICS IO OFF
SET STATISTICS TIME OFF