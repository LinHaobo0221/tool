import cx_Oracle
from datetime import datetime
import os

def operation_db():
    print('auto backup procedure start:' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    now = datetime.now().strftime('%Y%m%d')
    folder_name = 'D:\\' + now + '_proc'
    
    if not os.path.exists(folder_name):
        os.mkdir(folder_name)
        
    ip = 'host'
    port = 1521
    SID = 'sid'
    procedure_truple = (' your sql truple or list')

    dsn_tns = cx_Oracle.makedsn(ip, port, SID)
    
    con = cx_Oracle.connect(user='username', password='password', dsn=dsn_tns, encoding='utf-8')
    
    cursor = con.cursor()
    
    sql = "select text from user_source where type = 'PROCEDURE' and name= :procedure_name order by line"

    for element_name in procedure_truple:

        file_path = folder_name + '\\' + element_name + '.sql'
        
        cursor.execute(sql, {'procedure_name': element_name})

        rows = cursor.fetchall()
        
        with open(file_path, 'wb') as procedure_file:

           for index, line_content in enumerate(rows):
            
                if index == 0:
                   procedure_file.write(bytes('CREATE OR REPLACE ' + line_content[0], 'utf-8'))
                   continue
            
                procedure_file.write(bytes(line_content[0], 'utf-8'))

    
    con.close
    print('auto backup procedure end:' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
     
if __name__ == '__main__':
    operation_db();  

