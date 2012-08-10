$ ->
  $("#notifications-toggle").click((event)->
    if (!$(this).parent().hasClass("open"))
      # Mark notifications as read
      $.post(
        $(this).attr("ajax-path")
        dataType: "script"
        success: ->
          $("#notifications-count").addClass("hidden")
          document.title = "Loomio"
      )
  )

$ ->
  # Prevent scrolling on notifications box from scrolling down the rest of the page
  notifications = $('#notification-items')
  height = notifications.height()
  notifications.bind('mousewheel', (e, d) ->
    scrollHeight = notifications.get(0).scrollHeight
    if ((this.scrollTop == (scrollHeight - height) && d < 0) || (this.scrollTop == 0 && d > 0))
      e.preventDefault()
  )

$ ->
  # Prevent close of dropdown on click
  $(".notification-item").click((event)->
    event.stopPropagation()# if (event.metaKey || event.ctrlKey)
  )
