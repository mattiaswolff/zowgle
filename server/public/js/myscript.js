// Generated by CoffeeScript 1.3.1
(function() {
  var socket;

  socket = io.connect();

  socket.on("connect", function() {
    return console.log("connected");
  });

  socket.on("message", function(message) {
    console.log("Message from server: " + message);
    message = message.split(":");
    if (message[0] === "state") {
      $('#switch button').removeClass('active');
      if (message[1] === "on") {
        return $('#switch button[value=on]').addClass('active');
      } else if (message[1] === "off") {
        return $('#switch button[value=off]').addClass('active');
      }
    }
  });

  this.switchState = function(state) {
    console.log("sending..");
    socket.send("state:" + state);
    return console.log("sending completed");
  };

  this.sendId = function(id) {
    console.log("sending..");
    socket.send("id:" + id);
    return console.log("sending completed");
  };

}).call(this);
