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

#adds bootstrap popovers to preview pies
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $(".selector-pie-link").popover
      html: true,
      placement: "right",
      trigger: "manual"

#adds bootstrap tooltip to preview pies
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $(".pie").tooltip
      placement: "top",
      title: "Click to see more."

#adds bootstrap tooltip to makdown-settings-dropdown
$ ->
  $("#markdown-dropdown").tooltip
    placement: "top",
    title: "Text formatting settings and info."
