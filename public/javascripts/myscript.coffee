

# socket.on "message", (message) -> 
# 	console.log "Message from server: " + message
# 	message = JSON.parse(message)
# 	$('#' + message.id).text(message.controllers.state)	
# 	if message[0] == "state"
# 		$('#switch button').removeClass('active')
# 		if message[1] == "on"
# 			$('#switch button[value=on]').addClass('active')
# 		else if message[1] == "off"
# 		  	$('#switch button[value=off]').addClass('active')

# @sendState = (data) -> 
# 	message = JSON.stringify data 
# 	console.log "sending.." + message
# 	socket.send message
# 	console.log "sending completed"

# @sendId = (id) -> 
# 	console.log "sending.."
# 	socket.send "id:" + id
# 	console.log "sending completed"