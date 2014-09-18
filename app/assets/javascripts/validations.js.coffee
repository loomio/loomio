window.Application ||= {}

$ -> # Character counter for limiting input
  $(".validate-length").bind 'input propertychange', ->
    $(".error-message").hide()
    max = 250 if $(this).hasClass('limit-250')
    max = 150 if $(this).hasClass('limit-150')
    string = $(this).val().replace(/\r\n|\r|\n/g, '11')
    chars = string.length
    left = max - chars
    display_count(left, $(this))

display_count = (num, object) -> # Display charcaters left
  if(num >= 0)
    object.parent().find(".character-counter").text(pluralize_characters(num) + " left")
    object.parent().removeClass("error")
  else
    num = num * (-1)
    object.parent().find(".character-counter").text(pluralize_characters(num) + " too long")
    object.parent().addClass("error")

pluralize_characters = (num) ->
  if(num == 1)
    return num + " character"
  else
    return num + " characters"
