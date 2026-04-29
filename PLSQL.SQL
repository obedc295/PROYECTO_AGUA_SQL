create or replace procedure SP_REGISTRAR_PERSONA (
   P_CODIGO_PERSONA    out number,
   P_NOMBRE            varchar2 default null,
   P_APELLIDO          varchar2 default null,
   P_NUMERO_IDENTIDAD  varchar2 default null,
   P_TELEFONO          varchar2 default null,
   P_CORREO            varchar2 default null,
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2
) as
begin
   P_CODIGO_PERSONA := SEQ_CODIGO_PERSONA.NEXTVAL;
   insert into TBL_PERSONAS (
      CODIGO_PERSONA,
      NOMBRE,
      APELLIDO,
      NUMERO_IDENTIDAD,
      TELEFONO,
      CORREO
   ) values ( P_CODIGO_PERSONA,
              P_NOMBRE,
              P_APELLIDO,
              P_NUMERO_IDENTIDAD,
              P_TELEFONO,
              P_CORREO );

   P_MENSAJE_RESULTADO := 'PERSONA CON NOMBRE: '
                          || P_NOMBRE
                          || ' y ID: '
                          || P_NUMERO_IDENTIDAD
                          || ' REGISTRADA CORRECTAMENTE.';
   P_CODIGO_RESULTADO := 0;
exception
   when DUP_VAL_ON_INDEX then
      P_CODIGO_RESULTADO := 1;
      P_MENSAJE_RESULTADO := 'ERROR: EL NÚMERO DE IDENTIDAD O CORREO YA EXISTEN. ';
   when others then
      P_CODIGO_RESULTADO := -1;
      P_MENSAJE_RESULTADO := 'ERROR INESPERADO: ' || SQLERRM;
end SP_REGISTRAR_PERSONA;



create or replace procedure SP_ACTUALIZAR_PERSONA (
   P_CODIGO_PERSONA    number,
   P_NOMBRE            varchar2 default null,
   P_APELLIDO          varchar2 default null,
   P_NUMERO_IDENTIDAD  varchar2 default null,
   P_TELEFONO          varchar2 default null,
   P_CORREO            varchar2 default null,
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2
) as
begin
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
             P_NUMERO_IDENTIDAD,
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
    where CODIGO_PERSONA = P_CODIGO_PERSONA;

   if sql%ROWCOUNT > 0 then
      P_CODIGO_RESULTADO := 0;
      P_MENSAJE_RESULTADO := 'PERSONA ACTUALIZADA CORRECTAMENTE. ';
   else
      P_CODIGO_RESULTADO := 1;
      P_MENSAJE_RESULTADO := 'ERROR: NO SE ENCONTRÓ UNA PERSONA CON ESE CÓDIGO. ';
   end if;

exception
   when others then
      P_CODIGO_RESULTADO := 1;
      P_MENSAJE_RESULTADO := 'ERROR AL ACTUALIZAR: ' || SQLERRM;
end SP_ACTUALIZAR_PERSONA;



create or replace procedure SP_REGISTRAR_PEGUE (
   P_CODIGO_ABONADO    number,
   P_CODIGO_TARIFA     number,
   P_UBICACION         varchar2,
   P_CODIGO_CASA       varchar2,
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2,
   P_COSTO_PEGUE       number
) as
   V_CODIGO_PEGUE number;
begin
   V_CODIGO_PEGUE := SEQ_CODIGO_PEGUE.NEXTVAL;
   insert into TBL_PEGUES (
      CODIGO_PEGUE,
      CODIGO_ESTADO,
      CODIGO_ABONADO,
      CODIGO_TARIFA,
      UBICACION,
      CODIGO_CASA,
      COSTO_PEGUE
   ) values ( V_CODIGO_PEGUE,
              1,
              P_CODIGO_ABONADO,
              P_CODIGO_TARIFA,
              P_UBICACION,
              P_CODIGO_CASA,
              P_COSTO_PEGUE );

   insert into TBL_ABONADOS ( CODIGO_ABONADO )
      select P_CODIGO_ABONADO
        from DUAL
       where not exists (
         select 1
           from TBL_ABONADOS
          where CODIGO_ABONADO = P_CODIGO_ABONADO
      );


   P_MENSAJE_RESULTADO := 'PEGUE '
                          || V_CODIGO_PEGUE
                          || ' CREADO CON EXITO. ';
   P_CODIGO_RESULTADO := 0;
