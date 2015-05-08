# adds bootstrap popovers to group activity indicators
$ ->
  $(".group-activity").tooltip
    placement: "top",
    title: 'There have been new comments since you last visited the group.'

# adds bootstrap popovers to vote buttons
$ ->
  $(".position").popover
    placement: "top",
    trigger: "hover"

#adds bootstrap tooltips to makdown-settings-dropdown buttons
$ ->
  $("#comment-markdown-dropdown").tooltip
    placement: 'right',
    title: 'Text formatting settings and info.'

$ ->
  $("#discussion-markdown-dropdown").tooltip
    placement: "right",
    container: "body",
    title: "Text formatting settings and info."

#adds bootstrap tooltip to attachment buttons
$ ->
  $('#add-attachment-icon').tooltip
    placement: 'bottom',
    title: 'Attach files'

$ ->
  $("#inbox-container").tooltip
    placement: "bottom",
    title: "Inbox"

$ ->
  $('.js-tooltip').tooltip
    placement: "bottom"

$ ->
  $('.js-tooltip-left').tooltip
    placement: "left"

$ ->
  $('.js-tooltip-top').tooltip
    placement: "top"
