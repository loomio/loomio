$ ->
  $(document).on 'keydown', (event) ->
    active = $(document.activeElement)
    if active.is('.group-dropdown-search, .selector-link')
      switch event.which
        when 40 # select next group with down arrow
          target = active.parent().next('.group-item:visible').find('.selector-link')
          target = $('#group-dropdown-items').find('.group-item:visible').first().find('.selector-link') if target.length is 0
        when 38 # select prev group with up arrow
          target = active.parent().prev('.group-item:visible').find('.selector-link')
          target = $('#group-dropdown-items').find('.group-item:visible').last().find('.selector-link') if target.length is 0
      if target?
        target.focus()
        event.preventDefault()

    if !active.is('input, textarea, select') or event.which == 27
      switch event.which
        when 71 # G for groups search dropdown
          $('#groups>a').click()
          $('#groups').find('.group-dropdown-search').focus()
          event.preventDefault()
        when 27 # ESC for closing groups search dropdown (if it's open)
          if $('#groups').hasClass('open')
            $('#groups>a').click()
        when 78 # N for notifications dropdown
          $('#notifications-container>a').click()
        when 83 # S for search box
          $('#search_form_query').focus()
          event.preventDefault()
        when 85 # U for user dropdown
          $("#user>a").click()
