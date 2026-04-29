create or replace package PKG_ERRORES as
   EXITO constant number := 0;
   ERR_INESPERADO constant number := -1;
   --ERRORES DE BUSQUEDA
   ERR_DUPLICADO constant number := 1001;
   ERR_NO_ENCONTRADO constant number := 1002;
   --ERRORES DE INGRESO DE DATOS
   ERR_TARIFA_INVALIDA constant number := 2001;
   ERR_MONTO_INCORRECTO constant number := 2002;

   --ERRORES DE SISTEMA
   ERR_ANULACION_LIMIT constant number := 3003;
   ERR_BATCH_CUENTAS constant number := 4001;

   --ERRORES DE CREACION / ACTUALIZACION
   ERR_CREACION constant number := 5001;
   ERR_ACTUALIZO constant number := 5002;


   ---funcion
   function FN_MENSAJES_ERROR (
      P_CODIGO_ERROR number
   ) return varchar2;

end PKG_ERRORES;


create or replace package body PKG_ERRORES as

   function FN_MENSAJES_ERROR (
      P_CODIGO_ERROR number
   ) return varchar2 as
      V_MENSAJE_RESULTADO varchar2(500);
   begin
      case P_CODIGO_ERROR
         when 0 then
            return 'OPERACION REALIZADA CON ÉXITO ';
         when -1 then
            return 'ERROR INESPERADO';
         when 1001 then
            return 'ERROR CUENTA/PAGO DUPLICADO';
         when 1002 then
            return 'ERROR REGISTRO NO ENCONTRADO';
         when 2001 then
            return 'ERROR TARIFA INVALIDA (0)';
         when 2002 then
            return 'ERROR EL MONTO A PAGAR DEBE SER MULTIPLO DE SU TARIFA. ';
         when 3003 then
            return 'ERROR NO SE PUDO EL PAGO.';
         when 4001 then
            return 'ERROR NO SE PUDO ANULAR EL PAGO';
         when 5001 then
            return 'ERROR NO SE PUDO REGISTRAR. ';
         when 5002 then
            return 'ERROR NO SE PUDO ACTUALIZAR. ';
      end case;
   end FN_MENSAJES_ERROR;


end PKG_ERRORES;