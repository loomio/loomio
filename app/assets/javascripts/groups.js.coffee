$ ->
  if $("body.groups.show").length > 0
    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )

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

#*** ajax for discussions on group page ***
$ ->
  if $("body.groups.show").length > 0 && $('#group-discussions').html() != null
    idStr = new Array
    idStr = $('#group-discussions').children().attr('class').split('_')
    # params = Application.getPageParam()
    params = ""
    $('#group-discussions').load("/groups/#{idStr[1]}/discussions" + params, ->
      Application.convertUtcToRelativeTime()
      $("#group-discussions").removeClass('hidden')
      $("#discussions-loading").addClass('hidden')
      activate_discussions_tooltips()
    )
    $("#all-discussions-loading").addClass('hidden')

$ ->
  if $("body.groups.show").length > 0
    $(document).on('click', '#group-discussions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        # if Application.html5.supported
        #   window.history.pushState("stateObj", "title_ignored", Application.getNextURL($(this).attr("href")))
        $("#discussion-list").addClass('hidden')
        $("#discussions-loading").removeClass('hidden')
        $('#group-discussions').load($(this).attr('href'), ->
          Application.convertUtcToRelativeTime()
          $("#discussion-list").removeClass('hidden')
          $("#discussions-loading").addClass('hidden')
          activate_discussions_tooltips()
        )
        e.preventDefault()
    )

$ ->
  $("#privacy").tooltip
    placement: "right"


# adds bootstrap popovers to group activity indicators
activate_discussions_tooltips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'


