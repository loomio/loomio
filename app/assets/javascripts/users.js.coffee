# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#uploaded-avatar").change((event, ui) ->
    $("#user-avatar-kind").val("uploaded")
    $(".edit_user").submit()
  )

  $("#fake-upload").click((event, ui) ->
    $("#uploaded-avatar").click()
    event.preventDefault()
  )
