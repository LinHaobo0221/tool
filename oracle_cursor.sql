CREATE OR REPLACE PROCEDURE SPL_PROC(limit_count IN NUMBER DEFAULT 5000) 
IS  
    outputpath VARCHAR2(100 char) := 'outputpath';
    
    TYPE rows_cursor IS REF CURSOR;
    row_cursor rows_cursor;
    
    --data table
    TYPE edit_row_cursor_table is TABLE OF YOUR_TABLE%ROWTYPE;
    edit_row_table edit_row_cursor_table;
    
    --Oracleファイルオブジェクト初期化
    normal_result_file UTL_FILE.FILE_TYPE;
    
    validate_error_file UTL_FILE.FILE_TYPE;
     
    ERROR_MSG VARCHAR2(5 CHAR) := 'ERROR';
     
    normal_file_name VARCHAR2(100 CHAR) := 'RST.tsv'; 
    
    temp_error_message VARCHAR2(32767 CHAR) := '';
    
    --output line
    outputContent VARCHAR2(32767 char) := '';
    
BEGIN
     
     EXECUTE IMMEDIATE 'TRUNCATE TABLE TABLE_NAME';
    
     OPEN row_cursor FOR SELECT * FROM YOUR_TABLE;
     LOOP
      FETCH row_cursor BULK COLLECT INTO edit_row_table LIMIT limit_count ;
        EXIT WHEN edit_row_table.COUNT = 0;
        
        FORALL indx in edit_row_table.FIRST .. edit_row_table.LAST
          INSERT INTO YOUR_TABLE VALUES edit_row_table(indx);
        COMMIT;
        
        FOR indx in edit_row_table.FIRST .. edit_row_table.LAST LOOP
          
          IF edit_row_table(indx).ITEM_XXX = ERROR_MSG THEN
           temp_error_message := temp_error_message || 'XXXXXXXXXXXXXX,';
          END IF;
          
          IF temp_error_message IS NOT NULL THEN
           UPDATE TABLE_NAME SET ERROR_FLAG = 'ERROR', ERROR_MESSAGE = temp_error_message
           WHERE ITEM_001 = edit_row_table(indx).ITEM_XXX;
         END IF;
           temp_error_message := '';
       END LOOP;    
      COMMIT; 
    END LOOP;
    CLOSE row_cursor;
    
    --FILE OUTPUT
    OPEN row_cursor FOR SELECT * FROM WK_16_EDIT_KOUBAI WHERE ERROR_FLAG IS NULL ORDER BY ITEM_001;
    normal_result_file := UTL_FILE.FOPEN(UPPER(outputpath), normal_file_name, 'w', 32767);
    LOOP
      FETCH row_cursor BULK COLLECT INTO edit_row_table LIMIT limit_count;
      EXIT WHEN edit_row_table.COUNT = 0;
        FOR indx IN edit_row_table.FIRST .. edit_row_table.LAST LOOP 
          outputContent := edit_row_table(indx).ITEM_XXX;
          UTL_FILE.PUT_LINE(normal_result_file, outputContent);
          outputContent := '';
        END LOOP;
    END LOOP;
   CLOSE row_cursor;
   UTL_FILE.FCLOSE(normal_result_file);
   
    --異常処理
    EXCEPTION
       WHEN UTL_FILE.INVALID_PATH THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE('File location is invalid');
       
       WHEN UTL_FILE.INVALID_MODE THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'The open_mode parameter in FOPEN is invalid');
       
       WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'File handle is invalid.');
       
       WHEN UTL_FILE.INVALID_OPERATION THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'File could not be opened or operated on as requested.');
       
       WHEN UTL_FILE.WRITE_ERROR THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'Operating system error occurred during the read operation.');
       
       WHEN UTL_FILE.INTERNAL_ERROR THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'Unspecified PL/SQL error.');
       
       WHEN UTL_FILE.FILE_OPEN THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'The requested operation failed because the file is open.');
       
       WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'The MAX_LINESIZE value for FOPEN() is invalid; it should be within the range 1 to 32767.');
       
       WHEN UTL_FILE.ACCESS_DENIED THEN
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE(SQLCODE ||',' || 'Permission to access to the file location is denied.');  
       
       WHEN OTHERS THEN     
        UTL_FILE.FCLOSE_ALL();
        DBMS_OUTPUT.PUT_LINE( SQLCODE ||',' || SQLERRM);
END;