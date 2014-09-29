$ ->
  $('body.group_requests').on 'change', 'select#group_request_is_commercial', ->
    modal_target = if $(@).val() == 'true' then '#commercial' else '#non_commercial'
    $('a.commercial-modal-toggle').attr('data-target', modal_target)