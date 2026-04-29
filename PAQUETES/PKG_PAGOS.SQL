-- PKG_PAGOS
-- ├── SP_REGISTRAR_PAGO
-- ├── SP_ANULAR_PAGO
-- ├── FN_CALCULAR_MESES_A_PAGAR
-- ├── FN_OBTENER_DEUDA_PENDIENTE
-- └── PROCEDURE INTERNA (no visible externamente)



/*
--- NOTAS PARA MI Y LLEVAR UN ORDEN DE QUE PROGRAMAR, ESTE ES UN PROCESO MÁS COMPLEJO
ENTONCES DEBO DE LLEVAR UN ORDED.

EN EL FORMULARIO DE PAGO SOLO QUIERO SOLICITAR LO SIGUIENTE: 
- CODIGO DE CASA 
- MONTO A PAGAR
- IDENTIDAD DE LA PERSONA QUE ESTA PAGANDO (OPCIONAL). 
NO QUIERO NADA MÁS, EL SISTEMA DEBE SER CAPAZ DE HACER LOS SIGUIENTES CALCULOS:
- VERIFICAR PRIMERO QUE EL CODIGO DE CASA EXISTA
- EL MONTO SEA VALIDO (AUNQUE SE PUEDE VERIFOCAR DESDE EL FRONT ESO)
- CALCULAR LOS MESES QUE QUIERE PAGAR Y LOS QUE DEBE 
- REGISTRAR EN TABLA DETALLES , Y CUENTA CORRESPONDIENTE LOS PAGOS. 


*/

create or replace package PKG_PAGOS as
   procedure SP_REGISTRAR_PAGO (
      P_CODIGO_CASA       number,
      P_MONTO_A_PAGAR     number,
      P_IDENTIDAD         TBL_PERSONAS.NUMERO_IDENTIDAD%type,
      P_CODIGO_ENCARGADO  number default 1,
      P_CODIGO_TIPO_PAGO  number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2 -- si es pago unico de la instalacion del pegue (1) o pago de servicio (2).
   );

   procedure SP_ACTUALIZAR_CUENTAS (
      P_CODIGO_PEGUE      number,
      P_CODIGO_PAGO       number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );



end PKG_PAGOS;



