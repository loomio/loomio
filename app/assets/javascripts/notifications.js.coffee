$ ->
  # load the notifications on page load
  $("li#notification-dropdown-items").load('/notifications/dropdown_items')

  # when the user clicks the notifications toggle, send mark as viewed event
  $("a#notifications-toggle").on 'click', (event) ->
    if (!$(this).parent().hasClass("open"))
      if $('li.notification-item').length > 0
        $('#notifications-count').text('')
        notification_css_id = $('li.notification-item').first().attr('id')
        notification_id = /\d+/.exec(notification_css_id)
        $.post("/notifications/mark_as_viewed?latest_viewed=#{notification_id}")

$ ->
  $(".navbar").on 'click', '.notification-item', (event) ->
    event.stopPropagation()  if (event.metaKey || event.ctrlKey)

$ ->
  $("#group-dropdown-items").load('/notifications/groups_tree_dropdown', ->
    if $(@).find('.group-item').length > 10
      $(@).siblings('.group-dropdown-search').show()
  )

$ ->
  $('#groups').on 'click', '.group-dropdown-search', (event) ->
    event.preventDefault()
    event.stopPropagation()

  $('#groups').on 'keyup', '.group-dropdown-search', (event) ->
    groups  = $('#group-dropdown-items').find('.group-link-name')
    val     = $(@).val().toLowerCase()
    visible = groups.filter ->
      @.innerHTML.toLowerCase().indexOf(val) >= 0
    hidden  = groups.not(visible)

    visible.closest('.group-item').show()
    hidden.closest('.group-item').hide()
    $(@).siblings('.no-groups-found').toggle(visible.length == 0)
