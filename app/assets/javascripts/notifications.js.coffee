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
    if (!$(this).parent().hasClass("open"))
      if $('li.notification-item').length > 0
        notification_css_id = $('li.notification-item').first().attr('id')
        notification_id = /\d+/.exec(notification_css_id)
        $.post("/notifications/mark_as_viewed?latest_viewed=#{notification_id}")
$ ->
  $("#group-dropdown-items").load('/notifications/groups_tree_dropdown')

$ ->
  timeout_multiplier = 1
  load_inbox_count = () =>
    timeout_multiplier += 1
    $.ajax
      url: '/inbox/size',
      success: (count) ->
        $('#inbox-count').text(count);
      complete: ->
        setTimeout(load_inbox_count, timeout_multiplier*60*1000);

  load_inbox_count()
