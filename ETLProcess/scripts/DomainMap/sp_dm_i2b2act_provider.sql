/************************************************************
project : N3C DI&H
Date: 5/16/2020
Authors: 
Stephanie Hong, Sandeep Naredla, Richard Zhu, Tanner Zhang
Stored Procedure : SP_DM_I2B2ACT_PROVIDER

Description : insert to N3CDS_DOMAIN_MAP

*************************************************************/
CREATE PROCEDURE CDMH_STAGING.SP_DM_I2B2ACT_PROVIDER 
(
  DATAPARTNERID IN NUMBER 
, MANIFESTID IN NUMBER 
, RECORDCOUNT OUT NUMBER 
) AS 
/********************************************************************************************************
     Name:      sp_dm_i2b2act_provider
     Purpose:    Generate domain map id  for i2b2Act provider table. 
     Source:
     Revisions:
     Ver          Date        Author               Description
     0.1        7/20/2020     SHONG             Initial Version
*********************************************************************************************************/


/******************************************************
*  CONSTANTs
******************************************************/
COMMIT_LIMIT CONSTANT NUMBER := 10000;
loop_count NUMBER;
insert_rec_count NUMBER;
/**************************************************************
*  Cursor for selecting table
**************************************************************/
CURSOR ResultSet_Cursor IS
SELECT distinct 
DATAPARTNERID AS DATA_PARTNER_ID,
'PROVIDER_DIMENSION' AS DOMAIN_NAME,
PROVIDER_ID AS SOURCE_ID, 
SYSDATE AS CREATE_DATE,
null as target_domain_id, 
null as target_concept_id 
FROM NATIVE_I2B2ACT_CDM.PROVIDER_DIMENSION pd
LEFT JOIN CDMH_STAGING.N3CDS_DOMAIN_MAP mp on pd.PROVIDER_ID=Mp.Source_Id 
    AND mp.DOMAIN_NAME='PROVIDER_DIMENSION'  AND mp.DATA_PARTNER_ID=DATAPARTNERID 
where mp.n3cds_domain_map_id is null
;
TYPE l_val_cur IS TABLE OF ResultSet_Cursor%ROWTYPE;
values_rec l_val_cur;

BEGIN

/**************************************************************
_  VARIABLES:
*  loop_count - counts loop iterations for COMMIT_LIMIT
**************************************************************/
   loop_count := 0;
   insert_rec_count := 0;
/******************************************************
* Beginning of loop on each record in cursor.
******************************************************/
open ResultSet_Cursor;
  LOOP
    FETCH ResultSet_Cursor bulk collect into values_rec limit 10000;
    EXIT WHEN values_rec.COUNT=0;
BEGIN
   FORALL i IN 1..values_rec.COUNT
	   INSERT INTO CDMH_STAGING.N3CDS_DOMAIN_MAP (DATA_PARTNER_ID,DOMAIN_NAME,SOURCE_ID,CREATE_DATE,TARGET_DOMAIN_ID,TARGET_CONCEPT_ID)
     VALUES (values_rec(i).DATA_PARTNER_ID,
     values_rec(i).DOMAIN_NAME,
     values_rec(i).SOURCE_ID,
     values_rec(i).CREATE_DATE,
     values_rec(i).TARGET_DOMAIN_ID,
     values_rec(i).TARGET_CONCEPT_ID);
        COMMIT;
	END;
         insert_rec_count := insert_rec_count+ values_rec.COUNT;
--         dbms_output.put_line('Number of records inserted during loop = '||insert_rec_count);
END LOOP;
RECORDCOUNT :=insert_rec_count;
COMMIT;
Close ResultSet_Cursor;
dbms_output.put_line('Number of records inserted are = '||RECORDCOUNT);

end sp_dm_i2b2act_provider;