create or replace package body PKG_PAGOS as

   procedure SP_REGISTRAR_PAGO (
      P_CODIGO_CASA       number,
      P_MONTO_A_PAGAR     number,
      P_IDENTIDAD         TBL_PERSONAS.NUMERO_IDENTIDAD%type,
      P_CODIGO_ENCARGADO  number default 1,
      P_CODIGO_TIPO_PAGO  number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
      V_CODIGO_PEGUE         number;
      V_CODIGO_TARIFA        number;
      V_COSTO_SERVICIO       number;
      V_DETALLES_A_REGISTRAR number; -- por si es mesualidad, ver cuantas son necesarios
      V_DETALLES_RESTANTES   number; -- variable para iterador en cuentas.
      V_CODIGO_PAGO          number;
   begin
      if not PKG_VALIDACIONES.FN_CASA_EXISTA(P_CODIGO_CASA) then
         P_CODIGO_RESULTADO := 1002;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
         return;
      end if;
--- recordar hacer el unique constraint entre codigo casa y codigo pegue.


-- para pago de mensualidad solo necesitamos 2 variables, pero siempre hay que verificar que ese pegue este pagado
-- entonces obtenemos el costo del pegue y verificamos cuanto vale si este quiere hacer el pago de la instalacion tipo_pago = 1

      if P_CODIGO_TIPO_PAGO = 2 then -- mensualidad
         select CODIGO_PEGUE,
                CODIGO_TARIFA
           into
            V_CODIGO_PEGUE,
            V_CODIGO_TARIFA
           from TBL_PEGUES
          where CODIGO_CASA = P_CODIGO_CASA;
         V_COSTO_SERVICIO := PKG_VALIDACIONES.FN_TARIFA_COSTO(V_CODIGO_TARIFA);
         if not PKG_VALIDACIONES.FN_TARIFA_VALIDA(V_COSTO_SERVICIO) then -- la tarifa no es valida (0)
            P_CODIGO_RESULTADO := 2001;
            P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
            return;
         end if;
      else
         select CODIGO_PEGUE, -- pago unico
                COSTO_PEGUE
           into
            V_CODIGO_PEGUE,
            V_CODIGO_TARIFA -- use la misma para no desperdiciar variables.
           from TBL_PEGUES
          where CODIGO_CASA = P_CODIGO_CASA;
         V_COSTO_SERVICIO := V_CODIGO_TARIFA;
         if V_COSTO_SERVICIO <= 0 then -- la tarifa no es valida (0)
            P_CODIGO_RESULTADO := 2001;
            P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
            return;
         end if;
      end if;


-- ya tenemos los montos minimos a pagar y ahora , vemos por ejemplo la cantidad de veces que debemos realizar las insercciones en las tablas cuentas
-- en la tabla cuenta solo voy a registrar las mensualidades, y si el pago es unico de instacion que se verifique en solo en la tabla de pagos. 
-- en la de detalles registrare las mensualidades con su respectivo cuenta. 

      V_DETALLES_A_REGISTRAR := P_MONTO_A_PAGAR / V_COSTO_SERVICIO; -- v_costo en este punto imposible que sea 0 
      if mod(
         P_MONTO_A_PAGAR,
         V_COSTO_SERVICIO
      ) != 0 then
         P_CODIGO_RESULTADO := 2002;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
         return;
      end if;

      V_CODIGO_PAGO := SEQ_CODIGO_PAGO.NEXTVAL;
      insert into TBL_PAGOS (
         CODIGO_PAGO,
         CODIGO_ENCARGADO,
         CODIGO_PERSONA_PAGA,
         CODIGO_TIPO_PAGO,
         FECHA_PAGO,
         MONTO,
         MOTIVO_MODIFICACION
      ) values ( V_CODIGO_PAGO,
                 P_CODIGO_ENCARGADO,
                 null,
                 P_CODIGO_TIPO_PAGO,
                 SYSDATE,
                 P_MONTO_A_PAGAR,
                 null );


                


    --- AHORA A REGISTRAR EN DETALLES Y ACTUALIZAR CUENTAS 

      declare
         V_CUENTAS_ACTUALES    number;
         V_CUENTAS_A_CREAR     number;
         V_ULTIMA_CUENTA       number;
         V_FECHA_ULTIMA_CUENTA date;
      begin
         select count(*)
           into V_CUENTAS_ACTUALES
           from TBL_CUENTAS
          where CODIGO_ESTADO = 1 /* PENDIENTE*/
            and CODIGO_PEGUE = V_CODIGO_PEGUE; 

        -- si la cantidad de cuentas existentes es menor a las que se quieran pagar, tenemos que crearlas
        -- para esto supangamos que el cliente tiene 5 cuentas creadas  (meses pendientes )y quiere pagar 8 
        /*
        Entonces, creamos la cuenta, y el codigo del pegue (el mismo) y el registro pendientes nuevos
        para el codigo del mes tomaré el registro más reciente de la tabla cuenta y guardare el codigo del mes en una 
        variable temporal de tipo fecha y a esta le iré añadiendo 1 mes.
        */
         if V_DETALLES_A_REGISTRAR > V_CUENTAS_ACTUALES then
            V_CUENTAS_A_CREAR := V_DETALLES_A_REGISTRAR - V_CUENTAS_ACTUALES;
            for I in 1..V_CUENTAS_A_CREAR loop
               select max(CODIGO_MES)
                 into V_ULTIMA_CUENTA
                 from TBL_CUENTAS
                where CODIGO_PEGUE = V_CODIGO_PEGUE
                  and CODIGO_ESTADO = 1;

               V_FECHA_ULTIMA_CUENTA := PKG_VALIDACIONES.FN_CODIGO_A_FECHA(V_ULTIMA_CUENTA);
               V_FECHA_ULTIMA_CUENTA := ADD_MONTHS(
                  V_FECHA_ULTIMA_CUENTA,
                  1
               );
               V_ULTIMA_CUENTA := PKG_VALIDACIONES.FN_FECHA_A_CODIGO(V_FECHA_ULTIMA_CUENTA);
               -- CREO LA CUENTA NUEVA PARA REGISTRAR EL PAGO
               PKG_CUENTAS.SP_REGISTRAR_CUENTA(
                  V_CODIGO_PEGUE,
                  V_ULTIMA_CUENTA,
                  P_CODIGO_RESULTADO,
                  P_MENSAJE_RESULTADO
               );
               if P_CODIGO_RESULTADO = 0 then
                  continue;
               else
                  P_CODIGO_RESULTADO := 5001;
                  P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
                  return;
               end if;
            end loop; -- AQUI YA ESTAN CREADAS TODAS LAS CUENTAS RESTANTES
         end if;



         -- AHORA A ACTUALIZAR TODAS LAS CUENTAS YA NOS ASEGURAMOS QUE TODAS EXISTEN. 
         PKG_PAGOS.SP_ACTUALIZAR_CUENTAS(
            V_CODIGO_PEGUE,
            V_CODIGO_PAGO,
            P_CODIGO_RESULTADO,
            P_MENSAJE_RESULTADO
         );
         if P_CODIGO_RESULTADO = 0 then
            P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
            commit;
         else
            rollback;
            P_CODIGO_RESULTADO := 5001;
            P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
            return;
         end if;

      end;

   end SP_REGISTRAR_PAGO;



   procedure SP_ACTUALIZAR_CUENTAS (
      P_CODIGO_PEGUE      number,
      P_CODIGO_PAGO       number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as

      cursor CUR_CUENTAS_A_ACTUALIZAR is
      select CODIGO_CUENTA
        from TBL_CUENTAS
       where CODIGO_PEGUE = P_CODIGO_PEGUE
         and CODIGO_ESTADO = 1
       order by 1 asc;


      V_CODIGO_CUENTA CUR_CUENTAS_A_ACTUALIZAR%ROWTYPE;
   begin
      open CUR_CUENTAS_A_ACTUALIZAR;
      loop
         fetch CUR_CUENTAS_A_ACTUALIZAR into V_CODIGO_CUENTA;
         exit when CUR_CUENTAS_A_ACTUALIZAR%NOTFOUND;
         update TBL_CUENTAS
            set
            CODIGO_ESTADO = 2
          where CODIGO_CUENTA = V_CODIGO_CUENTA.CODIGO_CUENTA;

         insert into TBL_DETALLE_PAGOS (
            CODIGO_DETALLE,
            CODIGO_CUENTA,
            CODIGO_PAGO,
            DESCRIPCION
         ) values ( SEQ_CODIGO_DETALLE.nextval,
                    V_CODIGO_CUENTA.CODIGO_CUENTA,
                    P_CODIGO_PAGO,
                    'PAGO REGISTRADO. ' );

      end loop;

      close CUR_CUENTAS_A_ACTUALIZAR;
      if sql%ROWCOUNT > 0 then
         P_CODIGO_RESULTADO := 0;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
      else
         P_CODIGO_RESULTADO := 5002;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
      end if;

   end;

end PKG_PAGOS;