# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#uploaded-avatar").change((event, ui) ->
    $("#user-avatar-kind").val("uploaded")
    $("#upload-form").submit()
  )

  $("#upload-new-image").click((event, ui) ->
    $("#uploaded-avatar").click()
    event.preventDefault()
  )

# adds bootstrap popovers to user names
$ ->
  isVisible = false
  clickedAway = false

  $('.comment-user-name').popover(
    html: true,
    placement: 'top',
    trigger: 'manual'
  ).click((e)->
    if isVisible
      $(this).popover('hide')
      isVisible = false
      clickedAway = false
    else
      $(this).popover('show')
      clickedAway = false
      isVisible = true
    e.preventDefault()
  )

  $(document).click((e)->
    if(isVisible & clickedAway)
      $('.comment-user-name').popover('hide')
      isVisible = clickedAway = false
    else
      clickedAway = true
  )
