import cx_Oracle
from datetime import datetime
import os
import shutil

print('auto backup start:' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

now = datetime.now().strftime('%Y%m%d')

root_folder = 'D:\\auto_save_' + now + '\\'

if os.path.exists(root_folder):
    shutil.rmtree(root_folder)


if not os.path.exists(root_folder):
    os.mkdir(root_folder)

proc_folder_name = root_folder + 'procedures'
func_folder_name = root_folder + 'functions'

save_types = ({'output':func_folder_name, 'type': 'FUNCTION'},{'output':proc_folder_name, 'type': 'PROCEDURE'})
        
ip = 'your host'
port = 'your port'
SID = 'your sid'

dsn_tns = cx_Oracle.makedsn(ip, port, SID)
    
con = cx_Oracle.connect(user='your username', password='your password', dsn=dsn_tns, encoding='utf-8')
    
cursor = con.cursor()

for save_type in save_types:
    
    folder_name = save_type['output']
    type_name = save_type['type']

    if not os.path.exists(folder_name):
        os.mkdir(folder_name)

    query_list = cursor.execute("select distinct name from user_source where type = :type_name order by name" , {'type_name': type_name}).fetchall()

    for element in query_list:

        element_name = element[0]
        
        file_path = folder_name + '\\' + element_name + '.sql'
        
        rows = cursor.execute("select text from user_source where type = :type_name and name= :item_name order by line", {'type_name':type_name, 'item_name': element_name}).fetchall()
        
        with open(file_path, 'wb') as procedure_file:

            for index, line_content in enumerate(rows):
            
                if index == 0:
                    procedure_file.write(bytes('CREATE OR REPLACE ' + line_content[0], 'utf-8'))
                    continue
            
                procedure_file.write(bytes(line_content[0], 'utf-8'))

    
con.close

print('auto backup end:' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

