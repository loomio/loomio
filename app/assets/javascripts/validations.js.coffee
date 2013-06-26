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

$ -> # Remove error class on closing inputs if changed
  $(".motion-close-at-date").change () ->
    hideDateErrorMessageFor($(this))

$ -> # Remove error class on closing inputs if changed
  $(".motion-close-at-time").change () ->
    hideDateErrorMessageFor($(this))

$ -> # Remove error class on closing inputs if changed
  $(".motion-close-at-time-zone").change () ->
    hideDateErrorMessageFor($(this))

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
  formValid = false unless validateMotionCloseDate($(".motion-closing-inputs"))
  alert('There is a problem with the form') unless formValid
  formValid

Application.hideAllErrorMessages = () ->
  $(".inline-help").hide()
  $(".email-validation-help").hide()

Application.isValidDate = (dateString) -> #takes input in the form 'yyyy-mm-dd'
  bits = dateString.split('-')
  new_date = new Date(bits[2], bits[1] - 1, bits[0])
  return new_date && (new_date.getMonth() + 1) == parseInt(bits[1]) && new_date.getDate() == parseInt(bits[0])

validatePresence = (field) ->
  if $(field).is(":visible") && $(field).val() == ""
    addError(parentFor(field))
    return false
  true

validateInputLength = (field) ->
  return false if $(field).closest('.control-group').hasClass('error')
  true

validateMotionCloseDate = (closeAtParent) ->
  if $(closeAtParent).is(":visible")
    timeNow = new Date()
    unless Application.isValidDate(closeAtParent.find('.motion-close-at-date').val())
      addError(closeAtParent)
      return false
    if Application.parseCloseDateTimeZoneFields(closeAtParent) < timeNow
      addError(closeAtParent)
      return false
  true

addError = (errorField) ->
  $(errorField).addClass("error")
  $(errorField).find(".inline-help").show()

removeError = (errorField) ->
  $(errorField).removeClass("error")
  $(errorField).find(".inline-help").hide()

hidePresenceErrorMessageFor = (field) ->
  unless $(field).val() == ""
   removeError(parentFor(field))

hideDateErrorMessageFor = (field) ->
  removeError($(field).closest('.motion-closing-inputs'))

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
