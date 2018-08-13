create or replace PROCEDURE sample_procedure IS

/**
    ＊「secondtable」、「maintable」 、thirdTable」は全部は仮タブールですから、実際にのテーブル名何がの通りに直すことにしてください。。
    ＊４０行目のところには「１００」の意味は　１００行ずつ処理しますけど、性能問題あれば、ほかの値を設定するにします。
    ＊変換ロジックがあれば時に、５０行の所を追加することにしてください。
**/

    CURSOR result_cursor (
        conditionvalue VARCHAR2
    ) IS SELECT
             --st.*
             st.COLUMNNAMEONE, st.COLUMNNAMETWO, st.COLUMNNAMETHREE
         FROM
             secondtable st
             INNER JOIN maintable mt ON mt.keycolumn = mt.keycolumn
         WHERE
             mt.condition = conditionvalue;

    --TYPE result_rows_table IS TABLE OF secondtable%rowtype;
    --result_table result_rows_table;
    
    TYPE result_rows IS RECORD (
        COLUMNNAMEONE SECONDTABLE.COLUMNNAMEONE%TYPE,
        COLUMNNAMETWO SECONDTABLE.COLUMNNAMETWO%TYPE,
        COLUMNNAMETHREE SECONDTABLE.COLUMNNAMETHREE%TYPE
    );
    
    TYPE result_rows_table IS TABLE OF result_rows; 
    result_table result_rows_table;

    temp_columnOne_value varchar(100 char) := '';
    temp_columnTwo_value varchar(100 char) := '';
    temp_columnThree_value varchar(100 char) := '';
    
BEGIN 

    OPEN result_cursor('20180810');
    LOOP

        FETCH result_cursor BULK COLLECT INTO result_table LIMIT 100;
        EXIT WHEN result_table.count = 0;

            FOR indx IN result_table.first .. result_table.last LOOP 

                temp_columnOne_value := result_table(indx).COLUMNNAMEONE;
                temp_columnTwo_value := result_table(indx).COLUMNNAMETWO;
                temp_columnThree_value := result_table(indx).COLUMNNAMETHREE;

                if temp_columnOne_value = 'boris' then
                    temp_columnOne_value := 'boris' || 'niubi2';
                end if;

                update thirdTable set COLUMNNAMEONE = temp_columnOne_value, COLUMNNAMETWO = temp_columnTwo_value, COLUMNNAMETHREE = temp_columnThree_value; 

            END LOOP; 
        
        commit;

    END LOOP; 
    CLOSE result_cursor;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;

end;
