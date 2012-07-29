# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#use_uploaded").click((event, ui) ->
    $("#user_avatar_kind").val("uploaded")
    $("#user-initials-preview").hide()
    $("#user-gravatar-preview").hide()
    $("#user-uploaded-preview").show()
    event.preventDefault()
  )

  $("#use_gravatar").click((event, ui) ->
    $("#user_avatar_kind").val("gravatar")
    $("#user-initials-preview").hide()
    $("#user-uploaded-preview").hide()
    $("#user-gravatar-preview").show()
    event.preventDefault()
  )

  $("#use_initials").click((event, ui) ->
    $("#user_avatar_kind").val("")
    $("#user-gravatar-preview").hide()
    $("#user-uploaded-preview").hide()
    $("#user-initials-preview").show()
    event.preventDefault()
  )

  $("#user_uploaded_avatar").change((event, ui) ->
    window.location.reload()
    event.preventDefault()
  )

  $("#upload_image").click((event, ui) ->
    $("#user_uploaded_avatar").click()
    event.preventDefault()
  )
