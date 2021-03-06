from tkinter import *
from tkinter import PhotoImage
import pynput.keyboard as kbctl
import pynput.mouse as msctl
import socket

from _thread import *
import threading

import os
import sys

def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

#Initialize Mouse and Keyboard
mouse = msctl.Controller()
keyboard = kbctl.Controller()

def parseMessage(msg):
	msg = msg.decode('utf-8')
	#print(msg)
	if msg.find('RET') != -1:
		keyboard.tap(kbctl.Key.enter)
	elif msg.find('MV') != -1:
		if(msg.find('nan') != -1):
			return
		x = float(msg[4:msg.find(',')])
		y = float(msg[msg.find(',')+1:-1])
		mouse.move(x,y)
	elif msg.find('Left Click') != -1:
		mouse.click(msctl.Button.left,1)
	elif msg.find('Right Click') != -1:
		mouse.click(msctl.Button.right,1)
	elif msg.find('KEY') != -1:
		key = msg[-1]
		if key == ' ':
			keyboard.tap(kbctl.Key.space)
		else:
			keyboard.tap(key)
	elif msg.find('+') != -1:
		keyboard.tap(kbctl.Key.media_volume_up)
	elif msg.find('-') != -1:
		keyboard.tap(kbctl.Key.media_volume_down)
	elif msg.find('/\\') != -1:
		mouse.scroll(0,2)
	elif msg.find('\\/') != -1:
		mouse.scroll(0,-2)
	elif msg.find('BACK') != -1:
		keyboard.tap(kbctl.Key.backspace)
	else:
		return
		#print('Unknown Operation')

def startServer(attributes):
	server = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
	server.bind(attributes)
	while True:
		msg = server.recvfrom(1024)
		parseMessage(msg[0])

#Set up server
port = 2222
server_attrib = ('',port)
#Differente Attempts at getting hostname
hostname = socket.gethostname()
ip = socket.gethostbyname(hostname)
ip2 = ''
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
try:
    # doesn't even have to be reachable
    s.connect(('1.255.255.255', 1))
    ip2 = s.getsockname()[0]
except:
    ip2 = ''
finally:
    s.close()

print("Wifi Remote Controller\nHostname: {}\nPort: {}\n".format(ip,port)) 

start_new_thread(startServer,(server_attrib,))

window = Tk()
window.title("Wifi Remote Controller")
#window.iconbitmap('icon')
#window.iconphoto(False, PhotoImage(file='icon.ico'))


#window.tk.call('wm', 'iconphoto', window._w, PhotoImage(file='icon.ico'))
window.minsize(300,100)
window.configure(background = "white")
Label(window ,text = "Hostnames:",background='white').pack()
Label(window, text="{}".format(hostname),background='white').pack()
Label(window, text="{}".format(ip),background='white').pack()
if ip2 != '' and ip2 != ip:
	Label(window, text="{}".format(ip2),background='white').pack()

Label(window,text = "Code:",background='white').pack()
Label(window, text="{}".format(port),background='white').pack()

window.mainloop()
