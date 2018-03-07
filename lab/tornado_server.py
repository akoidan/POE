#!/usr/bin/env python

import datetime
import json
import os

import tornado
import imghdr
from  tornado import ioloop
from tornado import web
from tornado.httpserver import HTTPServer
from tornado.websocket import WebSocketHandler

root = os.path.dirname(os.path.abspath(__file__))
print ('root dir' + root)

import os

current_step = '{"x":0, "y":0}'

handlers = []


class ImageHandler(tornado.web.RequestHandler):

    def wget(self, now, path, format):
        img_url = now.strftime(format)
        res = os.system("wget -O {0} {1}".format(path, img_url))
        print("Fetched {} with result {}".format(img_url, res))
        return res == 0

    def get(self):
        now = datetime.datetime.now()
        file_name = now.strftime("%Y-%m-%d_uber.jpg")
        path = os.sep.join((root, file_name))
        if os.path.isfile(path) and imghdr.what(path) == 'jpeg':
            found = True
        else:
            print("image file doesn't exist nor it's not an image")
            url_1 = "http://www.poelab.com/wp-content/uploads/%Y/%m/%Y-%m-%d_uber.jpg"
            url_2 = "http://www.poelab.com/wp-content/uploads/%Y/%m/%Y-%m-%d_uber-1.jpg"
            found = self.wget(now, path, url_1) or self.wget(now, path, url_2)
        if found:
            self.redirect('/' + file_name)
        else:
            self.set_status(404, 'Not found')

class TornadoHandler(WebSocketHandler):
    joind = os.sep.join((root, 'config.json'))
    steps = {}

    @property
    def current_step(self):
        return TornadoHandler.steps.get(self.remote_ip, None)

    @current_step.setter
    def current_step(self, value):
        TornadoHandler.steps[self.remote_ip] = value

    def on_message(self, message):
        m = json.loads(message)
        data = self.get_data()
        prev_cord = None
        for d in data:
            if ((m['x'] - d['x']) * (m['x'] - d['x']) + (m['y'] - d['y']) * (m['y'] - d['y'])) < 500:
                prev_cord = d
        if prev_cord is not None and m['set']:
            data.remove(prev_cord)
            self.set_data(data)
        elif prev_cord is not None and not m['set']:
            self.current_step = json.dumps(prev_cord)
            self.broad()
        elif prev_cord is None and m['set']:
            data.append({"x": m["x"], "y": m["y"]})
            self.set_data(data)


    def get_data(self):
        with open(self.joind, encoding='utf-8') as data_file:
            data = json.loads(data_file.read())
        return data

    def set_data(self, data):
        datastr = json.dumps(data)
        text_file = open(self.joind, "w")
        text_file.write(datastr)
        self.write_message(datastr)
        text_file.close()

    def broad(self):
        if self.current_step is not None:
            for h in handlers:
                if h.remote_ip == self.remote_ip:
                    try:
                        h.write_message(self.current_step)
                    except Exception as e:
                        print("Error sending message to {}: {} {}".format(h.remote_ip, type(e), e))

    def open(self):
        handlers.append(self)
        self.remote_ip = self.request.remote_ip
        if self.current_step is not None:
            self.write_message(self.current_step)

    def close(self, code=None, reason=None):
        handlers.remove(self)


application = tornado.web.Application([
    (r'/ws/*', TornadoHandler),
    (r'/image.jpg', ImageHandler),
    (r"/(.*)", tornado.web.StaticFileHandler, {"path": root, "default_filename": "index.html"}),
])

if __name__ == '__main__':
   # http_server = tornado.httpserver.HTTPServer(application, ssl_options={
   #     "certfile": "/etc/nginx/ssl/1_pychat.org_bundle.crt",
   #     "keyfile": "/etc/nginx/ssl/server.key",
   # })
   # http_server.listen(8889)
    application.listen(8889) #insted of both above
    tornado.ioloop.IOLoop.instance().start()
