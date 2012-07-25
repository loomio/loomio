$ ->
  # Only execute on group page
  if $("body.groups").length > 0
    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )
  # Add a group description
  $ ->
    if $("body.groups").length > 0
      $("#add-description").click((event) ->
        $("#description-placeholder").toggle()
        $("#add-group-description").toggle()
        event.preventDefault()
      )
      $("#edit-description").click((event) ->
        $("#group-description").toggle()
        $("#add-group-description").toggle()
        event.preventDefault()
      )
      $("#cancel-add-description").click((event) ->
        $("#add-group-description").toggle()
        if $("#group-description").text().match(/\S/)
          $("#group-description").toggle()
        else
          $("#description-placeholder").toggle()
        event.preventDefault()
      )

#*** tick on proposal dropdown ***
$ ->
  $("#display-closed").click((event) ->
    $("#open").hide()
    $("#closed").show()
    $("#tick-closed").show()
    $("#tick-current").hide()
    $("#proposal-phase").text("Closed proposals")
    event.preventDefault()
  )
  $("#display-current").click((event) ->
    $("#open").show()
    $("#closed").hide()
    $("#tick-current").show()
    $("#tick-closed").hide()
    $("#proposal-phase").text("Current proposals")
    event.preventDefault()
  )

#*** add member form ***
$ ->
  # Only execute on group page
  if $("body.groups").length > 0
    $(".group-add-members").click((event) ->
      $(".group-add-members").hide()
      $("#invite-group-members").show()
      event.preventDefault()
    )
    $("#cancel-add-members").click((event) ->
      $(".group-add-members").show()
      $("#invite-group-members").hide()
      event.preventDefault()
    )

#*** ajax for discussions on group page ***

# closed proposals
$ ->
  if $("body.groups").length > 0
    idStr = new Array
    idStr = $('#group-closed-motions').children().attr('class').split('_')
    $('#group-closed-motions').load("/groups/#{idStr[1]}/motions", ->
      $("#group-closed-motions").show()
      $("#closed-motions-loading").hide()
    )
$ ->
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
  if $("body.groups").length > 0
    idStr = new Array
    idStr = $('#group-discussions').children().attr('class').split('_')
    $('#group-discussions').load("/groups/#{idStr[1]}/discussions", ->
      Application.convertUtcToRelativeTime()
      $("#group-discussions").show()
      $("#discussions-loading").hide()
    )
$ ->
  $(document).on('click', '#group-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      $("#discussion-list").hide()
      $("#discussions-loading").show()
      $('#group-discussions').load($(this).attr('href'), ->
        Application.convertUtcToRelativeTime()
        $("#discussion-list").show()
        $("#discussions-loading").hide()
      )
      e.preventDefault()
  )
