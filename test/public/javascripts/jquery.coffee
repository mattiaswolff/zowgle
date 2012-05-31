$ = jQuery
$ ->
	# $.each $('ul.thumbnails h3'), ->
	# 	sendId $(this).text()

	$('#switch button').click ->
		sendState "123456", $(this).attr("value")

	$('#id button').click ->
		sendId $(this).parent().children('input').val()