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
    $(document).on('click', '#group-closed-motions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        $("#closed-motion-list").hide()
        $("#closed-motions-loading").show()
        $('#group-closed-motions').load($(this).attr('href'), ->
          $("#closed-motion-list").show()
          $("#closed-motions-loading").hide()
        )
        e.preventDefault()
    )
# discussions

$ ->
  if $("body.groups.show").length > 0
    idStr = new Array
    idStr = $('#group-discussions').children().attr('class').split('_')
    params = Application.getPageParam()
    $('#group-discussions').load("/groups/#{idStr[1]}/discussions" + params, ->
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
        if Application.html5.supported
          window.history.pushState("stateObj", "title_ignored", Application.getNextURL($(this).attr("href")))
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
