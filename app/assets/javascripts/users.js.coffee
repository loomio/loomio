# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
# unhide edit user name form
$ ->
  $('#edit-name-link').click((event) ->
    $('#edit-name-row').addClass('hidden')
    $('#edit-name-form').removeClass('hidden')
    event.preventDefault()
  )

# hide edit user name form
$ ->
  $('#cancel-edit-name').click((event) ->
    $('#edit-name-form').addClass('hidden')
    $('#edit-name-row').removeClass('hidden')
    event.preventDefault()
  )

$ ->
  $("#uploaded-avatar").change((event, ui) ->
    $("#user-avatar-kind").val("uploaded")
    $("#upload-form").submit()
  )
