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
    $("#privacy-everyone").click((event) ->
        $('#viewable_by').val("everyone")
        $("#privacy-everyone").find('.icon-ok').removeClass('hidden')
        $("#privacy-members").find('.icon-ok').addClass('hidden')
        $("#privacy-parent").find('.icon-ok').addClass('hidden')
        $("#privacy-settings-form").submit()
        event.preventDefault()
    )
    $("#privacy-members").click((event) ->
        $('#viewable_by').val("members")
        $("#privacy-everyone").find('.icon-ok').addClass('hidden')
        $("#privacy-members").find('.icon-ok').removeClass('hidden')
        $("#privacy-parent").find('.icon-ok').addClass('hidden')
        $("#privacy-settings-form").submit()
        event.preventDefault()
    )
    $("#privacy-parent").click((event) ->
        $('#viewable_by').val("parent_group_members")
        $("#privacy-everyone").find('.icon-ok').addClass('hidden')
        $("#privacy-members").find('.icon-ok').addClass('hidden')
        $("#privacy-parent").find('.icon-ok').removeClass('hidden')
        $("#privacy-settings-form").submit()
        event.preventDefault()
    )

#*** add member form ***
$ ->
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
        $("#discussions-with-motions").hide()
        $('#group-discussions').load($(this).attr('href'), ->
          Application.convertUtcToRelativeTime()
          if document.URL.indexOf("page") == -1
            $("#discussions-with-motions").show()
          $("#discussion-list").removeClass('hidden')
          $("#discussions-loading").addClass('hidden')
          activate_discussions_tooltips()
        )
        e.preventDefault()
    )

# adds bootstrap popovers to group activity indicators
activate_discussions_tooltips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'

$ ->
  $("#privacy").tooltip
    placement: "top"
