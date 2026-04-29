create or replace package PKG_PEGUES as
   procedure SP_REGISTRAR_PEGUE (
      P_CODIGO_ABONADO    number,
      P_CODIGO_TARIFA     number,
      P_UBICACION         varchar2,
      P_CODIGO_CASA       varchar2,
      P_COSTO_PEGUE       number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );



   procedure SP_ACTUALIZAR_ESTADO_PEGUE (
      P_CODIGO_PEGUE      number,
      P_CODIGO_ESTADO     number default null,
      P_CODIGO_ABONADO    number default null,
      P_CODIGO_TARIFA     number default null,
      P_UBICACION         varchar2 default null,
      P_COSTO_PEGUE       number default null,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   );




end PKG_PEGUES;



create or replace package body PKG_PEGUES as
   procedure SP_REGISTRAR_PEGUE (
      P_CODIGO_ABONADO    number,
      P_CODIGO_TARIFA     number,
      P_UBICACION         varchar2,
      P_CODIGO_CASA       varchar2,
      P_COSTO_PEGUE       number,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
   begin
      insert into TBL_PEGUES (
         CODIGO_PEGUE,
         CODIGO_ESTADO,
         CODIGO_ABONADO,
         CODIGO_TARIFA,
         UBICACION,
         CODIGO_CASA,
         COSTO_PEGUE
      ) values ( SEQ_CODIGO_PEGUE.nextval,
                 1,
                 P_CODIGO_ABONADO,
                 P_CODIGO_TARIFA,
                 P_UBICACION,
                 P_CODIGO_CASA,
                 P_COSTO_PEGUE );



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
   end;



   procedure SP_ACTUALIZAR_ESTADO_PEGUE (
      P_CODIGO_PEGUE      number,
      P_CODIGO_ESTADO     number default null,
      P_CODIGO_ABONADO    number default null,
      P_CODIGO_TARIFA     number default null,
      P_UBICACION         varchar2 default null,
      P_COSTO_PEGUE       number default null,
      P_CODIGO_RESULTADO  out number,
      P_MENSAJE_RESULTADO out varchar2
   ) as
   begin
      if not PKG_VALIDACIONES.FN_PEGUE_EXISTE(P_CODIGO_PEGUE) then
         P_CODIGO_RESULTADO := 1002;
         P_MENSAJE_RESULTADO := PKG_ERRORES.FN_MENSAJES_ERROR(P_CODIGO_RESULTADO);
         return;
      end if;



      update TBL_PEGUES
         set CODIGO_ESTADO = NVL(
         P_CODIGO_ESTADO,
         CODIGO_ESTADO
      ),
             CODIGO_ABONADO = NVL(
                P_CODIGO_ABONADO,
                CODIGO_ABONADO
             ),
             CODIGO_TARIFA = NVL(
                P_CODIGO_TARIFA,
                CODIGO_TARIFA
             ),
             COSTO_PEGUE = NVL(
                P_COSTO_PEGUE,
                COSTO_PEGUE
             ),
             UBICACION = NVL(
                P_UBICACION,
                UBICACION
             )
       where CODIGO_PEGUE = P_CODIGO_PEGUE;


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
   end SP_ACTUALIZAR_ESTADO_PEGUE;



end PKG_PEGUES;