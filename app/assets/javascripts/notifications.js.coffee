$ ->
  $("#notification-toggle").dropdown()
  $("#notification-toggle").click( (event)->
    $(this).dropdown()
    $.ajax(url: $(this).attr("href"), dataType: "script")
  )
