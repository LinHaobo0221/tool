CREATE OR REPLACE PROCEDURE SPL_WK_PROC(limit_count IN NUMBER DEFAULT 5000) 
IS  
    outputpath VARCHAR2(100 char) := 'outputpath';
    
    --cursor for get data from wk_16_edit_koubai
    TYPE rows_cursor IS REF CURSOR;
    row_cursor rows_cursor;
    
    --data table
    TYPE edit_row_cursor_table is TABLE OF {table_name}%ROWTYPE;
    edit_row_table edit_row_cursor_table;
    
    --Oracleファイルオブジェクト初期化
    normal_result_file UTL_FILE.FILE_TYPE;
    
    validate_error_file UTL_FILE.FILE_TYPE;
     
    ERROR_MSG VARCHAR2(5 CHAR) := 'ERROR';
     
    normal_file_name VARCHAR2(100 CHAR) := '*****'; 
    validate_error_file_name VARCHAR2(100 CHAR) := '*****';
    
    temp_error_message VARCHAR2(32767 CHAR) := '';
    
    --output line
    outputContent VARCHAR2(32767 char) := '';
    
BEGIN
     
     EXECUTE IMMEDIATE 'TRUNCATE TABLE table name';
    
     OPEN row_cursor FOR SELECT * FROM dual temp_table;
     LOOP
      FETCH row_cursor BULK COLLECT INTO edit_row_table LIMIT limit_count ;
        EXIT WHEN edit_row_table.COUNT = 0;
        
        FORALL indx in edit_row_table.FIRST .. edit_row_table.LAST
          INSERT INTO table_name VALUES edit_row_table(indx);
        COMMIT;
          
      COMMIT; 
    END LOOP;
    CLOSE row_cursor;
    
    --FILE OUTPUT
    OPEN row_cursor FOR SELECT * FROM WK_16_EDIT_KOUBAI WHERE ERROR_FLAG IS NULL ORDER BY ITEM_001, ITEM_077;
    normal_result_file := UTL_FILE.FOPEN(UPPER(outputpath), normal_file_name, 'w', 32767);
    LOOP
      FETCH row_cursor BULK COLLECT INTO edit_row_table LIMIT limit_count;
      EXIT WHEN edit_row_table.COUNT = 0;
        FOR indx IN edit_row_table.FIRST .. edit_row_table.LAST LOOP 
          UTL_FILE.PUT_LINE(validate_error_file, '');
          outputContent := '';
        END LOOP;
    END LOOP;
   CLOSE row_cursor;
   UTL_FILE.FCLOSE(validate_error_file);
   
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