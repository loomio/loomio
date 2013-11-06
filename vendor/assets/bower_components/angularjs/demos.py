# coding: utf-8

import webapp2, random, json, string

SALUTATIONS = [ "Adab", "Ahoj", "An-nyeong-ha-se-yo", "Apa khabar", "Barev Dzez", u"Buenos días".encode('utf-8'), "Bula Vinaka",
                "Chào", "Ciao", "Dia Duit", "Hallo", "Hallå", "Halló", "Halo", "Haye", "Hei", "Hej", "Hello",
                "Helo", "Hola", "Kamusta", "Konnichiwa", "Merhaba", "Mingalarba", "Namaskar", "Namaste", "Olá",
                "Pryvit", "Pryvitannie", "Përshëndetje", "Salam", "Salut", "Sat Sri Akal", "Sholem aleikhem",
                "Sveiki", "Szia", "Tere", "Zdraveĭte", "Zdravo" ]


class GreetHandler(webapp2.RequestHandler):
  def get(self):
    name = self.request.get('name')
    callback = self.request.get('callback')
    salutation = SALUTATIONS[random.randint(0, len(SALUTATIONS) - 1)].encode('string_escape')
    greeting = json.dumps([name, salutation, salutation + ' ' + name + '!'])

    self.response.headers['Content-Type'] = 'application/javascript'
    self.response.out.write(callback + '(' + greeting + ')')


class GeneratePasswordHandler(webapp2.RequestHandler):
  def get(self):
    callback = self.request.get('callback')
    password = ''.join(random.choice(string.hexdigits) for x in range(random.randint(3, 10)))
    password = json.dumps({'password': password})
    self.response.headers['Content-Type'] = 'application/javascript'
    self.response.out.write(callback + '(' + password + ')')


app = webapp2.WSGIApplication([('/greet.*', GreetHandler),
                               ('/generatePassword.*', GeneratePasswordHandler)])
