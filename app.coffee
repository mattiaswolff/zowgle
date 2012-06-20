tcpServer = require('net').createServer()
express = require('express')
routes = require('./routes')
app = module.exports = express.createServer();
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
	
	wsSocket.on 'devices:read', (data, fn) ->
		redis.keys "device:object:*", (error, reply) ->
			console.log "redis keys: " + reply
			devices = []
			key_length = reply.length - 1
			reply.forEach (key, i) ->
				console.log "key: " + key
				console.log "i: " + i
				console.log "reply length: " +  reply.length
				redis.get key, (error, reply) ->
					devices.push JSON.parse reply
					console.log "length: " + key_length
					if i == key_length
						console.log "data: " + devices
						fn data: JSON.stringify devices
		
	wsSocket.on 'device:update2', (data, fn) ->
		console.log "device:update recieved"
		console.log data
		console.log fn

		fn data: "some random data"
		wsSocket.emit "device:update", "testar"

	wsSocket.on 'device:update', (message, fn) ->
		message = JSON.parse(message)

		console.log "Message from " + wsSocket.id + ": "
		console.log "deviceId: " + message.id
		console.log "controllers:" + message.controllers
		
		redis.get "device:" + message.id, (error, reply) ->
			
			if !reply
				console.log "error: " + error
				redis.set "device:object:" + message.id, JSON.stringify(message)
				redis.sadd "device:sessions:" + message.id, wsSocket.id
			
			else
				object = JSON.parse(reply)
				console.log "test1 " + message.controllers

				for messageKey, messageValue of message.controllers
					console.log "Message: " + messageValue.name
					for objectKey, objectValue of object.controllers
						console.log "Object: " + objectValue.name
						if objectValue.name == messageValue.name
							console.log "value: " + messageValue.value
							objectValue.value = messageValue.value
							break					
				
				console.log "insert updated object to redis..."

				redis.set "device:object:" + message.id, JSON.stringify(object)
				redis.smembers "device:sessions:" + message.id, (error, reply) ->

					if wsSocket.id not in reply
						console.log "add sessionId to subscribers for device..."
						redis.sadd "device:sessions:" + message.id, wsSocket.id
						reply += wsSocket.id

					console.log  "Looping trough all sockets..."
					console.log "reply: " + reply
					
					for i in [0 .. sockets.length - 1]
						if (sockets[i].id.toString() in reply)
							if sockets[i].type == "ws"
								console.log "WS socket found, sending object.."
								sockets[i].emit "message", JSON.stringify object
							else if sockets[i].type == "tcp"
								console.log "TCP socket found, sending object.."
								sockets[i].write JSON.stringify object
				# TODO: Create function for sending objects to all subscribers.
				
	wsSocket.on 'disconnect', ->
		for i in [0 .. sockets.length - 1]
			if wsSocket.id == sockets[i].id
				sockets.splice(i,1)
				break
		# TODO: Remove socket from redis list.
#WS server 			- 	END

#HTTP server 		- 	START
app.configure -> 
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  app.use(express.errorHandler())

#Routes

app.get '/', routes.index
#HTTP server 		- 	END

console.log "TCP server listening on port 7000 at localhost"
console.log "WS / HTTP server listening on port 8080 at localhost"