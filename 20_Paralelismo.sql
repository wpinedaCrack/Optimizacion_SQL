/*1.Grado de Paralelismo*/
SET STATISTICS IO ON
SET STATISTICS TIME ON

SET DATEFORMAT DMY;
SELECT ts.Sucursal,
        tv.COD_DIA,
		tv.NUM_DOC, 
		tv.CONDICIONES, 
		tz.ZONA,
		tv2.NOM_VEND AS VENDEDOR,
		tc.NOMBRE AS CLIENTE,		
		tp.NOM_PROD,
		tl.NOM_LIN AS LINEA,
		tg.NOM_GRUP AS GRUPO,
		tvd.CANTIDAD* tvd.VALOR AS TOTAL_VENTA,
		tvd.CANTIDAD* tvd.COSTO AS TOTAL_COSTO,		
		tvd.CANTIDAD* tvd.VALOR- tvd.CANTIDAD* tvd.COSTO	AS TOTAL_UTILIDAD
FROM tblVentas tv   INNER JOIN  tblVentas_Detalle tvd  ON tv.ID = tvd.ID  
      INNER JOIN tblSucursales ts  ON tv.COD_SUC = ts.COD_SUC    COLLATE DATABASE_DEFAULT
      INNER JOIN tblClientes tc ON tv.COD_ID = tc.COD_ID        COLLATE DATABASE_DEFAULT
	  INNER JOIN tblProductos tp ON tvd.COD_PROD = tp.COD_PROD  COLLATE DATABASE_DEFAULT
	  INNER JOIN tblLineas tl ON tp.COD_LIN = tl.COD_LIN
	  INNER JOIN tblGrupos tg    ON tp.COD_GRUP = tg.COD_GRUP
	  INNER JOIN tblVendedores tv2  ON tc.COD_VEND = tv2.COD_VEND
	  INNER JOIN tblZonas tz ON tc.COD_ZON = tz.COD_ZON
WHERE TV.FECHA BETWEEN '01/01/2014' AND '31/12/2015'
OPTION (MAXDOP 1)


SET STATISTICS IO OFF
SET STATISTICS TIME OFF
  