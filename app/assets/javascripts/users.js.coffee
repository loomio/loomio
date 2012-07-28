# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#use_uploaded").click((event, ui) ->
    $("#user_avatar_kind").val("uploaded")
    e.preventDefault()
  )

  $("#use_gravatar").click((event, ui) ->
    $("#user_avatar_kind").val("gravatar")
    e.preventDefault()
  )

  $("#use_initials").click((event, ui) ->
    $("#user_avatar_kind").val("")
    e.preventDefault()
  )

  $("#user_uploaded_avatar").change((event, ui) ->
    $("#user_avatar_kind").val("uploaded")
    e.preventDefault()
  )

  $("#upload_image").click((event, ui) ->
    $("#user_uploaded_avatar").click()
  )
