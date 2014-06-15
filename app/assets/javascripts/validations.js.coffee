window.Application ||= {}

$ ->
  Application.hideAllErrorMessages()

### EVENTS ###

$ -> # Remove error class on field if not empty
  $(".validate-presence").change () ->
    hidePresenceErrorMessageFor($(this))

$ -> # Remove error class on field if not empty
  $(".validate-presence").keyup () ->
    hidePresenceErrorMessageFor($(this))

$ -> # Character counter for limiting input
  $(".validate-length").bind 'input propertychange', ->
    $(".error-message").hide()
    max = 250 if $(this).hasClass('limit-250')
    max = 150 if $(this).hasClass('limit-150')
    string = $(this).val().replace(/\r\n|\r|\n/g, '11')
    chars = string.length
    left = max - chars
    display_count(left, $(this))

$ -> # Run validations and prevent default if false
  $(".run-validations").click (event, ui) ->
    form = $(this).parents("form")
    unless Application.validateForm(form)
      event.preventDefault()


### FUNCTIONS ###

Application.validateForm = (form) ->
  formError = ''
  form.find(".validate-presence").each((index, field) ->
    formError = 'A mandatory field has been left blank, please fill it out and try again' unless validatePresence(field)
    return
    )
  form.find(".validate-length").each((index, field) ->
    formError = 'One of the fields has too many characters, please remove some of the characters and try again' unless validateInputLength(field)
    return
    )
  formError = 'There is a problem with the form' unless Application.validateEmailsAndConfirm($(".validate-emails"))
  formError = 'The date you have chosen is invalid, please choose another date and try again' unless Application.validateMotionCloseDate($(".motion-closing-inputs"))
  alert(formError) unless formError == ''
  (formError == '')

Application.hideAllErrorMessages = () ->
  $(".inline-help").hide()
  $(".email-validation-help").hide()

validatePresence = (field) ->
  if $(field).is(":visible") && $(field).val() == ""
    parentFor(field).addClass("error")
    parentFor(field).find(".inline-help").show()
    return false
  true

validateInputLength = (field) ->
  return false if $(field).closest('.control-group').hasClass('error')
  true

hidePresenceErrorMessageFor = (field) ->
  unless $(field).val() == ""
    parentFor(field).removeClass("error")
    parentFor(field).find(".inline-help").hide()

parentFor = (field) ->
  $(field).closest('.control-group').parent().closest('.control-group')

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
