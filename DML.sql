-- Meses de 2025
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202501,
           'Enero',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202502,
           'Febrero',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202503,
           'Marzo',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202504,
           'Abril',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202505,
           'Mayo',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202506,
           'Junio',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202507,
           'Julio',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202508,
           'Agosto',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202509,
           'Septiembre',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202510,
           'Octubre',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202511,
           'Noviembre',
           2025 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202512,
           'Diciembre',
           2025 );

-- Meses de 2026 (Hasta Mayo)
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202601,
           'Enero',
           2026 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202602,
           'Febrero',
           2026 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202603,
           'Marzo',
           2026 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202604,
           'Abril',
           2026 );
INSERT INTO TBL_MES (
   CODIGO_MES,
   NOMBRE,
   ANIO
) VALUES ( 202605,
           'Mayo',
           2026 );



INSERT INTO TBL_TARIFAS (
   CODIGO_TARIFA,
   DESCRIPCION,
   COSTO
) VALUES ( 1,
           'Tarifa Doméstica Estándar',
           100 );

INSERT INTO TBL_ESTADO_PEGUES (
   CODIGO_ESTADO,
   NOMBRE
) VALUES ( 1,
           'Activo' );
INSERT INTO TBL_ESTADO_PEGUES (
   CODIGO_ESTADO,
   NOMBRE
) VALUES ( 2,
           'Inactivo' );
INSERT INTO TBL_ESTADO_PEGUES (
   CODIGO_ESTADO,
   NOMBRE
) VALUES ( 3,
           'Suspendido por Falta de Pago' );

INSERT INTO TBL_ESTADO_CUENTAS (
   CODIGO_ESTADO,
   NOMBRE,
   DESCRIPCION
) VALUES ( 1,
           'Pendiente',
           'La factura ha sido generada pero no pagada' );
INSERT INTO TBL_ESTADO_CUENTAS (
   CODIGO_ESTADO,
   NOMBRE,
   DESCRIPCION
) VALUES ( 2,
           'Pagado',
           'El pago ha sido procesado completamente' );
INSERT INTO TBL_ESTADO_CUENTAS (
   CODIGO_ESTADO,
   NOMBRE,
   DESCRIPCION
) VALUES ( 3,
           'Atrasado',
           'El plazo de pago ha vencido' );

-- 4. Tipos de Pagos
INSERT INTO TBL_TIPO_PAGOS (
   CODIGO_TIPO_PAGO,
   NOMBRE
) VALUES ( 1,
           'Pago Único de Pegue' );
INSERT INTO TBL_TIPO_PAGOS (
   CODIGO_TIPO_PAGO,
   NOMBRE
) VALUES ( 2,
           'Mensualidad' );



COMMIT;