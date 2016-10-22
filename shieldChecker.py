import json

import requests
import time

conf = {'id' : 46590000}
headers = {
	'Cookie:': 'league=Standard'
}
url = 'http://poe.trade/search/omonotamomoras/live'

while True:
	response = requests.post(url, conf, headers)
	d = json.loads(response.content.decode('utf-8'))
	conf['id'] = d['newid']
	if d.get('data'):
		with open("/tmp/file", "w") as text_file:
			text_file.write(d.get('data'))
		break
	time.sleep(10)
