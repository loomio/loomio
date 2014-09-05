# adds bootstrap popovers to group activity indicators
activate_discussions_tooltips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'

is_subgroup = ->
  $('#group_parent_id').val().length > 0

disable = ($el) ->
  $el.prop('disable', true)
  $el.parent().addClass('disabled')

check = ($el) ->
  $el.prop('checked', true)

toggle_discussion_privacy_options = ->
  if is_subgroup()
    if $('#group_visible_to_public').is(':checked')
      $('.group_parent_members_can_see_discussions').hide()
      $('.group_discussion_privacy_options').show()
    else
      $('.group_parent_members_can_see_discussions').show()
      $('.group_discussion_privacy_options').hide()

set_private_discussions_only = ->
  #check private discussions only
  if !$('#group_visible_to_parent_members').is(':checked')
    check $('#group_parent_members_can_see_discussions_false')
    disable $('#group_parent_members_can_see_discussions_true')


  check $('#group_discussion_privacy_options_private_only')

  #disable other privacy choices
  disable $('#group_discussion_privacy_options_public_or_private,
             #group_discussion_privacy_options_public_only')

set_public_discussions_only = ->
  #check public discussions only
  check $('#group_discussion_privacy_options_public_only')
  #disable other privacy choices
  disable $('#group_discussion_privacy_options_public_or_private,
             #group_discussion_privacy_options_private_only')

set_invitation_only = ->
  #check invitation only
  check $('#group_membership_granted_upon_invitation')
  # disable other invitation choices
  disable $('#group_membership_granted_upon_request,
             #group_membership_granted_upon_approval')

set_members_can_add_members_only = ->
  check $('#group_members_can_add_members_true')
  disable $('#group_members_can_add_members_false')

update_group_form_state = ->
  return unless $('form.group-settings').length > 0

  #undisable everything
  $('form.group-settings input').prop('disabled', false)
  $('form.group-settings label').removeClass('disabled')
  toggle_discussion_privacy_options()
  $('.group_members_can_add_members').show()

  if $('#group_visible_to_public').is(':checked')
    #if anyone can join
    if $('#group_membership_granted_upon_request').is(':checked')
      set_public_discussions_only()
      set_members_can_add_members_only()


  if $('#group_visible_to_parent_members').is(':checked')
    #set_invitation_only()
    set_private_discussions_only()

  if $('#group_visible_to_members').is(':checked')
    set_invitation_only()
    set_private_discussions_only()

previously_allowed_private_discussions = ->
  $('form.group-settings').data().previousDiscussionPrivacyOptions != 'public_only'

previously_allowed_public_discussions = ->
  $('form.group-settings').data().previousDiscussionPrivacyOptions != 'private_only'

all_discussions_will_be_made_public = ->
  previously_allowed_private_discussions() and
  $('#group_discussion_privacy_options_public_only').is(':checked')

all_discussions_will_be_made_private = ->
  previously_allowed_public_discussions() and
  $('#group_discussion_privacy_options_private_only').is(':checked')

editing_group = ->
  $('.group-settings').data().isEditing

$ ->
  $('form.group-settings').on 'submit', ->
    if editing_group()
      if all_discussions_will_be_made_private()
        confirm $('form.group-settings').data().confirmAllDiscussionsWillBeMadePrivateMessage
      else if all_discussions_will_be_made_public()
        confirm $('form.group-settings').data().confirmAllDiscussionsWillBeMadePublicMessage

  $('form.group-settings').on 'change', ->
    update_group_form_state()

  # and when the dom loads
  update_group_form_state()

show_cover_photo_upload = ->
  $('.cover-photo-upload').show()

hide_cover_photo_upload = ->
  $('.cover-photo-upload').hide()

show_logo_upload = ->
  $('.logo-upload').show()

hide_logo_upload = ->
  $('.logo-upload').hide()

show_edit_description = ->
  $('.edit-description').show()
  $('.edit-icon-placeholder').hide()

hide_edit_description = ->
  $('.edit-description').hide()
  $('.edit-icon-placeholder').show()

$ ->

  if navigator.userAgent.match(/MSIE 8/) != null
    $('.group-heading').attr('style', $('.group-heading').attr('style').replace('url(/assets/cover-photo-gradient.png), ', ''))

  hide_cover_photo_upload()
  hide_logo_upload()
  hide_edit_description()
  $('.group-heading').hover(show_cover_photo_upload, hide_cover_photo_upload)
  $('.group-logo').hover(show_logo_upload, hide_logo_upload)
  $('.group-description').hover(show_edit_description, hide_edit_description)

  $(".js-submit-on-change").change (event) ->
    $(this).submit()

  $('.cover-photo-upload').tooltip
    placement: "bottom"
  $('.logo-upload').tooltip
    placement: "bottom"
  $('.edit-description').tooltip
    placement: "bottom"

  $('#group-form-tabs a').click (e) ->
    e.preventDefault();
    $(this).tab('show');