exception
   when others then
      P_CODIGO_RESULTADO := -1;
      P_MENSAJE_RESULTADO := 'ERROR AL CREAR PEGUE: ' || SQLERRM;
end SP_REGISTRAR_PEGUE;



create or replace procedure SP_ACTUALIZAR_ESTADO_PEGUE (
   P_CODIGO_PEGUE      number,
   P_CODIGO_ESTADO     number default null,
   P_CODIGO_ABONADO    number default null,
   P_CODIGO_TARIFA     number default null,
   P_UBICACION         varchar2 default null,
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2,
   P_COSTO_PEGUE       number default null
) as
begin
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
      P_MENSAJE_RESULTADO := 'INFORMACION DEL PEGUE ACTUALIZADA CORRECTAMENTE. ';
   else
      P_CODIGO_RESULTADO := 1;
      P_MENSAJE_RESULTADO := 'NO SE PUDO ACTUALIZAR. ';
   end if;

exception
   when others then
      P_CODIGO_RESULTADO := -1;
      P_MENSAJE_RESULTADO := 'ERROR AL ACTUALIZAR: ' || SQLERRM;
end SP_ACTUALIZAR_ESTADO_PEGUE;



--=============================
--GESTION DE PAGOS Y CUENTAS
--=============================

create or replace procedure SP_REGISTRAR_PAGO (
   P_CODIGO_CASA       varchar2,
   P_CODIGO_ENCARGADO  number,
   P_CODIGO_PERSONA    number default null,
   P_CODIGO_TIPO_PAGO  number,
   P_MONTO_PAGADO      number,
   P_DESCRIPCION       varchar2,
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2
) as
   V_CODIGO_PEGUE    number;
   V_CODIGO_PAGO     TBL_PAGOS.CODIGO_PAGO%type;
   V_ULTIMO_MES_ID   number;
   V_MONTO_MINIMO    number;
   V_MESES_A_PAGAR   number;
   V_CODIGO_DETALLE  number;
   V_CODIGO_CUENTA   number;
   V_EXISTE_MES      number;
   V_MESES_RESTANTES number;
begin
   select CODIGO_PEGUE
     into V_CODIGO_PEGUE
     from TBL_PEGUES
    where CODIGO_CASA = P_CODIGO_CASA;

---- COSTO TARIFA 
   select B.COSTO
     into V_MONTO_MINIMO
     from TBL_PEGUES A
    inner join TBL_TARIFAS B
   on A.CODIGO_TARIFA = B.CODIGO_TARIFA
    where A.CODIGO_PEGUE = V_CODIGO_PEGUE;

   if V_MONTO_MINIMO = 0 then
      P_CODIGO_RESULTADO := -2;
      P_MENSAJE_RESULTADO := 'ERROR: TARIFA INVALIDA (0).';
      return;
   end if;
    

    ---VAMOS A CALCULAR CUANTOS MESES QUIERE PAGAR CON EL MONTO MINIMO
   V_MESES_A_PAGAR := P_MONTO_PAGADO / V_MONTO_MINIMO;
   V_MESES_RESTANTES := V_MESES_A_PAGAR;
    
    --- CALCULAR CUANTOS MESES DEBE 

   if mod(
      P_MONTO_PAGADO,
      V_MONTO_MINIMO
   ) != 0 then
      P_CODIGO_RESULTADO := 11;
      P_MENSAJE_RESULTADO := 'EL MONTO NO COINCIDE CON LA TARIFA. ';
      return;
   end if;


   V_CODIGO_PAGO := SEQ_CODIGO_PAGO.NEXTVAL;
   insert into TBL_PAGOS (
      CODIGO_PAGO,
      CODIGO_ENCARGADO,
      CODIGO_PERSONA_PAGA,
      CODIGO_TIPO_PAGO,
      FECHA_PAGO,
      MONTO
   ) values ( V_CODIGO_PAGO,
              P_CODIGO_ENCARGADO,
              P_CODIGO_PERSONA,
              P_CODIGO_TIPO_PAGO,
              SYSDATE,
              P_MONTO_PAGADO );



    -- AHORA EN DETALLE CUENTA REGISTRAR LOS PAGOS. 
   for R in (
      select CODIGO_CUENTA
        from (
         select CODIGO_CUENTA
           from TBL_CUENTAS
          where CODIGO_PEGUE = V_CODIGO_PEGUE
            and CODIGO_ESTADO = 1
          order by CODIGO_MES asc
      )
       where rownum <= V_MESES_A_PAGAR
   ) loop
      V_CODIGO_DETALLE := SEQ_CODIGO_DETALLE.NEXTVAL;
      insert into TBL_DETALLE_PAGOS (
         CODIGO_DETALLE,
         CODIGO_CUENTA,
         CODIGO_PAGO,
         DESCRIPCION
      ) values ( V_CODIGO_DETALLE,
                 R.CODIGO_CUENTA,
                 V_CODIGO_PAGO,
                 P_DESCRIPCION );

      update TBL_CUENTAS
         set
         CODIGO_ESTADO = 2
       where CODIGO_CUENTA = R.CODIGO_CUENTA;

      V_MESES_RESTANTES := V_MESES_RESTANTES - 1;
   end loop;

