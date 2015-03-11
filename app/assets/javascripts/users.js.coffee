$ ->
  $('#upload-new-image').on 'click', ->
    $("#user-avatar-kind").val("uploaded")
    $('#uploaded-avatar').trigger('click')
    return false

  $('#uploaded-avatar').on 'change', ->
    $("#upload-form").submit()


$('.toggle-set-group-volume').on 'click', ->
  $('.set-group-volume').toggle()

toggle_email_new_disussions_and_proposals = ->
  if $('#js_email_new_discussions_and_proposals').is(':checked')
    $('.per-group-email-settings input').prop('disabled', false)
    $('.per-group-email-settings input').removeClass('disabled')
    $('.per-group-email-settings').removeClass('disabled')
  else
    $('.per-group-email-settings input').prop('disabled', true)
    $('.per-group-email-settings input').addClass('disabled')
    $('.per-group-email-settings').addClass('disabled')

$ ->
  toggle_email_new_disussions_and_proposals()
  $('#js_email_new_discussions_and_proposals').change ->
    toggle_email_new_disussions_and_proposals()
