# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  # Only execute on group page
  if $("body.groups").length > 0
    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )

#$ ->
  #isVisible = false
  #clickedAway = false

  #$('.info-help').popover(html: true, trigger: 'manual', placement: 'top').click((e) ->
    #$(this).popover('show')
    #isVisible = true
    #e.preventDefault()
  #)

  #$(document).click((e) ->
    #if(isVisible & clickedAway)
      #$('.info-help').popover('hide')
      #isVisible = clickedAway = false
    #else
      #clickedAway = true
  #)
