$ ->
  $("#notifications-toggle").click( (event)->
    if (!$(this).parent().hasClass("open"))
      $.ajax(url: $(this).attr("href"), dataType: "script")
  )

$ ->
  notifications = $('#notification-items')
  height = notifications.height()

  notifications.bind('mousewheel', (e, d) ->
    scrollHeight = notifications.get(0).scrollHeight
    if ((this.scrollTop == (scrollHeight - height) && d < 0) || (this.scrollTop == 0 && d > 0))
      e.preventDefault()
  )
