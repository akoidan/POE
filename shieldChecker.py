import datetime
import json
import os
import time
import traceback
from sys import platform

import requests
from bs4 import BeautifulSoup as Soup

from credentials import *

LOG_FILE_NAME = 'shield.log'
IS_WIN = platform.startswith('win')
LOG_DIR = os.path.dirname(__file__) if IS_WIN else '/tmp'
LOG_FILE_PATH = os.sep.join((LOG_DIR, LOG_FILE_NAME))


class Unbuffered(object):

	def __init__(self):
		self.stream = open(LOG_FILE_PATH, "wb")

	def write(self, data):
		if not isinstance(data, str) and not isinstance(data, bytes):
			data = str(data)
		if isinstance(data, str):
			data = data.encode('utf-8')
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
		self.notify('Notifier started')

	def log(self, *args):
		self.logger.write("{} ".format(datetime.datetime.now()))
		for arg in args:
			self.logger.write(arg)
			self.logger.write(' ')
		self.logger.write("\n")

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
		self.notifier.log(url, parsed_response)
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
		time.sleep(10)

	def extract_title(self, html):
		soup = Soup(html, "html.parser")
		tbody = soup.select('tbody[data-name]')
		if len(tbody) > 0:
			name = tbody[0].get('data-name', 'NAME')
			ign = tbody[0].get('data-ign', 'IGN')
			bo = tbody[0].get('data-buyout', '')
			title = "{} '{}' {}".format(ign, name, bo)
		else:
			title = 'NO_MATCHES'
		return title

	def notify(self, url, parsed_response):
		if parsed_response.get('data'):
			content = "{} url matches: {}".format(url, parsed_response.get('data'))
			title = self.extract_title(parsed_response.get('data'))
			self.notifier.notify(content, title)

if not IS_WIN:
	import daemon
	with daemon.DaemonContext():
		digger = PoeTradeDigger()
		while True:
			digger.check_all()
else:
	digger = PoeTradeDigger()
	digger.check_all()