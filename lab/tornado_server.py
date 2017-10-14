import datetime
import os

import tornado
from  tornado import ioloop
from tornado import web
from tornado.websocket import WebSocketHandler

root = os.path.dirname(__file__)

import os

def get_img_path():
    now = datetime.datetime.now()
    return "{}-{}-{}_uber.jpg".format(now.year, now.month, now.day)


def refresh_img():
    if not os.path.isfile(get_img_path()):
        now = datetime.datetime.now()
        img_url = "http://www.poelab.com/wp-content/uploads/{}/{}/{}-{}-{}_uber.jpg".format(
            now.year, now.month, now.year, now.month, now.day
        )
        os.system("wget -O {0} {1}".format(get_img_path(), img_url))


refresh_img()

current_step = 0

handlers = []

class TornadoHandler(WebSocketHandler):

    def on_message(self, message):
        current_step = message
        for h in handlers:
            try:
                h.write_message(current_step)
            except:
                pass

    def open(self):
        refresh_img()
        handlers.append(self)
        self.write_message(str(current_step))

    def close(self, code=None, reason=None):
        handlers.remove(self)

def make_app():

    return tornado.web.Application([
        (r'/ws/*', TornadoHandler),
        (r"/(.*)", tornado.web.StaticFileHandler, {"path": root, "default_filename": "index.html"}),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()