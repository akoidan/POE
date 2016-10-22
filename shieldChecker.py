import json
import datetime
import requests
import time

conf = {'id' : -1}
headers = {
	'Cookie:': 'league=Standard'
}
url = 'http://poe.trade/search/eatehagoyesiut/live'

while True:
	response = requests.post(url, conf, headers)
	d = json.loads(response.content.decode('utf-8'))
	conf['id'] = d['newid']
	print("{} :: {}".format(datetime.datetime.now(), str(d)))
	if d.get('data'):
		with open("/tmp/file", "w") as text_file:
			text_file.write(d.get('data'))
		break
	time.sleep(10)
