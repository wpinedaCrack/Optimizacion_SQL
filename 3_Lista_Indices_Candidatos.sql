/*Identificar claves Externas no Indexadas*/
WITH v_NonIndexedFKColumns AS (
   SELECT 
      Object_Name(a.parent_object_id) AS Table_Name
      ,b.NAME AS Column_Name
   FROM 
      sys.foreign_key_columns a
      ,sys.all_columns b
      ,sys.objects c
   WHERE 
      a.parent_column_id = b.column_id
      AND a.parent_object_id = b.object_id
      AND b.object_id = c.object_id
      AND c.is_ms_shipped = 0
   EXCEPT
   SELECT 
      Object_name(a.Object_id)
      ,b.NAME
   FROM 
      sys.index_columns a
      ,sys.all_columns b
      ,sys.objects c
   WHERE 
      a.object_id = b.object_id
      AND a.key_ordinal = 1
      AND a.column_id = b.column_id
      AND a.object_id = c.object_id 
      AND c.is_ms_shipped = 0
   )
SELECT  
  'CREATE NONCLUSTERED INDEX [IX_'+v.Table_Name + '_' + v.Column_Name + '] ON [dbo].['+v.Table_Name+'] ('+ v.Column_Name + ') WITH ( FILLFACTOR=80)' AS Indice,
  'DROP INDEX [IX_'+v.Table_Name + '_' + v.Column_Name + '] ON [dbo].['+v.Table_Name+']' AS borrarIndice,
   v.Table_Name AS NonIndexedCol_Table_Name
   ,v.Column_Name AS NonIndexedCol_Column_Name             
   ,fk.NAME AS Constraint_Name   
   ,SCHEMA_NAME(fk.schema_id) AS Ref_Schema_Name       
   ,object_name(fkc.referenced_object_id) AS Ref_Table_Name      
   ,c2.NAME AS Ref_Column_Name         
FROM 
   v_NonIndexedFKColumns v
   ,sys.all_columns c
   ,sys.all_columns c2
   ,sys.foreign_key_columns fkc
   ,sys.foreign_keys fk
WHERE 
   v.Table_Name = Object_Name(fkc.parent_object_id)
   AND v.Column_Name = c.NAME
   AND fkc.parent_column_id = c.column_id
   AND fkc.parent_object_id = c.object_id
   AND fkc.referenced_column_id = c2.column_id
   AND fkc.referenced_object_id = c2.object_id
   AND fk.object_id = fkc.constraint_object_id
ORDER BY 1,2

alter table tblEvaluacion drop constraint FK_tblEvaluacion_IdEvaluado


--CREATE CLUSTERED INDEX [IX_tblEvaluacion_Fecha] ON tblEvaluacion(Fecha) --- Indice cluster para fecha es muy bueno debido a que trae muchos registros y es mas rapido

--alter table tblEvaluacion add constraint FK_tblEvaluacion_IdEvaluado foreign key(IdEvaluador)
--references tblEvaluador(IdEvaluador)


--CREATE NONCLUSTERED INDEX [IX_tblEmpleado_IdDepartamento] ON tblEmpleado(IdDepartamento) WITH(FILLFACTOR=80) --- FILLFACTOR  campos que se usan frecuentemente en la busqueda
--CREATE NONCLUSTERED INDEX [IX_tblEmpleado_IdDepartamento] ON [dbo].[tblEmpleado] (IdDepartamento)
--DROP INDEX [IX_tblEmpleado_IdDepartamento] ON tblEmpleado


/*--------------------------------------------------------------------------------------------------------------------------------------------

tablescan ==>  No usa el Indice alerta

BUENAS PRACTICAS

Usar Exist en vez de count 

sp_help 'tblProductos'    ---buena ayuda 


Ver en mensajes las LECTURAS LOGICAS QUE USE EN ESTE CASO   logical reads 205
*/

/*1.Optimizar La busqueda A través de indices del campo NOM_PROD de la tabla tblProductos,
 Plan de Ejecución*/
--sp_help 'tblproductos'

SET STATISTICS IO ON
SET STATISTICS TIME ON
--DROP INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos
--CREATE INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos (NOM_PROD) WITH (DROP_EXISTING=ON)
--SELECT * FROM tblProductos tp WITH(INDEX(IX_TBLVENTAS_NOM_PROD)) WHERE tp.NOM_PROD LIKE '%carne%'
SELECT * FROM tblProductos tp  WHERE tp.NOM_PROD LIKE 'carne%'

SET STATISTICS IO OFF
SET STATISTICS TIME OFF




/*1.Microsoft Search ,Contains y Freetext*/
/*Es un predicado que se utiliza para buscar en columnas que contengan tipos de datos de 
tipo carácter coincidencias exactas o aproximadas con palabras o frases.*/
SET STATISTICS IO ON
SET STATISTICS TIME ON

--DROP INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos
--CREATE INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos (NOM_PROD) WITH (DROP_EXISTING=ON)
SELECT * FROM tblProductos tp  WHERE tp.NOM_PROD LIKE '%carne%'
SELECT * FROM tblProductos tp  WHERE CONTAINS(tp.NOM_PROD,'carne')
SELECT * FROM tblProductos tp  WHERE CONTAINS(tp.NOM_PROD,N'"carne*"') 

/*Se utiliza para buscar en columnas de tipo carácter valores que coincidan con el significado 
 de la condición de búsqueda. Cuando se utiliza FREETEXT se separa la cadena buscada 
 internamente en palabras que son términos de búsqueda y se asigna a cada uno de los términos
 un peso y se buscan las coincidencias.*/
 --SELECT * FROM tblProductos tp  WHERE FREETEXT(tp.NOM_PROD,'carne')
 SELECT * FROM tblProductos tp  WHERE FREETEXT(tp.NOM_PROD,'carne OR res')----- MEJOR OPCION

SET STATISTICS IO OFF
SET STATISTICS TIME OFF


/* INDICE DE COBERTURA PARA CAMPOS SELECT */
CREATE INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos (NOM_PROD) INCLUDE(COD_GRUP,COD_LIN,MARCA,COS_PROM_C,PRECIO_VTA) 
WITH  (DROP_EXISTING=ON)
SELECT * FROM tblProductos tp  WHERE tp.NOM_PROD LIKE 'carne%'

/* FORZADO DE USO DE INDICES */









--------------------------------------------------------------------------------------------------------------------------------------------