--- AQUI SE PAGAN LOS MESES, ADELATADOS
   if V_MESES_RESTANTES > 0 then
      select max(CODIGO_MES)
        into V_ULTIMO_MES_ID
        from TBL_CUENTAS
       where CODIGO_PEGUE = V_CODIGO_PEGUE;

      if V_ULTIMO_MES_ID is null then
         V_ULTIMO_MES_ID := to_number ( TO_CHAR(
            SYSDATE,
            'YYYYMM'
         ) );
      end if;



      for I in 1..V_MESES_RESTANTES loop
         V_ULTIMO_MES_ID := to_number ( TO_CHAR(
            ADD_MONTHS(
               to_date(TO_CHAR(V_ULTIMO_MES_ID),
                       'YYYYMM'),
               1
            ),
            'YYYYMM'
         ) );


         V_CODIGO_CUENTA := SEQ_CODIGO_CUENTA.NEXTVAL;
         select count(*)
           into V_EXISTE_MES
           from TBL_MES
          where CODIGO_MES = V_ULTIMO_MES_ID;


--- AQUI INSETAMOS EN LA TABLA MESES LOS MESES ADELANTADOS POR SI NO EXISTEN.
         if V_EXISTE_MES = 0 then
            insert into TBL_MES (
               CODIGO_MES,
               NOMBRE,
               ANIO
            ) values ( V_ULTIMO_MES_ID,
                       TO_CHAR(
                          to_date(TO_CHAR(V_ULTIMO_MES_ID),
                               'YYYYMM'),
                          'FMMONTH',
                          'NLS_DATE_LANGUAGE=SPANISH'
                       ),
                       TO_CHAR(
                          to_date(TO_CHAR(V_ULTIMO_MES_ID),
                               'YYYYMM'),
                          'YYYY'
                       ) );
         end if;

         insert into TBL_CUENTAS (
            CODIGO_CUENTA,
            CODIGO_PEGUE,
            CODIGO_MES,
            CODIGO_ESTADO,
            MONTO_ESPERADO
         ) values ( V_CODIGO_CUENTA,
                    V_CODIGO_PEGUE,
                    V_ULTIMO_MES_ID,
                    2,
                    V_MONTO_MINIMO );

         insert into TBL_DETALLE_PAGOS (
            CODIGO_DETALLE,
            CODIGO_CUENTA,
            CODIGO_PAGO,
            DESCRIPCION
         ) values ( SEQ_CODIGO_DETALLE.nextval,
                    V_CODIGO_CUENTA,
                    V_CODIGO_PAGO,
                    'ADELANTO: ' || P_DESCRIPCION );
      end loop;
   end if;



   P_CODIGO_RESULTADO := 0;
   P_MENSAJE_RESULTADO := 'PAGO REGISTRADO CON EXITO. RECIBO # ' || V_CODIGO_PAGO;
exception
   when NO_DATA_FOUND then
      P_CODIGO_RESULTADO := 404;
      P_MENSAJE_RESULTADO := 'ERROR: NO SE ENCONTRO EL PEGUE O TARIFA PARA LA CASA' || P_CODIGO_CASA;
   when others then
      P_CODIGO_RESULTADO := -1;
      P_MENSAJE_RESULTADO := 'ERROR AL REGISTRAR PAGO. ' || SQLERRM;
