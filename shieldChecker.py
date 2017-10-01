import datetime
import json
import os
import smtplib
import time
import traceback
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formatdate
from json import JSONDecodeError
from smtpd import COMMASPACE
from sys import platform

import requests
from bs4 import BeautifulSoup as Soup
from requests.exceptions import ConnectionError as ConnectionErrorReqExc
from requests.packages.urllib3.exceptions import NewConnectionError

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
		self.notif_all('Notifier started')

	def log(self, *args):
		self.logger.write("{} ".format(datetime.datetime.now()))
		for arg in args:
			self.logger.write(arg)
			self.logger.write(' ')
		self.logger.write("\n")

	def notif_all(self, data='Null data', title='POE'):
		self.log(data)
		self.mail(data, title)
		self.pushbullet(data, title)

	def pushbullet(self, data, title):
		resp = requests.post(self.pushbullet_url, json={
			'body': data,
			'type': 'note',
			'title': title
		}, headers=self.headers)
		if resp.status_code != 200:
			raise Exception(resp.content)

	def mail(self,
			text,
			subject,
			subtype='plain',
			fro='shieldChecker',
			to=('deathangel908@gmail.com',),
			server="localhost"):
		if IS_WIN:
			print("MAIL MOCK")
			return
		msg = MIMEMultipart()
		msg['From'] = fro
		msg['To'] = COMMASPACE.join(to)
		msg['Date'] = formatdate(localtime=True)
		msg['Subject'] = subject
		msg.attach(MIMEText(text, subtype))

		smtp = smtplib.SMTP(server)
		smtp.sendmail(fro, to, msg.as_string())
		smtp.close()


class PoeTradeDigger(object):

	def __init__(self):
		self.conf = {'id': -1}
		self.headers = {
			'Cookie:': 'league=Harbinger'
		}

		self.urls = {
			'http://poe.trade/search/booyaanatigaba/live': -1,  # Harb belt
			'http://poe.trade/search/itetaretanyahu/live': -1,  # Harb jewel
			'http://poe.trade/search/ausonarimoheui/live': -1,  # Harb Amu
			'http://poe.trade/search/ihanasakekabau/live': -1,  # Harb Boots
			'http://poe.trade/search/ariahonnetohih/live': -1,  # Harb shield
			'http://poe.trade/search/raikominohobak/live': -1,  # Harb wand
			'http://poe.trade/search/raikominohobak/live': -1,  # Harb wand
			'http://poe.trade/search/erinoyatobarud/live': -1,  # Harb QueenOfTheForest
		}
		self.notifier = Notifier()

	def check(self, url):
		response = requests.post(url, {'id': self.urls[url]}, self.headers)
		parsed_response = json.loads(response.content.decode('utf-8'))
		self.urls[url] = parsed_response['newid']
		self.notifier.log(url, parsed_response)
		self.notify_if_html(url, parsed_response)

	def check_all(self):
		for url in self.urls:
			try:
				self.check(url)
				time.sleep(2)
			except Exception as e:
				exp_data = "{} url exception : {}\n {}".format(url, str(e), str(traceback.format_exc()))
				self.notifier.log(exp_data)
				if not isinstance(e, (NewConnectionError, ConnectionError, ConnectionErrorReqExc, JSONDecodeError)):
					self.notifier.mail(exp_data, e.__class__.__name__)

	def extract_data(self, html):
		soup = Soup(html, "html.parser")
		tbody = soup.select('tbody[data-name]')
		data = {}
		if len(tbody) > 0:
			data['name'] = tbody[0].get('data-name', 'NAME')
			data['ign'] = tbody[0].get('data-ign', 'IGN')
			data['bo'] = tbody[0].get('data-buyout', '')
			mods = soup.select('.mods li')
			if len(mods) > 0:
				data['mods'] = [{'n': m.get('data-name'), 'v': m.get('data-value')} for m in mods]
			else:
				data['mods'] = []
		return data

	def notify_if_html(self, url, parsed_response):
		html = parsed_response.get('data')
		if html:
			content = "{} url matches: {}".format(url, html)
			data = self.extract_data(html)
			title = "{} '{}' {}".format(data['ign'], data['name'], data['bo'])
			self.notifier.mail(html, title, subtype='html')
			self.notifier.log(content)
			text_content = "{} '{}' {}\n".format(data['ign'], data['name'], data['bo'])
			for m in data['mods']:
				text_content += "{}: {} \n".format(m['n'], m['v'])
			self.notifier.pushbullet(text_content, data['name'])

if not IS_WIN:
	import daemon
	with daemon.DaemonContext():
		digger = PoeTradeDigger()
		while True:
			try:
				digger.check_all()
			except:
				pass
else:
	digger = PoeTradeDigger()
	digger.check_all()
