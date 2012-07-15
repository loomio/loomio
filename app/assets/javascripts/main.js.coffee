$ ->
  $(".dismiss-system-notice").click( (event)->
    $.post($(this).attr("href"))
    $("#system-notice").remove()
    event.preventDefault()
  )
