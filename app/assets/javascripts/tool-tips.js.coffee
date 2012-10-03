# adds bootstrap popovers to group activity indicators
$ ->
  $(".group-activity").tooltip
    placement: "top"
    title: 'There have been new comments since you last visited this group.'

# adds bootstrap popovers to vote buttons
$ ->
  $(".position").popover
    placement: "top"

# adds bootstrap popovers to group privacy indicators
$ ->
  $("#privacy").tooltip
    placement: "top"

