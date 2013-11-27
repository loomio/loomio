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
