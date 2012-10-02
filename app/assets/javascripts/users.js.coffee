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
      $(this).addClass("selected")
      $('.comment-user-name').each ->
        if $(this).hasClass("selected")
          if $(this).hasClass("popover-visible")
            toggle_popover(false, $(this))
            #$(this).popover('hide')
            #$(this).removeClass('popover-visible')
            isVisible = false
          else
            toggle_popover(true, $(this))
            #$(this).popover('show')
            #$(this).addClass('popover-visible')
            isVisible = true
        else
          toggle_popover(false, $(this))
          #$(this).popover('hide')
          #$(this).removeClass('popover-visible')
      $(this).removeClass("selected")
      clickedAway = false
    else
      #$(this).popover('show')
      #$(this).addClass('popover-visible')
      toggle_popover(true, $(this))
      clickedAway = false
      isVisible = true
    e.preventDefault()
  )

  $(document).click((e)->
    if(isVisible & clickedAway)
      toggle_popover(false, $('.comment-user-name'))
      #$('.comment-user-name').popover('hide')
      #$('.comment-user-name').removeClass('popover-visible')
      isVisible = false
      clickedAway = false
    else
      clickedAway = true
  )

  toggle_popover = (show, elem) ->
    #elem.each ->
    if show
      elem.popover('show')
      elem.addClass('popover-visible')
    else
      elem.popover('hide')
      elem.removeClass('popover-visible')

