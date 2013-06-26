$ ->
  $('.enable-tooltip').tooltip
    placement: "bottom",

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
    $(".motion-popover-link").popover
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
  $("#comment-markdown-dropdown").tooltip
    placement: "left",
    title: "Text formatting settings and info."

$ ->
  $("#discussion-markdown-dropdown").tooltip
    placement: "right",
    container: "body",
    title: "Text formatting settings and info."
