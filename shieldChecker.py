import json
import datetime
import os
import traceback

import requests
import time
import daemon
from sys import platform

from credentials import *

LOG_FILE_NAME = 'shield.log'
LOG_DIR = os.path.dirname(__file__) if platform.startswith('win') else '/tmp'
LOG_FILE_PATH = os.sep.join((LOG_DIR, LOG_FILE_NAME))


class Unbuffered(object):

	def __init__(self):
		self.stream = open(LOG_FILE_PATH, "w")

	def write(self, data):
		self.stream.write(data)
		self.stream.flush()

	def __getattr__(self, attr):
		return getattr(self.stream, attr)


class Notifier(object):

	def __init__(self):
		self.headers = {
			'Access-Token': PUSHBULET_TOKEN,
			'Content-Type': 'application/json'
		}
		self.logger = Unbuffered()
		self.pushbullet_url = 'https://api.pushbullet.com/v2/pushes'
		self.notify('{} notifier started'.format(datetime.datetime.now()))

	def log(self, parsed_response):
		self.logger.write("{} :: {}\n".format(datetime.datetime.now(), str(parsed_response)))

	def notify(self, data='Null data', title='POE'):
		self.log(data)
		self.sms(data, title)
		self.pushbullet(data, title)

	def pushbullet(self, data, title):
		resp = requests.post(self.pushbullet_url, json={
			'body': data,
			'type': 'note',
			'title': title
		}, headers=self.headers)
		if resp.status_code != 200:
			raise Exception(resp.content)

	def sms(self, data, title):
		if SMS_TOKEN is None:
			return
		response = requests.get(
			'https://gate.smsclub.mobi/http/',
			{
				'username': '380636972218',
				'password': SMS_TOKEN,
				'from': title,
				'to': '380636972218',
				'text': data[:100]
			}
		)
		if response.status_code != 200:
			raise Exception(response.content)


class PoeTradeDigger(object):

	def __init__(self):
		self.conf = {'id': -1}
		self.headers = {
			'Cookie:': 'league=Standard'
		}

		self.urls = {
			'http://poe.trade/search/naragotenahohu/live': -1,  # jewel
			'http://poe.trade/search/kanayahamikaki/live': -1,  # ES shield craft
			'http://poe.trade/search/atetatasisiuku/live': -1,  # dagger
			'http://poe.trade/search/roritosinikiyo/live': -1  # ring
		}
		self.notifier = Notifier()

	def check(self, url):
		response = requests.post(url, {'id': self.urls[url]}, self.headers)
		parsed_response = json.loads(response.content.decode('utf-8'))
		self.urls[url] = parsed_response['newid']
		self.notifier.log(parsed_response)
		self.notify(url, parsed_response)

	def check_all(self):
		for url in self.urls:
			try:
				self.check(url)
				time.sleep(1)
			except Exception as e:
				exp_data = "{} url exception : {}".format(url, str(e))
				self.notifier.notify(exp_data)
				self.notifier.log(traceback.format_exc())

	def notify(self, url, parsed_response):
		if parsed_response.get('data'):
			self.notifier.notify("{} url matches: {}".format(url, parsed_response.get('data')))

with daemon.DaemonContext():
	digger = PoeTradeDigger()
	while True:
		digger.check_all()
		time.sleep(10)