end SP_REGISTRAR_PAGO;



create or replace procedure SP_ANULAR_PAGO (
   P_CODIGO_ENCARGADO  number,
   P_CODIGO_PERSONA    number default null,
   P_CODIGO_TIPO_PAGO  number,
   P_CODIGO_CASA       varchar2,
   P_MONTO             number,
   P_MOTIVO            varchar2,
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2
) as
   V_CODIGO_PEGUE   number;
   V_COSTO_TARIFA   number;
   V_MESES_A_ANULAR number;
   V_MESES_PAGADOS  number;
   V_CODIGO_PAGO    number;
begin 
--- IDENTIFICAMOS EL PEGUE AL CUAL LE ANULAREMOS EL PAGO.
   select CODIGO_PEGUE
     into V_CODIGO_PEGUE
     from TBL_PEGUES
    where CODIGO_CASA = P_CODIGO_CASA;

   V_CODIGO_PAGO := SEQ_CODIGO_PAGO.NEXTVAL;
   select A.COSTO
     into V_COSTO_TARIFA
     from TBL_TARIFAS A
    inner join TBL_PEGUES B
   on A.CODIGO_TARIFA = B.CODIGO_TARIFA
    where B.CODIGO_PEGUE = V_CODIGO_PEGUE;

   if V_COSTO_TARIFA = 0 then
      P_CODIGO_RESULTADO := -2;
      P_MENSAJE_RESULTADO := 'ERROR: TARIFA INVALIDA (0).';
      return;
   end if;

   V_MESES_A_ANULAR := TRUNC(P_MONTO / V_COSTO_TARIFA);
   select count(*)
     into V_MESES_PAGADOS
     from TBL_CUENTAS
    where CODIGO_PEGUE = V_CODIGO_PEGUE
      and CODIGO_ESTADO = 2;

   if V_MESES_PAGADOS < V_MESES_A_ANULAR then
      P_CODIGO_RESULTADO := 14;
      P_MENSAJE_RESULTADO := 'LA CANTIDAD DE MESES A ANULAR ES MAYOR A LOS PAGOS. ';
      return;
   end if;

    --- INSERT A PAGOS
   insert into TBL_PAGOS (
      CODIGO_PAGO,
      CODIGO_ENCARGADO,
      CODIGO_PERSONA_PAGA,
      CODIGO_TIPO_PAGO,
      FECHA_PAGO,
      MONTO
   ) values ( V_CODIGO_PAGO,
              P_CODIGO_ENCARGADO,
              P_CODIGO_PERSONA,
              P_CODIGO_TIPO_PAGO,
              SYSDATE,
              - P_MONTO );


   for R in (
      select CODIGO_CUENTA
        from (
         select CODIGO_CUENTA,
                row_number()
                over(
                    order by CODIGO_MES desc
                ) as RN
           from TBL_CUENTAS
          where CODIGO_PEGUE = V_CODIGO_PEGUE
            and CODIGO_ESTADO = 2
      )
       where RN <= V_MESES_A_ANULAR
   ) loop
      update TBL_CUENTAS
         set
         CODIGO_ESTADO = 1
       where CODIGO_CUENTA = R.CODIGO_CUENTA;


      insert into TBL_DETALLE_PAGOS (
         CODIGO_DETALLE,
         CODIGO_CUENTA,
         CODIGO_PAGO,
         DESCRIPCION
      ) values ( SEQ_CODIGO_DETALLE.nextval,
                 R.CODIGO_CUENTA,
                 V_CODIGO_PAGO,
                 P_MOTIVO );


   end loop;

   P_CODIGO_RESULTADO := 0;
   P_MENSAJE_RESULTADO := 'PAGO ANULADO CON EXITO. ';
exception
   when NO_DATA_FOUND then
      P_CODIGO_RESULTADO := 404;
      P_MENSAJE_RESULTADO := 'ERROR: NO SE ENCONTRO EL PEGUE O TARFIA PARA LA CASA' || P_CODIGO_CASA;
   when others then
      P_CODIGO_RESULTADO := -1;
      P_MENSAJE_RESULTADO := 'ERROR AL ANULAR PAGO. ' || SQLERRM;
end;

