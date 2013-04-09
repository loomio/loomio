$ ->
  if $("body.group_setup").length > 0
    hideButtons()
    $("#next").click((event) ->
      $('ul.nav-tabs li.active').next().find('a').tab('show')
    )
    $("#prev").click((event) ->
      $('ul.nav-tabs li.active').prev().find('a').tab('show')
    )

$ ->
  $('a[data-toggle="pill"]').on 'shown', (event) ->
    hideButtons()

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
