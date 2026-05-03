-- PKG_PERSONAS
-- ├── SP_REGISTRAR_PERSONA
-- ├── SP_ACTUALIZAR_PERSONA
-- ├── FN_OBTENER_DATOS_PERSONA
-- └

create or replace package PKG_PERSONAS as
   procedure SP_REGISTRAR_PERSONA (
      P_NOMBRE            TBL_PERSONAS.NOMBRE%type,
      P_APELLIDO          TBL_PERSONAS.APELLIDO%type,
      P_IDENTIDAD         TBL_PERSONAS.NUMERO_IDENTIDAD%type default null,
      P_TELEFONO          TBL_PERSONAS.TELEFONO%type default null,
      P_CORREO            TBL_PERSONAS.CORREO%type default null,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );
   procedure SP_ACTUALIZAR_PERSONA (
      P_CODIGO            number,
      P_NOMBRE            TBL_PERSONAS.NOMBRE%type default null,
      P_APELLIDO          TBL_PERSONAS.APELLIDO%type default null,
      P_IDENTIDAD         TBL_PERSONAS.NUMERO_IDENTIDAD%type default null,
      P_TELEFONO          TBL_PERSONAS.TELEFONO%type default null,
      P_CORREO            TBL_PERSONAS.CORREO%type default null,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );
end PKG_PERSONAS;
create or replace package body PKG_PERSONAS as


   procedure SP_REGISTRAR_PERSONA (
      P_NOMBRE            TBL_PERSONAS.NOMBRE%type,
      P_APELLIDO          TBL_PERSONAS.APELLIDO%type,
      P_IDENTIDAD         TBL_PERSONAS.NUMERO_IDENTIDAD%type default null,
      P_TELEFONO          TBL_PERSONAS.TELEFONO%type default null,
      P_CORREO            TBL_PERSONAS.CORREO%type default null,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
   begin
      insert into TBL_PERSONAS (
         CODIGO_PERSONA,
         NOMBRE,
         APELLIDO,
         NUMERO_IDENTIDAD,
         TELEFONO,
         CORREO
      ) values ( SEQ_CODIGO_PERSONA.nextval,
                 P_NOMBRE,
                 P_APELLIDO,
                 P_IDENTIDAD,
                 P_TELEFONO,
                 P_CORREO );


      if sql%ROWCOUNT > 0 then
         P_CODIGO_RESULTADO := 0;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
         commit;
      else
         P_CODIGO_RESULTADO := 5001;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
      end if;


   exception
      when others then
         rollback;
         P_CODIGO_RESULTADO := -1;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
   end SP_REGISTRAR_PERSONA;


   procedure SP_ACTUALIZAR_PERSONA (
      P_CODIGO            number,
      P_NOMBRE            TBL_PERSONAS.NOMBRE%type default null,
      P_APELLIDO          TBL_PERSONAS.APELLIDO%type default null,
      P_IDENTIDAD         TBL_PERSONAS.NUMERO_IDENTIDAD%type default null,
      P_TELEFONO          TBL_PERSONAS.TELEFONO%type default null,
      P_CORREO            TBL_PERSONAS.CORREO%type default null,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
   begin
      if not PKG_VALIDACIONES.FN_PEGUE_EXISTE(P_CODIGO) then
         P_CODIGO_RESULTADO := 1002;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
         return;
      end if;
      update TBL_PERSONAS
         set NOMBRE = NVL(
         P_NOMBRE,
         NOMBRE
      ),
             APELLIDO = NVL(
                P_APELLIDO,
                APELLIDO
             ),
             NUMERO_IDENTIDAD = NVL(
                P_IDENTIDAD,
                NUMERO_IDENTIDAD
             ),
             TELEFONO = NVL(
                P_TELEFONO,
                TELEFONO
             ),
             CORREO = NVL(
                P_CORREO,
                CORREO
             )
       where CODIGO_PERSONA = P_CODIGO;

      if sql%ROWCOUNT > 0 then
         P_CODIGO_RESULTADO := 0;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
         commit;
      else
         P_CODIGO_RESULTADO := 5002;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
      end if;


   exception
      when others then
         rollback;
         P_CODIGO_RESULTADO := -1;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
   end SP_ACTUALIZAR_PERSONA;

end PKG_PERSONAS;