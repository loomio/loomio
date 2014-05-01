$ ->
  $("#privacy").tooltip
    placement: "right"

$ ->
  if $("body.groups.add_subgroup").length > 0 || $("body.groups.edit").length > 0
    toggle_viewable_by_parent_members_ability()
    $('.group_privacy input[type="radio"]').click ->
      toggle_viewable_by_parent_members_ability()

# adds bootstrap popovers to group activity indicators
activate_discussions_tooltips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'


toggle_viewable_by_parent_members_ability = ->
  if $('input[name="group[privacy]"]:checked').val() == 'public'
    $('.group_viewable_by_parent_members label').addClass('disabled')
    $('input#group_viewable_by_parent_members').attr('disabled', true)
  else
    $('.group_viewable_by_parent_members label').removeClass('disabled')
    $('input#group_viewable_by_parent_members').removeAttr('disabled')

$ ->
  $(".group_privacy").on 'change', (e) ->
    value = $(e.target).val()
    $("#current-privacy-setting").val(value)

$ ->
  $("form.edit_group").on "submit", (e) ->
    current_privacy = $("form.edit_group").data('current-privacy')
    selected_privacy = $('input[name="group[privacy]"]:checked').val()
    if (current_privacy == "public" || current_privacy == "private") && (selected_privacy == "hidden")
      confirm("By changing your group privacy to hidden, all of your discussions will be made private.")


