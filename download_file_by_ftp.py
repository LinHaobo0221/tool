import paramiko
import stat
import os

def create(input_path,output_path, sftp):
    
    dir_lists = sftp.listdir_attr(input_path)
    
    for dir_lst in dir_lists:

        temp_output = output_path + '\\' + dir_lst.filename
        temp_input = input_path + '/' +dir_lst.filename
        
            
        if stat.S_ISDIR(dir_lst.st_mode):                 
            if not os.path.exists(temp_output):
                os.mkdir(temp_output)
                create(temp_input, temp_output, sftp)
        else:
            print(temp_output)
            sftp.get(temp_input, temp_output)
    
    
def handleFile():

    output_path = 'output_path'
    input_path = 'input_path'
    
    with paramiko.Transport(('your server domain or ip', 'your port ')) as file_server:
    
        file_server.connect(username='your name', password='your password')
    
        sftp = paramiko.SFTPClient.from_transport(file_server)

        sftp.chdir(input_path)

        create(input_path, output_path, sftp)
            

if __name__ == '__main__':
    
    handleFile()



