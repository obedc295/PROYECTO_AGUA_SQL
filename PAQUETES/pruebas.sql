select *
  from TBL_ABONADOS;

select * from TBL_PERSONAS;

select *
  from TBL_PEGUES;


   set SERVEROUTPUT on

declare
   V_CODIGO_RESULTADO  number;
   V_MENSAJE_RESULTADO varchar2(500);
begin
   PKG_CUENTAS.SP_GENERAR_DEUDAS_MENSUALES(
      V_CODIGO_RESULTADO,
      V_MENSAJE_RESULTADO
   );
   DBMS_OUTPUT.PUT_LINE(V_CODIGO_RESULTADO || V_MENSAJE_RESULTADO);
end;


select *
  from TBL_PEGUES;

)
SELECT * from TBL_CUENTAS where codigo_pegue=6;