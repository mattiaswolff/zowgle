// Generated by CoffeeScript 1.3.1
(function() {
  var $;

  $ = jQuery;

  $(function() {
    $('#switch button').click(function() {
      return sendState("123456", $(this).attr("value"));
    });
    return $('#id button').click(function() {
      return sendId($(this).parent().children('input').val());
    });
  });

}).call(this);
