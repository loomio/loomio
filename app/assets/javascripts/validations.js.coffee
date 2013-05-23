 #The following methods are used to provide client side validation for
 #- character count
 #- date validation specific for motion-form

$ -> # Remove error class on field if not empty
  $(".validate-presence").change () ->
    hidePresenceErrorMessageFor($(this))

$ -> # Remove error class on field if not empty
  $(".validate-presence").keyup () ->
    hidePresenceErrorMessageFor($(this))

$ -> # Run validations and prevent default if false
  $(".run-validations").click (event, ui) ->
    form = $(this).parents("form")
    unless Application.validateForm(form)
      event.preventDefault()

Application.validateForm = (form) ->
  formValid = true
  form.find(".validate-presence").each((index, field) ->
    formValid = false unless validatePresence(field)
    return
    )
  formValid = false unless Application.validateEmailsAndConfirm($(".validate-emails"))
  formValid = false unless Application.validateMotionCloseDate($(".motion-closing-inputs"))
  alert('There is a problem with the form') unless formValid
  formValid

validatePresence = (field) ->
  if $(field).is(":visible") && $(field).val() == ""
    parentFor(field).addClass("error")
    parentFor(field).find(".inline-help").show()
    return false
  true

hidePresenceErrorMessageFor = (field) ->
  unless $(field).val() == ""
    parentFor(field).removeClass("error")
    parentFor(field).find(".inline-help").hide()

parentFor = (field) ->
  $(field).closest('.control-group').parent().closest('.control-group')

hideAllErrorMessages = () ->
  $(".inline-help").hide()
  $(".email-validation-help").hide()

