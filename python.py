from urllib import request
from bs4 import BeautifulSoup

url = 'https://stackoverflow.com/questions/8289957/python-2-7-beautiful-soup-img-src-extract'

file_name = 'result.png'

#image_list = ()

req = request.Request(
    url,
    data=None,
    headers={
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
        })

with request.urlopen(req) as req:
    
    data = req.read()
    
    soup = BeautifulSoup(data, "html.parser")

    image_list = (soup.findAll('img'))


for index, image in enumerate(image_list):
    
    file_src = image['src']
    
    print(file_src)

    temp_index = 'resut_' + str(index + 1) + '.png'

    temp_image = request.urlopen(file_src).read()
    
    with open(temp_index, 'wb') as file:

        file.write(temp_image)
