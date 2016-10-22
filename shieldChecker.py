import json
import datetime
import requests
import time
import daemon

conf = {'id' : -1}
headers = {
	'Cookie:': 'league=Standard'
}
url = 'http://poe.trade/search/eatehagoyesiut/live'

with daemon.DaemonContext():
	text_file = open("/tmp/shield.log", "w")
	while True:
		response = requests.post(url, conf, headers)
		d = json.loads(response.content.decode('utf-8'))
		conf['id'] = d['newid']
		text_file.write("{} :: {}\n".format(datetime.datetime.now(), str(d)))
		text_file.flush()
		if d.get('data'):
			with open("/tmp/shield.txt", "w") as out_report:
				out_report.write(d.get('data'))
		time.sleep(10)
	text_file.close()
