--- EL PAQUETE DE VALIDACIONES VAN  FUNCIONES QUE AYUDAN A VALIDAR DATOS
--- TAMBIEN INCLUYE PROCEDMIENTO PARA GENERAR MESES.

/*
QUE LA CUENTA EXISTA, SINO CREARLA
QUE EL MES QUE SE QUIERA AGREGAR EXISTA, SINO INSETARLOS
QUE EL PEGUE EXISTA
QUE EL ABONADO EXISTA
QUE EL ENCARGADO EXITA
QUE LA PERSONA EXITA. 
QUE LA TARIFA NO SEA 0
QUE  EL MONTO SEA POSITIVO
*/

create or replace package PKG_VALIDACIONES as
   function FN_MES_EXISTE (
      P_CODIGO_MES number
   ) return boolean; --VERIFACAR QUE EL MES EXISTA EN LA TABLA 
   function FN_PEGUE_EXISTE (
      P_CODIGO_PEGUE number
   ) return boolean; --SOLO VERIFICA SI EL PEGUE EXISTE
   function FN_PERSONA_EXISTE (
      P_CODIGO_PERSONA number
   ) return boolean;

   function FN_CASA_EXISTA (
      P_CODIGO_CASA varchar2
   ) return boolean;
   function FN_TARIFA_VALIDA (
      P_CODIGO_TARIFA number
   ) return boolean;
   function FN_MONTO_POSITIVO (
      P_MONTO number
   ) return boolean;

   function FN_FECHA_A_CODIGO (
      P_FECHA date
   ) return number;

   function FN_CODIGO_A_FECHA (
      P_CODIGO number
   ) return date;

   function FN_TARIFA_COSTO (
      P_CODIGO_TARIFA number
   ) return number;

   procedure SP_GENERAR_MESES (
      P_CODIGO_MES number
   );

   function FN_ABONADO_EXISTE (
      P_CODIGO_PERSONA number
   ) return boolean;

end PKG_VALIDACIONES;



create or replace package body PKG_VALIDACIONES as


   function FN_MES_EXISTE (
      P_CODIGO_MES number
   ) return boolean as
      V_CARNADA number;
   begin
      select CODIGO_MES
        into V_CARNADA
        from TBL_MES
       where CODIGO_MES = P_CODIGO_MES;

      return true;
   exception
      when NO_DATA_FOUND then
         return false;
   end FN_MES_EXISTE;


   function FN_PEGUE_EXISTE (
      P_CODIGO_PEGUE number
   ) return boolean as
      V_CARNADA number;
   begin
      select CODIGO_PEGUE
        into V_CARNADA
        from TBL_PEGUES
       where CODIGO_PEGUE = P_CODIGO_PEGUE;

      return true;
   exception
      when NO_DATA_FOUND then
         return false;
   end;


--SOLO VERIFICA SI EL PEGUE EXISTE

   function FN_PERSONA_EXISTE (
      P_CODIGO_PERSONA number
   ) return boolean as
      V_CARNADA number;
   begin
      select CODIGO_PERSONA
        into V_CARNADA
        from TBL_PERSONAS
       where CODIGO_PERSONA = P_CODIGO_PERSONA;

      return true;
   exception
      when NO_DATA_FOUND then
         return false;
   end;

   function FN_CASA_EXISTA (
      P_CODIGO_CASA varchar2
   ) return boolean as
      V_CARNADA number;
   begin
      select CODIGO_CASA
        into V_CARNADA
        from TBL_PEGUES
       where CODIGO_CASA = P_CODIGO_CASA;
      return true;
   exception
      when NO_DATA_FOUND then
         return false;
   end;




   function FN_TARIFA_VALIDA (
      P_CODIGO_TARIFA number
   ) return boolean as
      V_COSTO_TARIFA number;
   begin
      select COSTO
        into V_COSTO_TARIFA
        from TBL_TARIFAS
       where CODIGO_TARIFA = P_CODIGO_TARIFA;
      if V_COSTO_TARIFA > 0 then
         return true;
      else
         return false;
      end if;
   end;



   function FN_TARIFA_COSTO (
      P_CODIGO_TARIFA number
   ) return number as
      V_COSTO_TARIFA number;
   begin
      select COSTO
        into V_COSTO_TARIFA
        from TBL_TARIFAS
       where CODIGO_TARIFA = P_CODIGO_TARIFA;
      if V_COSTO_TARIFA > 0 then
         return V_COSTO_TARIFA;
      else
         return 0;
      end if;
   end;


   function FN_MONTO_POSITIVO (
      P_MONTO number
   ) return boolean as
   begin
      if P_MONTO > 0 then
         return true;
      else
         return false;
      end if;
   end;



   procedure SP_GENERAR_MESES (
      P_CODIGO_MES number
   ) as
      V_FECHA      date;
      V_NOMBRE_MES varchar2(20);
      V_ANIO       number;
   begin
