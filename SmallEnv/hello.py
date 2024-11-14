#!/usr/bin/python
import subprocess,os,socket
from http.server import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = 80

#This class will handles any incoming request from
#the browser
class myHandler(BaseHTTPRequestHandler):

  #Handler for the GET requests
  def do_GET(self):
    self.send_response(200)
    self.send_header('Content-type','text/html')
    self.end_headers()
    #Send the html message
    self.wfile.write(bytes("*** Python - Hello World ! ***\n", "utf-8"))
    self.wfile.write(bytes("Hostname is : %s\n" % socket.gethostname(), "utf-8") )
    self.wfile.write(bytes("Client ip : %s\n" % self.client_address[0], "utf-8") )
    return

try:
  #Create a web server and define the handler to manage the
  #Incoming request
  server = HTTPServer(('', PORT_NUMBER), myHandler)
  print ('Started httpserver on port ' , PORT_NUMBER)

  #Wait forever for incoming htto requests
  server.serve_forever()

except KeyboardInterrupt:
  print ('^C received, shutting down the web server')
  server.socket.close()
