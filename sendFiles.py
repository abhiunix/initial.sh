#!/bin/python3
import requests
import os
from datetime import date
import time
import subprocess as sp


currentdate = date.today()
t = time.localtime()
currentTime = time.strftime("%H-%M-%S", t)


os.system("zip -r {}-{}.backup.zip .".format(currentdate, currentTime))
files={'document':open('{}-{}.backup.zip'.format(currentdate, currentTime),'rb')}
resp= requests.post('https://api.telegram.org/bot1703671935:AAEDKB7d3554qywT2Q1SZyYiSc3SSMLrBzU/sendDocument?chat_id=249998494&caption={}-{}.backup.zip'.format(currentdate, currentTime), files=files)

os.system("rm -r *.zip")

print("{}-{}-backup.zip sent to telegram.".format(currentdate, currentTime))
