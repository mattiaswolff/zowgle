tcpServer = require('net').createServer()
express = require('express')
app = express.createServer()
io = require('socket.io').listen(app)
redis = require("redis").createClient()

app.listen 8080
tcpServer.listen 7000

sockets = []

#TCP server 		- 	START
tcpServer.on 'connection', (tcpSocket) ->
	
	tcpSocket.type = "tcp"
	tcpSocket.id = Math.floor(Math.random() * 1000)
	sockets.push(tcpSocket)
	
	tcpSocket.on "data", (data) ->
		n = data.toString().replace(/\n$/, '')
		n = n.toString().split ":"
		if (n[0] == "id")
			redis.sadd "device:" + n[1] + ":sessions", tcpSocket.id
			tcpSocket.deviceId = n[1]
		else if (n[0] == "state")
			redis.hset "device:" + tcpSocket.deviceId, "state", n[1]
			redis.smembers "device:" + tcpSocket.deviceId + ":sessions", (err, reply) ->
				for i in [0 .. sockets.length - 1]
					if (sockets[i].id.toString() in reply)
						if sockets[i].type == "ws"
							sockets[i].emit "message", "state:" + n[1]
						else if sockets[i].type == "tcp"
						  	sockets[i].write("state:" + n[1])

	tcpSocket.on "end", ->
		for i in [0 .. sockets.length - 1]
			if tcpSocket.id == sockets[i].id
				sockets.splice(i,1)
				break
#TCP server 		- 	END

#WS server 			- 	START
io.sockets.on 'connection', (wsSocket) ->
	
	wsSocket.type = "ws"
	sockets.push(wsSocket)
	console.log "New WS connection!"
	
	wsSocket.on 'message', (message) ->
		console.log "Message from " + wsSocket.id + ":" + message
		m = message.replace(/\n$/, '')
		m = m.split ":"
		if (m[0] == "id")
			redis.sadd "device:" + m[1] + ":sessions", wsSocket.id
			wsSocket.deviceId = m[1]
		else if (m[0] == "state")
			redis.hset "device:" + wsSocket.deviceId, "state", m[1]
			redis.smembers "device:" + wsSocket.deviceId + ":sessions", (err, reply) ->
				for i in [0 .. sockets.length - 1]
					if (sockets[i].id.toString() in reply)
						if sockets[i].type == "ws"
							sockets[i].emit "message", "state:" + m[1]
						else if sockets[i].type == "tcp"
						  	sockets[i].write("state:" + m[1])

	wsSocket.on 'disconnect', ->
		for i in [0 .. sockets.length - 1]
			if wsSocket.id == sockets[i].id
				sockets.splice(i,1)
				break
#WS server 			- 	END

#HTTP server 		- 	START
app.configure -> 
  app.use(express.static(__dirname + '/public'))
  app.set 'views' , __dirname + '/public/views'

app.get "/", (req, res) -> res.render '/index.jade'
#HTTP server 		- 	END

# TODO: Change comments
console.log "TCP server listening on port 7000 at localhost"
console.log "WS / HTTP server listening on port 8080 at localhost"