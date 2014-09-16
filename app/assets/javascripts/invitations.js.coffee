$ ->
  $('#new_invite_people_form').on 'submit', (e) ->
    emails = parseEmailsFromString($('#invitees').val())
    $(".recipients").val(emails.toString())

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

parseEmailsFromString = (input_emails) ->
  parsed_emails = []
  regex = /[^\s<,]+?@[^>,\s]+/g
  while(matches = regex.exec(input_emails))
    parsed_emails.push(matches[0])
  parsed_emails
