$ ->
  $('.enable-tooltip').tooltip
    placement: "bottom"

$ ->
  $('.tooltip-top').tooltip
    placement: 'top'

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

#adds bootstrap tooltip to makdown-settings-dropdown
$ ->
  $("#comment-markdown-dropdown").tooltip
    placement: "left",
    title: "Text formatting settings and info."

$ ->
  $("#discussion-markdown-dropdown").tooltip
    placement: "right",
    container: "body",
    title: "Text formatting settings and info."

$ ->
  $("#inbox-container").tooltip
    placement: "bottom",
    title: "Inbox"
    delay: 200
