$ -> #initialiazation of form
  if $("body.group_setup").length > 0
    hideButtons()
    $('#group_setup_group_name').focus()


# EVENTS

$ -> #button functionality
  if $("body.group_setup").length > 0
    $("#next").on 'click', (event) ->
      form = $(this).parents("form")
      if Application.validateForm(form)
        $('ul.nav-tabs li.active').next().find('a').tab('show')

    $("#prev").on 'click', (event) ->
      $('ul.nav-tabs li.active').prev().find('a').tab('show')

    $("#finish").on 'click', (event) ->
      form = $(this).parents("form")
      unless Application.validateForm(form)
        event.preventDefault()

$ -> #hide/show buttons on tab change
  if $("body.group_setup").length > 0
    if $("body.group_setup").length > 0
      $('.nav-tabs li a').on 'shown', (event) ->
        hideButtons()

$ -> #indicate error on field if blank
  if $("body.group_setup").length > 0
    $('.validate-presence').on 'focusout', (event) ->
      Application.validatePresence(this)

hideButtons = () ->
  activeTab = $('ul.nav-tabs li.active')
  if activeTab[0] == $('ul.nav-tabs li:first')[0]
    $('#prev').hide()
  else
    $('#prev').show()
  if activeTab[0] == $('ul.nav-tabs li:last')[0]
    $('#next').hide()
    $('#finish').show()
  else
    $('#next').show()
    $('#finish').hide()
