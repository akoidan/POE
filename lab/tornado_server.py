import datetime
import json
import os

import tornado
import imghdr
from  tornado import ioloop
from tornado import web
from tornado.httpserver import HTTPServer
from tornado.websocket import WebSocketHandler

root = os.path.dirname(__file__)

import os

def get_img_path():
    now = datetime.datetime.now()
    return "{}-{}-{}_uber.jpg".format(now.year, now.month, now.day)


current_step = '{"x":0, "y":0}'

handlers = []

class BaseHander(tornado.web.RequestHandler):
    join = os.sep.join((root, 'config.json'))

    def get(self):
        with open(self.join, 'r') as myfile:
           self.write(myfile.read())
    def post(self, a, b):
        f = open(self.join, 'w')
        f.write(a)
        f.close()

class ImageHandler(tornado.web.RequestHandler):

    def get(self):
        path = get_img_path()
        if not os.path.isfile(path) or imghdr.what(path) != 'jpeg':
            now = datetime.datetime.now()
            img_url = "http://www.poelab.com/wp-content/uploads/{}/{}/{}-{}-{}_uber.jpg".format(
                now.year, now.month, now.year, now.month, now.day 
            )
            os.system("wget -O {0} {1}".format(path, img_url))
        print('serving {}'.format(path))
        self.redirect('/'+path)

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
                    except:
                        pass

    def open(self):
        handlers.append(self)
        self.remote_ip = self.request.remote_ip
        if self.current_step is not None:
            self.write_message(self.current_step)

    def close(self, code=None, reason=None):
        handlers.remove(self)


application = tornado.web.Application([
    (r'/ws/*', TornadoHandler),
    (r'/rest/*', BaseHander),
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
