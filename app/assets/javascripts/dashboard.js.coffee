# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#*** ajax for discussions ***
$ ->
  $('#user-discussions').load("/discussions", 'group=false',
    Application.convertUtcToRelativeTime)

$ ->
  $(document).on('click', '.pagination a', (e)->
    $('#user-discussions').load($(this).attr('href'),
      Application.convertUtcToRelativeTime)
    e.preventDefault()
  )

