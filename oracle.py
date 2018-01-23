import cx_Oracle

def operation_db():

    ip = 'oracle db host'
    port = 1521
    SID = 'sid name'

    dsn_tns = cx_Oracle.makedsn(ip, port, SID)
    
    con = cx_Oracle.connect('db username', 'db password', dsn_tns)
    
    cursor = con.cursor()
    cursor.execute("select sysdate from dual")

    rows = cursor.fetchall()

    for result in rows:
        print(result)
    
    con.close

if __name__ == '__main__':
    operation_db();
