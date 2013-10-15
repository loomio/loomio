#*** edit privacy settings from dropdown ***
$ ->
  if $("#privacy-settings-form").length > 0
    $(".privacy-item").click((event) ->
        $('#viewable_by').val($(this).children().attr('class'))
        $(".privacy-item").find('.icon-ok').removeClass('icon-ok')
        $(this).children().first().children().addClass('icon-ok')
        $("#privacy-settings-form").submit()
        event.preventDefault()
    )

$ ->
  $("#privacy").tooltip
    placement: "right"


# adds bootstrap popovers to group activity indicators
activate_discussions_tooltips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'


