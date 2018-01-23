
def load_file():

    with open('INSERT_29_CV_HINMOKU_CD.sql', 'r',encoding='utf-8') as input_file:
        
        while True:
            
            line = input_file.readline()
            
            if not line:
                break
            pass

            print(line);
        

if __name__ == '__main__':

    load_file()
