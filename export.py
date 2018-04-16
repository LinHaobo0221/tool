import cx_Oracle
from datetime import datetime
import os
import shutil

char_set = {'　' : ' ','＜' : '<', '＞' : '>' ,'：' :':' , '＝':'=','！':'!'}

print('auto backup start:' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

now = datetime.now().strftime('%Y%m%d')

root_folder_02 = 'D:\\auto_save_dev02_' + now + '\\'
root_folder_03 = 'D:\\auto_save_dev03_' + now + '\\'

db_schmas = (
    {'root_folder' : root_folder_02, 'host' : '00.00.00.01', 'port' : 1521, 'schma' : 'schma1', 'user_name' : 'user_name_1', 'password_str' : 'password_1'},
    {'root_folder' : root_folder_03, 'host' : '00.00.00.02', 'port' : 1521, 'schma' : 'schma2', 'user_name' : 'user_name1_2', 'password_str' : 'password_2'}
    )

for db_schma in db_schmas:

    root_folder = db_schma['root_folder']
    host = db_schma['host']
    port = db_schma['port']
    schma = db_schma['schma']
    user_name = db_schma['user_name']
    password_str = db_schma['password_str']

    if os.path.exists(root_folder):
        shutil.rmtree(root_folder)


    if not os.path.exists(root_folder):
        os.mkdir(root_folder)

    proc_folder_name = root_folder + 'procedures'
    func_folder_name = root_folder + 'functions'
    table_folder_name = root_folder + 'tables'

    save_types = ({'output':func_folder_name, 'type': 'FUNCTION'},{'output':proc_folder_name, 'type': 'PROCEDURE'}, {'output':table_folder_name, 'type': 'TABLE'})

    dsn_tns = cx_Oracle.makedsn(host, port, schma)

    con = cx_Oracle.connect(user=user_name, password=password_str, dsn=dsn_tns, encoding='utf-8')

    cursor = con.cursor()

    for save_type in save_types:

        folder_name = save_type['output']
        type_name = save_type['type']

        if not os.path.exists(folder_name):
            os.mkdir(folder_name)

        if type_name == 'TABLE':

            print(schma + '_' + type_name)

            table_list = cursor.execute("select * from USER_TABLES").fetchall()

            for elements in table_list:

                element = elements[0]

                print(schma + '_' + 'TABLE NAME:' + element)

                table_result = cursor.execute("select dbms_metadata.get_ddl('TABLE', :table_name) FROM dual", {'table_name' : element}).fetchone()

                file_path = folder_name + '\\' + element + '.sql'

                with open(file_path, 'wb') as table_file:

                    table_str = table_result[0].read().replace('"','').replace('IKOU.','')

                    table_file.write(bytes(table_str, 'utf-8'))

            continue

        query_list = cursor.execute("select distinct name from user_source where type = :type_name order by name" , {'type_name': type_name}).fetchall()

        for element in query_list:

            element_name = element[0]

            print(schma + '_' + 'OBJECT NAME:' + element_name)

            file_path = folder_name + '\\' + element_name + '.sql'


            rows = cursor.execute("select text from user_source where type = :type_name and name= :item_name order by line", {'type_name':type_name, 'item_name': element_name}).fetchall()

            with open(file_path, 'wb') as procedure_file:

                for index, line_content in enumerate(rows):

                    line = line_content[0]

                    for key in char_set.keys():
                        line = line.replace(key, char_set.get(key))

                    if index == 0:
                        procedure_file.write(bytes('CREATE OR REPLACE ' + line, 'utf-8'))
                        continue

                    procedure_file.write(bytes(line, 'utf-8'))

                procedure_file.write(bytes("\n", 'utf-8'))
                procedure_file.write(bytes('/', 'utf-8'))


con.close

print('auto backup end:' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

