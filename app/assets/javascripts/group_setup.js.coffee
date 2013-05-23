### INITIASLIZATION ###

$ -> #initialiazation of form
  if $("body.group_setup").length > 0
    hideButtons()
    $('#group_setup_group_name').focus()

### EVENTS ###

$ -> #button functionality
  if $("body.group_setup").length > 0

    $("#prev").on 'click', (event) ->
      $('ul.nav-tabs li.active').prev().find('a').tab('show')
      event.preventDefault()

    $("#next, #start").on 'click', (event) ->
      form = $(this).parents("form")
      if Application.validateForm(form)
        $('ul.nav-tabs li.active').next().find('a').tab('show')
        event.preventDefault()

$ -> #hide/show buttons on tab change
  if $("body.group_setup").length > 0
    if $("body.group_setup").length > 0
      $('.nav-tabs li a').on 'shown', (event) ->
        hideButtons()


### FUCTIONS ###

hideButtons = () ->
  activeTab = $('ul.nav-tabs li.active')
  if activeTab[0] == $('ul.nav-tabs li:first')[0]
    $('#prev').hide()
    $('#send_invites').hide()
    $('#next').hide()
  else
    $('#prev').show()
  if activeTab[0] == $('ul.nav-tabs li:last')[0]
    $('#send_invites').show()
    $('#next').hide()
  else
    $('#next').show() unless activeTab[0] == $('ul.nav-tabs li:first')[0]
    $('#send_invites').hide()
