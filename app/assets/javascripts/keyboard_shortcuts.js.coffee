$ ->
  $(document).on 'keydown', (event) ->
    active = $(document.activeElement)
    if active.is('.group-dropdown-search, .selector-link')
      switch event.which
        when 40 # select next group with down arrow
          target = active.parent().next('.group-item').find('.selector-link')
          target = $('#group-dropdown-items').find('.selector-link').first() if target.length is 0
        when 38 # select prev group with up arrow
          target = active.parent().prev('.group-item').find('.selector-link')
          target = $('#group-dropdown-items').find('.selector-link').last() if target.length is 0
      target.focus() if target?
      event.preventDefault()

    if active.not('input, textarea, select') or event.which == 27
      switch event.which
        when 71, 27 # G or ESC for groups search dropdown
          $('#groups>a').click()
          $('#groups').find('.group-dropdown-search').focus()
          event.preventDefault()
        when 78 # N for notifications dropdown
          $('#notifications-container>a').click()
        when 83 # S for search box
          $('#search_form_query').focus()
          event.preventDefault()
        when 85 # U for user dropdown
          $("#user>a").click()