window.Application ||= {}

### EVENTS ###

$ -> # Remove email help class if changed
  $(".validate-emails").keyup () ->
    hideValidateEmailErrorMessageFor($(this))

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
    parentMembersEmpty = $('.invite_people_form_parent_members_to_add input:checked:enabled').length == 0
    emailListEmpty = emailList.length == 0
    if parentMembersEmpty && emailListEmpty
      addValidateEmailErrorMessageFor($(field))
      return false
    else
      $(".recipients").val(emailList.toString())
  true


addValidateEmailErrorMessageFor = (field) ->
  $(field).parent().addClass("error")
  $(field).parent().find(".email-validation-help").show()

hideValidateEmailErrorMessageFor = (field) ->
  $(field).parent().removeClass("error")
  $(field).parent().find(".email-validation-help").hide()