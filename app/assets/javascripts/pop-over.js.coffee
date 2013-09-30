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

$ ->
  $("#inbox-container").tooltip
    placement: "bottom",
    title: "Inbox"
    delay: 200
