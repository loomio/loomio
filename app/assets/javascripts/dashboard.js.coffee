#*** ajax for discussions ***

#closed proposals
# $ ->
#   if $("body.dashboard.show").length > 0
#     $(".pie").each(->
#       displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
#     )

#*** open-close motions dropdown (dashboard)***
#Switch between open & closed motions and load initial page
$ ->
  $("#display-closed").click((event) ->
    $("#open-motions-list").addClass('hidden')
    $("#previous-motions-list").removeClass('hidden')
    $("#closed-motions-list").addClass('hidden')
    $("#closed-motions-loading").removeClass('hidden')
    $("#user-closed-motions").load("/motions", ->
      $("#user-closed-motions").removeClass('hidden')
      $("#closed-motions-list").removeClass('hidden')
      $("#closed-motions-loading").addClass('hidden')
      # $(".pie").each(->
      #   displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
      # )
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
  $(document).on('click', '#user-closed-motions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      $("#closed-motions-list").addClass('hidden')
      $("#closed-motions-loading").removeClass('hidden')
      $('#user-closed-motions').load($(this).attr('href'), ->
        $("#closed-motions-list").removeClass('hidden')
        $("#closed-motions-loading").addClass('hidden')
        # $(".pie").each(->
        #   displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
        #   )
        )
      e.preventDefault()
    )

# discussions
$ ->
  $('#user-discussions').load("/discussions", ->
    Application.convertUtcToRelativeTime()
    $("#user-discussions").removeClass('hidden')
    $("#discussions-loading").addClass('hidden')
  )
$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      $("#discussion-list").addClass('hidden')
      $("#discussions-loading").removeClass('hidden')
      $('#user-discussions').load($(this).attr('href'), ->
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


