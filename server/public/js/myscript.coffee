socket = io.connect()
socket.on "connect", -> 
	console.log "connected"

socket.on "message", (message) -> 
	console.log "Message from server: " + message
	message = message.split ":"
	if message[0] == "state"
		$('#switch button').removeClass('active')
		if message[1] == "on"
			$('#switch button[value=on]').addClass('active')
		else if message[1] == "off"
		  	$('#switch button[value=off]').addClass('active')

@switchState = (state) -> 
	console.log "sending.."
	socket.send "state:" + state
	console.log "sending completed"

@sendId = (id) -> 
	console.log "sending.."
	socket.send "id:" + id
	console.log "sending completed"