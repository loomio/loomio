$ ->
  # Only execute on group page
  if $("body.groups.show").length > 0
    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )

#*** add member form ***
$ ->
  # Only execute on group page
  if $("body.groups.show").length > 0
    $("#group-add-members").click((event) ->
      $("#group-add-members").addClass('hidden')
      $("#invite-group-members").removeClass('hidden')
      $("#user_email").focus()
      event.preventDefault()
    )
    $("#cancel-add-members").click((event) ->
      $("#group-add-members").removeClass('hidden')
      $("#invite-group-members").addClass('hidden')
      event.preventDefault()
    )

#*** ajax for discussions on group page ***
$ ->
  if $("body.groups.show").length > 0 && $('#group-discussions').html() != null
    idStr = new Array
    idStr = $('#group-discussions').children().attr('class').split('_')
    $('#group-discussions').load("/groups/#{idStr[1]}/discussions", ->
      Application.convertUtcToRelativeTime()
      $("#group-discussions").removeClass('hidden')
      $("#discussions-loading").addClass('hidden')
      activate_tool_tips()
    )
    $("#all-discussions-loading").addClass('hidden')
$ ->
  if $("body.groups.show").length > 0
    $(document).on('click', '#group-discussions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        $("#discussion-list").addClass('hidden')
        $("#discussions-loading").removeClass('hidden')
        $('#group-discussions').load($(this).attr('href'), ->
          Application.convertUtcToRelativeTime()
          $("#discussion-list").removeClass('hidden')
          $("#discussions-loading").addClass('hidden')
          activate_tool_tips()
        )
        e.preventDefault()
    )

# adds bootstrap popovers to group activity indicators
activate_tool_tips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'

