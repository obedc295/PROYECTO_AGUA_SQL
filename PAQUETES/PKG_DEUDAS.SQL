-- PKG_CUENTAS
-- ├── SP_GENERAR_DEUDAS_MENSUALES
-- ├── FN_CALCULAR_MESES_ADEUDADOS
-- └── FN_OBTENER_FECHA_ULTIMA_FACTURA


--- ESTE VAMOS A GENERAR LAS DEUDAS MENSUALES DE TODOS LOS USUARIO CON PEGUES ACTIVOS
-- EL CODIGO DE PEGUE ACTIVO ES (1)
--ESAS DEUDAS DEBEN DE REFLEJARSE EN LA TABLA DE CUENTAS
-- LA CUAL CONTIENE VARIOS ATRIBUTOS.

create or replace package PKG_CUENTAS as
   procedure SP_GENERAR_DEUDAS_MENSUALES (
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );


   procedure SP_REGISTRAR_CUENTA (
      P_CODIGO_PEGUE      number,
      P_CODIGO_MES        number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );



end PKG_CUENTAS;


create or replace package body PKG_CUENTAS as

   procedure SP_GENERAR_DEUDAS_MENSUALES (
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
   --- CURSOR PARA OBTENER TODOS LOS PEGUES ACTIVOS (1)
      cursor CUR_OBTENER_PEGUES is
      select A.CODIGO_PEGUE,
             B.COSTO,
             A.FECHA_INSTALACION
        from TBL_PEGUES A
       inner join TBL_TARIFAS B
      on A.CODIGO_TARIFA = B.CODIGO_TARIFA
       where A.CODIGO_ESTADO = 1;

-- VARIABLE QUE GUARDA EL REGISTRO DE CADA PEGUE
      V_OBTENER_PEGUE       CUR_OBTENER_PEGUES%ROWTYPE;

/* VARIBBLE PARA OBTENER EL MES ACTUAL, Y ASI TOMAR LA DECISION SI ES NECESARIO , CREAR UNA cuenta, porque, habra cuentas
 que ya estaran pagadas por adelantos y no será necesario crear una nueva (evitando duplicados.), o por el contrario si ya 
se llegó la fecha de pago , inicio de mes por ejemplo, es hora de generar esa nueva deuda a los que aun no han pagado.
    V_MES_ACTUAL number; tipo number, porque lo pasaré al formato de como estan registrados los códigos en la base de datos 
    codigo tipo number de ejemplo 202601 donde los primeros 4 número representan el anio, y los 2 restantes el mes.
*/
      V_MES_ACTUAL          number;
      V_CODIGO_MES          number; -- buena practica, para dejar el valor original de la ultima cuenta para logs futuros
      V_ULTIMA_CUENTA       number;
      V_CUENTAS_A_CREAR     number;
      --- para calcular los meses necesito pasar a fechas los codigos numericos, para eso
      -- necesito 2 variables más 1. fecha actual, 2. ultima cuenta.

      V_FECHA_MES_ACTUAL    date;
      V_FECHA_ULTIMA_CUENTA date;
   begin

-- obtener el mes actual.
      V_MES_ACTUAL := to_number ( TO_CHAR(
         SYSDATE,
         'YYYYMM'
      ) );
      if not PKG_VALIDACIONES.FN_MES_EXISTE(V_MES_ACTUAL) then
         PKG_VALIDACIONES.SP_GENERAR_MESES(V_MES_ACTUAL);
      end if;


-- A USAR EL CURSOR DE LOS PEGUES 
      open CUR_OBTENER_PEGUES;
      loop 
        -- OBTENER EL PEGUE Y GUARDARLO EN LA VARIBLE PARA ESO SE USA FETCH 

         fetch CUR_OBTENER_PEGUES into V_OBTENER_PEGUE;
         exit when CUR_OBTENER_PEGUES%NOTFOUND; -- SALIR CUANDO YA NO SE ENCUENTREN MÁS PEGUES.

-- ya tenemos el pegue , entonces ahora verifacamos cual es la cuenta más reciente registrada de ese pegue activo
-- si no hay ninguna tomamos la fecha de instalacion. 
         select max(CODIGO_MES)
           into V_ULTIMA_CUENTA
           from TBL_CUENTAS
          where CODIGO_PEGUE = V_OBTENER_PEGUE.CODIGO_PEGUE;

         if V_ULTIMA_CUENTA is null then
            V_ULTIMA_CUENTA := to_number ( TO_CHAR(
               V_OBTENER_PEGUE.FECHA_INSTALACION,
               'YYYYMM'
            ) );
         end if;



         V_FECHA_MES_ACTUAL := to_date ( TO_CHAR(V_MES_ACTUAL),
         'YYYYMM' );
         V_FECHA_ULTIMA_CUENTA := to_date ( TO_CHAR(V_ULTIMA_CUENTA),
         'YYYYMM' );
         V_CUENTAS_A_CREAR := TRUNC(MONTHS_BETWEEN(
            V_FECHA_MES_ACTUAL,
            V_FECHA_ULTIMA_CUENTA
         ));
         if V_CUENTAS_A_CREAR <= 0 then
            continue;
         end if;
         for I in 1..V_CUENTAS_A_CREAR loop 

    --- voy a usar el codigo de la ultima cuenta registrada , la que esta en fecha
    -- a esa le añáddo el mes correpodiente con el iterador I y lo guardado en la que esta en tipo numero. 

            V_CODIGO_MES := to_number ( TO_CHAR(
               ADD_MONTHS(
                  V_FECHA_ULTIMA_CUENTA,
                  I
               ),
               'YYYYMM'
            ) );
            insert into TBL_CUENTAS (
               CODIGO_CUENTA,
               CODIGO_PEGUE,
               CODIGO_MES,
               CODIGO_ESTADO,
               MONTO_ESPERADO
            ) values ( SEQ_CODIGO_CUENTA.nextval,
                       V_OBTENER_PEGUE.CODIGO_PEGUE,
                       V_CODIGO_MES,
                       1,
                       V_OBTENER_PEGUE.COSTO );
         end loop;
      end loop;

      close CUR_OBTENER_PEGUES;
      P_CODIGO_RESULTADO := 0;
      P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
      commit;
   exception
      when others then
         rollback;
         P_CODIGO_RESULTADO := -1;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
   end SP_GENERAR_DEUDAS_MENSUALES;




   procedure SP_REGISTRAR_CUENTA (
      P_CODIGO_PEGUE      number,
      P_CODIGO_MES        number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
      V_CODIGO_TARIFA  number;
      V_MONTO_ESPERADO number;
   begin
      select CODIGO_TARIFA
        into V_CODIGO_TARIFA
        from TBL_PEGUES
       where CODIGO_PEGUE = P_CODIGO_PEGUE;

      V_MONTO_ESPERADO := PKG_VALIDACIONES.FN_TARIFA_COSTO(V_CODIGO_TARIFA);
      insert into TBL_CUENTAS (
         CODIGO_CUENTA,
         CODIGO_PEGUE,
         CODIGO_MES,
         CODIGO_ESTADO,
         MONTO_ESPERADO
      ) values ( SEQ_CODIGO_CUENTA.nextval,
                 P_CODIGO_PEGUE,
                 P_CODIGO_MES,
                 1,
                 V_MONTO_ESPERADO );


      P_CODIGO_RESULTADO := 0;
      P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
      commit;
   exception
      when others then
         rollback;
         P_CODIGO_RESULTADO := -1;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
   end SP_REGISTRAR_CUENTA;

end PKG_CUENTAS;