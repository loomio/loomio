$ ->
  $(".mark-as-read-btn").tooltip
    placement: "top",
    title: 'Mark as read'
    delay: 800

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
  if $('body.inbox').length > 0
    $('.ui-sortable').sortable()

    $('.mark-all-as-read-btn').on 'click', (e) -> 
      group_div = $(e.target).parents('.inbox-group')

      group_div.find('li.discussion').fadeOut fade_time, ->
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

    #
    # Load discussion counts
    #

    discussion_css_class = '.discussion'

    # read all the discussion ids into a list
    discussion_ids = $.map $(discussion_css_class), (e) ->
      $(e).data('discussion-id')

    $.get '/discussions/activity_counts', {discussion_ids: discussion_ids.join('x')}, (discussion_counts) ->
      i = 0
      $(discussion_css_class).each ->
        i = discussion_ids.indexOf($(this).data('discussion-id'))
        $(this).find('.activity-count').text(discussion_counts[i])

    $('.motion-sparkline').sparkline('html', { type: 'pie', height: '26px', width: '26px', sliceColors: [ "#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc'] })
    #
    # Load motion sparklines
    #
    #motion_css_class '.motion-icon'

    ## read all the motion ids into a list
    #motion_ids = $.map $(motion_css_class), (e) ->
      #$(e).data('motion-id')

    #$.get '/motions/vote_data', {motion_ids: motion_ids}, (motion_data) ->
      #i = 0
      #$(motion_css_class).each ->
        #i = motion_ids.indexOf($(this).data('motion-id'))
        #$(this).find('.motion-sparkline').sparkline(motion_data[i], type: 'pie')


    #
    # find times to be updated in javascript
    #
    $('.js-format-as-timeago').each ->
      time = moment($(this).data('time'))
      $(this).text(time.fromNow(true))
      
    #console.log(discussion_ids)

    #motion_ids = $.map $('.inbox-motion-icon'), (e) -> 
      #$(e).data('motion-id')



