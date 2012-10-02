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
  )
  $('.comment-user-name').click((e)->
    if isVisible
      console.log("isVisible")
      if not $(this).hasClass('popover-visible')
        console.log("there is a popup visible and but not this one")
        $('.comment-user-name').popover('hide')
        $('.comment-user-name').removeClass('popover-visible')
        console.log("remove all popups1")
        $(this).popover('toggle')
        console.log("show this popup and add class visible")
        $(this).addClass('popover-visible')
        isVisible = true
        clickedAway = false
      else
        console.log("clicked popup was visible")
        $('.comment-user-name').popover('hide')
        $('.comment-user-name').removeClass('popover-visible')
        console.log("remove all popups2")
        isVisible = false
        clickedAway = false 
    else
      console.log("non-visible, showing popover")
      $(this).popover('show')
      $(this).addClass('popover-visible')
      clickedAway = false
      isVisible = true
    e.preventDefault()
  )

  $(document).click((e)->
    if(isVisible & clickedAway)
      console.log("visible and clickedAway - hiding popover")
      #$('.comment-user-name').popover('hide')
      #$('.comment-user-name').removeClass('popover-visible')
      isVisible = false
      clickedAway = false
    else
      console.log("clickedAway = true")
      console.log("-------------------")
      clickedAway = true
  )
