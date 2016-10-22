import json
import datetime
import requests
import time
import daemon
from sys import argv


class Unbuffered(object):
	def __init__(self):
		self.stream = open("/tmp/shield.log", "w")

	def write(self, data):
		self.stream.write(data)
		self.stream.flush()

	def __getattr__(self, attr):
		return getattr(self.stream, attr)


class Notifier(object):

	def __init__(self):
		if len(argv) < 2:
			raise PermissionError("Token is missing")
		self.token = argv[1]
		self.headers = {
			'Access-Token': self.token,
			'Content-Type': 'application/json'
		}
		self.url = 'https://api.pushbullet.com/v2/pushes'
		self.message('Notifier started')

	def notify(self, data):
		with open("/tmp/shield.txt", "w") as out_report:
			out_report.write(data)
		self.message('The guy is online!')

	def message(self, data='Null data', title='Poe'):
		resp = requests.post(self.url, json={
			'body': data,
			'type': 'note',
			'title': title
		}, headers=self.headers)
		if resp.status_code != 200:
			raise Exception(resp)


class PoeTradeDigger(object):

	def __init__(self):
		self.conf = {'id': -1}
		self.headers = {
			'Cookie:': 'league=Standard'
		}

		self.response = {}
		self.url = 'http://poe.trade/search/eatehagoyesiut/live'
		self.notifier = Notifier()
		self.logger = Unbuffered()

	def check(self):
		response = requests.post(self.url, self.conf, self.headers)
		self.response = json.loads(response.content.decode('utf-8'))
		self.conf['id'] = self.response['newid']
		self.log()
		self.notify()

	def log(self):
		self.logger.write("{} :: {}\n".format(datetime.datetime.now(), str(self.response)))

	def notify(self):
		if self.response.get('data'):
			self.notifier.notify(self.response.get('data'))

with daemon.DaemonContext():
	digger = PoeTradeDigger()
	while True:
		digger.check()
		time.sleep(10)