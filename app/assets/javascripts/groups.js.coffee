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


# Info-tips
$ ->
  $(".info-help").tooltip(placement: 'top', trigger: 'manual')
  $(".info-help").hover(
    (e) ->
      $(this).css('background-image', 'url("/assets/dark-info.png")')
    (e) ->
      $(this).css('background-image', 'url("/assets/info.png")')
      $(this).tooltip('hide')
  )

$ ->
  $(".info-help").click((event) ->
    $(this).tooltip('show')
  )
