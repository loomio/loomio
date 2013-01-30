# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


# unhide edit user name form
$ ->
  $('#edit-name-link').click((event) ->
    $(this).addClass('hidden')
    $('#edit-name-form').removeClass('hidden')
    event.preventDefault()
  )

# hide edit user name form
$ ->
  $('#cancel-edit-name').click((event) ->
    $('#edit-name-form').addClass('hidden')
    $('#edit-name-link').removeClass('hidden')
    event.preventDefault()
  )

$ ->
  $('.image-setting').click((event) ->
    if not $('#file-too-big-message').hasClass('hidden')
      $('#file-too-big-message').addClass('hidden')
  )

$ ->
  $("#uploaded-avatar").change((event, ui) ->
    size = this.files[0].size/1024
    if size < $('#max-file-size').val()
      $("#user-avatar-kind").val("uploaded")
      $("#upload-form").submit()
    else
      $('#file-too-big-message').removeClass('hidden')
      $(this).val("")
  )

  $("#upload-new-image").click((event, ui) ->
    $("#uploaded-avatar").click()
    event.preventDefault()
  )

# adds bootstrap popovers to user names
Application.setupPopovers = () ->
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

  toggle_popover = (show, elem) ->
    if show
      elem.popover('show')
      elem.addClass('popover-visible')
    else
      elem.popover('hide')
      elem.removeClass('popover-visible')

$ ->
  Application.setupPopovers()
