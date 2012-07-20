# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(document.body).keypress ->
    keyCode = event.which || event.keyCode
    keyChar = String.fromCharCode(keyCode)
  
    if !$('#new-comment').is(":focus")
      switch keyChar
        when "i" then show_group_homepage()
        when "g" then show_group_dropdown()
        when "j" then show_previous_discussion()
        when "k" then show_next_discussion()

show_group_dropdown = ->
  $('#my_groups_header').click()

show_previous_discussion = ->
  $('#previous_button')[0].click()

show_next_discussion = ->
  $('#next_button')[0].click()

show_group_homepage = ->
  $('.group-title h2 a')[0].click()