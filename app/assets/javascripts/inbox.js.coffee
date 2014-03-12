$ ->
  $(".mark-as-read-btn").tooltip
    placement: "top",
    title: 'Mark as read'
    delay: 500

  $(".unread-comments-count").tooltip
    placement: "right",
    title: "Unread comments"
    delay: 500

  $(".unread-votes-count").tooltip
    placement: "right",
    title: "New votes"
    delay: 500

fade_time = 150

remove_group_if_empty = (group_div) ->
  # remove the whole inbox group if it is empty
  if group_div.find('li').length == 0
    group_div.fadeOut fade_time, ->
      $(this).remove()

show_inbox_empty_msg_if_empty = ->
  # put up inbox empty message if inbox is empty
  inbox_container = $('.inbox-container')
  if inbox_container.find('.inbox-group').length == 0
    $('.inbox-empty-msg').show()

$ ->
  step = 0
  load_inbox_count = ->
    step += 1 if step < 5
    $.ajax
      url: '/inbox/size',
      success: (count) ->
        $('#inbox-count').text(count);
      complete: ->
        setTimeout(load_inbox_count, step*60*1000);

  load_inbox_count()

$ ->
  #load sparklines for motion pies
  $('.motion-sparkline').sparkline('html', { disableTooltips: true, type: 'pie', height: '26px', width: '26px', sliceColors: [ "#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc'] })

  if $('body.inbox').length > 0
    $('.ui-sortable').sortable()

    $('.mark-all-as-read-btn').on 'click', (e) ->
      group_div = $(e.target).parents('.inbox-group')
      items = group_div.find('li')
      items.fadeOut fade_time, ->
        $(this).remove()
        remove_group_if_empty(group_div)
        show_inbox_empty_msg_if_empty

    $('.mark-as-read-btn, .unfollow-btn').on 'click', (e) ->
      group_div = $(e.target).parents('.inbox-group')
      list = $(e.target).parents('ul')
      row = $(e.target).parents('li')

      # remove the row for the item marked as read
      row.fadeOut fade_time, ->
        $(this).remove()
        remove_group_if_empty(group_div)
        show_inbox_empty_msg_if_empty



    # find times to be updated in javascript
    $('.js-format-as-timeago').each ->
      time = moment($(this).data('time'))
      $(this).text(time.fromNow(true))