--- EL CODIGO MES QUE RECIBE ESTA EN FORMATO 202601, ENTONCES EL OBJETIVO DE ESTE PROCESO ES QUE INSERTE ESE MES EN LA TABLA
--MESES POR SI NO EXISTE, USO LA FUNCION ANTERIOR QUE CREE PARA LA VERIFICACION, ESTO ES UTIL PARA CUANDO LA PERSONA QUIERA HACER POR EJEMPLO UN PAGO
-- DE MESES POR ADELANTADO Y LOS MESES NO SE ENCUENTREN EN LA BASE DE DATOS, ESTO LO DECIDI HACER ASI PARA PRACTICAR, PORQUE LA OTRA OPCION QUE PODRIA HABER
--HECHO Y AHORRAME TODAS LAS VALIDACIONES PORDRIA HABER SIDO LLENAR LOS MESES DE AQUI A 100 - 50 ANIOS, PERO ASI AHORRO ESPACIO EN LA BASE Y LA HAGO DINAMICA ESTA TABLA DE MESES.
      if FN_MES_EXISTE(P_CODIGO_MES) then 
    -- ASI EVITO DUPLICADOS
         return;
      else 
    -- COMO NO EXITE EN EL REGISTRO, ENTONCES TENERMOS QUE GENERAR EL NOMBRE Y ANIO SEGUN EL CODIGO 
    -- PARA ESO HAY QUE HACER VARIAS COSAS CON AYUDA DEL CODIGO 202601 

         V_FECHA := to_date ( TO_CHAR(P_CODIGO_MES),
         'YYYYMM' );
         V_NOMBRE_MES := TO_CHAR(
            V_FECHA,
            'FMMONTH',
            'NLS_DATE_LANGUAGE=SPANISH'
         );
         V_ANIO := to_number ( TO_CHAR(
            V_FECHA,
            'YYYY'
         ) );
         insert into TBL_MES (
            CODIGO_MES,
            NOMBRE,
            ANIO
         ) values ( P_CODIGO_MES,
                    V_NOMBRE_MES,
                    V_ANIO );

      end if;
   end;



   function FN_FECHA_A_CODIGO (
      P_FECHA date
   ) return number as
      V_RESULTADO number;
   begin
      V_RESULTADO := to_number ( TO_CHAR(
         P_FECHA,
         'YYYYMM'
      ) );
      return V_RESULTADO;
   end;

   function FN_CODIGO_A_FECHA (
      P_CODIGO number
   ) return date as
      V_RESULTADO date;
   begin
      V_RESULTADO := to_date ( TO_CHAR(P_CODIGO),
      'YYYYMM' );
      return V_RESULTADO;
   end;


   function FN_ABONADO_EXISTE (
      P_CODIGO_PERSONA number
   ) return boolean as
      V_CARNADA number;
   begin
      select CODIGO_ABONADO
        into V_CARNADA
        from TBL_ABONADOS
       where CODIGO_ABONADO = P_CODIGO_PERSONA;
      return true;
   exception
      when NO_DATA_FOUND then
         return false;
   end;





end PKG_VALIDACIONES;