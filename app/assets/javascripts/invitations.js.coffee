window.Application ||= {}

### EVENTS ###

$ -> # Remove email help class if changed
  $(".validate-emails").keyup () ->
    hideValidateEmailErrorMessageFor($(this))

$ -> # Parse emails and display number of valid ones
  $(".validate-emails").focusout () ->
    emailList = parseEmails($(this).val())
    validateMinimumEmailCount(this, emailList.length)


### FUNCTIONS ###

parseEmails = (input_emails) ->
  parsed_emails = []
  regex = /[^\s<,]+?@[^>,\s]+/g
  while(matches = regex.exec(input_emails))
    parsed_emails.push(matches[0])
  parsed_emails

Application.validateEmailsAndConfirm = (field) ->
  if $(field).is(":visible")
    emailList = parseEmails($(field).val())
    return false unless validateMinimumEmailCount(field, emailList.length)
    return false unless confirm("#{emailList.length} invitations will be sent")
    $(".recipients").val(emailList.toString())
  true

validateMinimumEmailCount = (field, num) ->
  if num == 0
    $(field).parent().addClass('error')
    $(field).parent().find(".email-validation-help").show()
    return false
  true

hideValidateEmailErrorMessageFor = (field) ->
  $(field).parent().removeClass("error")
  $(field).parent().find(".email-validation-help").hide()