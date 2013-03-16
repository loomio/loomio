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
  # Prevent close of dropdown on click
  $(".notification-item").click((event)->
    event.stopPropagation()# if (event.metaKey || event.ctrlKey)
  )
