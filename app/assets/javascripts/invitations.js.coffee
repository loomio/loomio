window.Application ||= {}

$ ->
  if $(".js-autocomplete-contacts").length > 0
    autocomplete_path = $('.js-autocomplete-contacts').data('autocomplete-path')
    $("textarea.js-autocomplete-contacts").atwho
      at: '',
      tpl: "<li id='${id}' data-value='${name_and_email}, '>${name} &lt;${email}&gt;</li>"
      limit: 5
      callbacks:
        remote_filter: (query, callback) ->
          if query.length > 2
            $.getJSON autocomplete_path, {q: query}, (data) ->
              callback(data)

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
