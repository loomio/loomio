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

#*** add member form ***
$ ->
  # Only execute on group page
  if $("body.groups").length > 0
    $(".group-add-members").click((event) ->
      $(".group-add-members").hide()
      $("#invite-group-members").show()
      $("#user_email").focus()
      event.preventDefault()
    )
    $("#cancel-add-members").click((event) ->
      $(".group-add-members").removeClass('hidden')
      $("#invite-group-members").addClass('hidden')
      event.preventDefault()
    )

#*** ajax for discussions on group page ***

# closed proposals
$ ->
  if $("body.groups.show").length > 0
    $(".pie").each(->
      displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
    )

#*** open-close motions dropdown (group.show)***
#Switch between open & closed motions and load initial page
$ ->
  if $("body.groups.show").length > 0
    idStr = new Array
    idStr = $('#group-closed-motions').children().attr('class').split('_')
    $("#display-closed").click((event) ->
      $("#open-motions-list").addClass('hidden')
      $("#previous-motions-list").removeClass('hidden')
      $("#closed-motions-list").addClass('hidden')
      $("#closed-motions-loading").removeClass('hidden')
      $('#group-closed-motions').load("/groups/#{idStr[1]}/motions", ->
        $("#group-closed-motions").removeClass('hidden')
        $("#closed-motions-list").removeClass('hidden')
        $("#closed-motions-loading").addClass('hidden')
        $(".pie").each(->
          displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
        )
      )
      $("#tick-closed").removeClass('hidden')
      $("#tick-current").addClass('hidden')
      $("#proposal-phase").text("Closed proposals")
      event.preventDefault()
    )
    $("#display-current").click((event) ->
      $("#open-motions-list").removeClass('hidden')
      $("#previous-motions-list").addClass('hidden')
      $("#tick-current").removeClass('hiddden')
      $("#tick-closed").addClass('hidden')
      $("#proposal-phase").text("Current proposals")
      event.preventDefault()
    )

#pagination load on closed motions
$ ->
  if $("body.groups.show").length > 0
    $(document).on('click', '#group-closed-motions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        $("#closed-motions-list").addClass('hidden')
        $("#closed-motions-loading").removeClass('hidden')
        $('#group-closed-motions').load($(this).attr('href'), ->
          $("#closed-motion-list").removeClass('hidden')
          $("#closed-motions-loading").addClass('hidden')
          $(".pie").each(->
            displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
            )
          )
        e.preventDefault()
      )
# discussions
$ ->
  if $("body.groups.show").length > 0
    idStr = new Array
    idStr = $('#group-discussions').children().attr('class').split('_')
    $('#group-discussions').load("/groups/#{idStr[1]}/discussions", ->
      Application.convertUtcToRelativeTime()
      $("#group-discussions").removeClass('hidden')
      $("#discussions-loading").addClass('hidden')
    )
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
        )
        e.preventDefault()
    )

displayGraph = (this_pie, graph_id, data)->
  # Display vote graph
  @pie_graph_view = new Loomio.Views.Utils.GraphView
    el: this_pie
    id_string: graph_id
    legend: false
    data: data
    type: 'pie'
    tooltip_selector: '#tooltip'
    diameter: 25
    padding: 1
    gap: 1
    shadow: 0.75