--- BIEN PARA GENEREAR LAS CUENTAS, LO HARE EN BASE AL CAMPO FECHA INSTALCION EN LA TABLA PEGUES, ESPERANDO QUE ALGUIEN NO DEBA DESDE ESA FECHA. 
--- Y LAS CUENTAS SE HARAN HASTA EL ULTIMOS MES ACTUAL, 

create or replace procedure SP_GENERAR_DEUDAS_MENSUALES (
   P_CODIGO_RESULTADO  out number,
   P_MENSAJE_RESULTADO out varchar2
) as

   cursor C_OBTENER_PEGUES is
   select A.CODIGO_PEGUE,
          B.COSTO,
          A.FECHA_INSTALACION
     from TBL_PEGUES A
    inner join TBL_TARIFAS B
   on A.CODIGO_TARIFA = B.CODIGO_TARIFA
    where A.CODIGO_ESTADO = 1;

   V_OBTENER_PEGUE            C_OBTENER_PEGUES%ROWTYPE;
   V_ULTIMA_CUENTA            date;
   V_ULTIMA_CUENTA_CODIGO_MES number;
   V_MES_ACTUAL               date;
   V_CUENTAS_A_CREAR          number;
   V_CODIGO_MES               number;
begin
   V_MES_ACTUAL := to_date ( TO_CHAR(
      SYSDATE,
      'YYYYMM'
   ),
   'YYYYMM' );
   open C_OBTENER_PEGUES;
   loop
-- VER NUMERO DE CUENTAS A CREAR 
      fetch C_OBTENER_PEGUES into V_OBTENER_PEGUE;
      exit when C_OBTENER_PEGUES%NOTFOUND;
      select max(CODIGO_MES)
        into V_ULTIMA_CUENTA_CODIGO_MES
        from TBL_CUENTAS
       where CODIGO_PEGUE = V_OBTENER_PEGUE.CODIGO_PEGUE;

      if V_ULTIMA_CUENTA_CODIGO_MES is null then 
--- NO SE HA CREADO NINGUNA CUENTA
         V_ULTIMA_CUENTA := V_OBTENER_PEGUE.FECHA_INSTALACION;
      else
         V_ULTIMA_CUENTA := to_date ( TO_CHAR(V_ULTIMA_CUENTA_CODIGO_MES),
         'YYYYMM' );
      end if;
--AHORA SI LAS VECES QUE DEBOS DE CREAR LA CUENTA. 

      V_CUENTAS_A_CREAR := TRUNC(MONTHS_BETWEEN(
         V_MES_ACTUAL,
         V_ULTIMA_CUENTA
      ));
      if V_CUENTAS_A_CREAR <= 0 then
         continue;
      end if;
      for I in 1..V_CUENTAS_A_CREAR loop
         V_CODIGO_MES := to_number ( TO_CHAR(
            ADD_MONTHS(
               V_ULTIMA_CUENTA,
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


   close C_OBTENER_PEGUES;
   P_CODIGO_RESULTADO := 0;
   P_MENSAJE_RESULTADO := 'CUENTAS CREADAS. ';
exception
   when others then
      P_CODIGO_RESULTADO := -1;
      P_MENSAJE_RESULTADO := 'ERROR AL CREAR CUENTA. ' || SQLERRM;
end SP_GENERAR_DEUDAS_MENSUALES;




create or replace procedure SP_AGREGAR_MES_ACTUAL as
   V_MES_ACTUAL number;
   V_EXISTE     number;
begin
   -- Obtener el mes actual en formato YYYYMM
   V_MES_ACTUAL := to_number ( TO_CHAR(
      SYSDATE,
      'YYYYMM'
   ) );

   -- Verificar si ya existe
   select count(*)
     into V_EXISTE
     from TBL_MES
    where CODIGO_MES = V_MES_ACTUAL;

   -- Si no existe, lo insesrtamos
   if V_EXISTE = 0 then
      insert into TBL_MES (
         CODIGO_MES,
         NOMBRE,
         ANIO
      ) values ( V_MES_ACTUAL,
                 TO_CHAR(
                    SYSDATE,
                    'FMMONTH',
                    'NLS_DATE_LANGUAGE=SPANISH'
                 ),
                 to_number(TO_CHAR(
                    SYSDATE,
                    'YYYY'
                 )) );
   end if;

end;