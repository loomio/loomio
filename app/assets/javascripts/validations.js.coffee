window.Application ||= {}

$ -> # Character counter for limiting input
  $(".validate-length").on 'keypress', ->
    remaining = 250 - $(@).val().length
    if(remaining >= 0)
      $(".character-counter").text(pluralize_characters(remaining) + " left")
    else
      $(".character-counter").text(pluralize_characters(-remaining) + " too long")

pluralize_characters = (num) ->
  if(num == 1)
    return num + " character"
  else
    return num + " characters"
