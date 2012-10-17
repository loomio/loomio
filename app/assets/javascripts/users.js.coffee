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
  $('.user-name-with-popover').popover(
    html: true,
    placement: 'top',
    trigger: 'manual'
  )
  $('.user-name-with-popover').click((e)->
    if isVisible
      $(this).addClass("selected")
      $('.user-name-with-popover').each ->
        if $(this).hasClass("selected")
          if $(this).hasClass("popover-visible")
            toggle_popover(false, $(this))
            isVisible = false
          else
            toggle_popover(true, $(this))
            isVisible = true
        else
          toggle_popover(false, $(this))
      $(this).removeClass("selected")
      clickedAway = false
    else
      toggle_popover(true, $(this))
      clickedAway = false
      isVisible = true
    e.preventDefault()
  )

  $(document).click((e)->
    if(isVisible & clickedAway)
      target = e.target
      if !$(target).closest(".popover").length
        toggle_popover(false, $('.user-name-with-popover'))
        isVisible = false
        clickedAway = false
    else
      clickedAway = true
  )

  $('#ng-values .btn-group > .btn, #noise_email.btn-group > .btn').click((e) -> 
    $(this).parent().find('a.btn').each( (i) ->
      $(this).removeClass('active')
    )
    $(this).addClass('active')
  )

  toggle_popover = (show, elem) ->
    if show
      elem.popover('show')
      elem.addClass('popover-visible')
    else
      elem.popover('hide')
      elem.removeClass('popover-visible')
