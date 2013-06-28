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

$ ->
  # load the notifications on page load
  $("li#notification-dropdown-items").load('/notifications/dropdown_items')

  # when the user clicks the notifications toggle, send mark as viewed event
  $("a#notifications-toggle").on 'click', (event) ->
    if $('li.notification-item').length > 0
      notification_css_id = $('li.notification-item').first().attr('id')
      notification_id = /\d+/.exec(notification_css_id)
      $.post("/notifications/mark_as_viewed?latest_viewed=#{notification_id}")
$ ->
  $("#group-dropdown-items").load('/notifications/groups_tree_dropdown')
  #$('#inbox-container').load('ccn
