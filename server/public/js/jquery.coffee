$ = jQuery
$ ->
	$('#switch button').click ->
		switchState $(this).attr("value")

	$('#id button').click ->
		sendId $(this).parent().children('input').val()