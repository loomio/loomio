window.Application ||= {}


### EVENTS ###

$ -> # Remove error class on field if not empty
  $(".validate-presence").change () ->
    hidePresenceErrorMessageFor($(this))

$ -> # Remove error class on field if not empty
  $(".validate-presence").keyup () ->
    hidePresenceErrorMessageFor($(this))

$ -> # Character counter for limiting input
  $(".validate-length").keyup () ->
    $(".error-message").hide()
    max = 250 if $(this).hasClass('limit-250')
    max = 150 if $(this).hasClass('limit-150')
    chars = $(this).val().length
    left = max - chars
    display_count(left, $(this))

$ -> # Run validations and prevent default if false
  $(".run-validations").click (event, ui) ->
    form = $(this).parents("form")
    unless Application.validateForm(form)
      event.preventDefault()


### FUNCTIONS ###

Application.validateForm = (form) ->
  formValid = true
  form.find(".validate-presence").each((index, field) ->
    formValid = false unless validatePresence(field)
    return
    )
  form.find(".validate-length").each((index, field) ->
    formValid = false unless validateInputLength(field)
    return
    )
  formValid = false unless Application.validateEmailsAndConfirm($(".validate-emails"))
  formValid = false unless Application.validateMotionCloseDate($(".motion-closing-inputs"))
  alert('There is a problem with the form') unless formValid
  formValid

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
