$ ->
  $('body.group_requests').on 'change', 'select#group_request_is_commercial', ->
    modal_target = if $(@).val() == 'true' then '#commercial' else '#non-commercial'
    $('a.commercial-page-show').attr('data-target', modal_target)

  $('body.group_requests').on 'click', 'a.commercial-page-show', ->
    $($(@).data('target')).slideDown('slow')

  $('body.group_requests').on 'click', 'a.commercial-page-toggle', ->
    $('.commercial-page').toggle()