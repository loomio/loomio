$ ->
  $(".dismiss-system-notice").click( (event)->
    $.post($(this).attr("href"))
    $("#system-notice").remove()
    event.preventDefault()
  )

  $(document.body).keypress ->
    keyCode = event.which || event.keyCode
    keyChar = String.fromCharCode(keyCode)
    
    if check_page_focus_non_textarea()
      switch keyChar
        when "g" then show_group_dropdown()
      
check_page_focus_non_textarea = ->
  non_textarea = true
  if $('input').is(":focus")
    non_textarea = false
  if $('textarea').is(":focus")
    non_textarea = false
  return non_textarea
      
show_group_dropdown = ->
  $('#my_groups_header').click()