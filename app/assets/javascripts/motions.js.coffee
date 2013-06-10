window.Application ||= {}

### INITIALIZATION ###

$ ->
  hideOrShowOutcome()


### EVENTS ###

$ -> # Remove error class on closing inputs if changed
  $(".motion-close-at-date").change () ->
    hideDateErrorMessageFor($(this))

$ -> # Remove error class on closing inputs if changed
  $(".motion-close-at-time").change () ->
    hideDateErrorMessageFor($(this))

$ -> # Remove error class on closing inputs if changed
  $(".motion-close-at-time-zone").change () ->
    hideDateErrorMessageFor($(this))

$ -> # Disable links on usernames
  $('.activity-item-actor a, .member-name a').click (event) ->
    event.preventDefault()

$ -> # Toggle the list of members who  are yet to vote
  if $(".motion").length > 0
    $(".toggle-yet-to-vote").click((event) ->
      if $("#yet-to-vote").hasClass("hidden")
        $(this).text("[Hide users who have not yet decided]")
        $("#yet-to-vote").removeClass('hidden')
      else
        $(".toggle-yet-to-vote").text("[Show users who have not yet decided]")
        $("#yet-to-vote").addClass('hidden')
      event.preventDefault()
    )

$ -> # Check for error and submit vote
  $(".vote").click (event) ->
    unless $(".control-group").hasClass("error")
      $('#new_vote').submit()
    event.preventDefault()

$ -> # Show form for editing outcome
  $("#edit-outcome").click (event) ->
    $("#outcome-input").toggle()
    $("#outcome-display").toggle()
    event.preventDefault()


### FUNCTIONS ###

hideDateErrorMessageFor = (field) ->
  $(field).closest('.motion-closing-inputs').removeClass("error")
  row = $(field).closest('.motion-closing-inputs').find(".inline-help").hide()

Application.validateMotionCloseDate = (closeAtParent) ->
  if $(closeAtParent).is(":visible")
    timeNow = new Date()
    if parseCloseDateTimeZoneFields(closeAtParent) < timeNow
      $(closeAtParent).addClass("error")
      $(closeAtParent).find(".inline-help").show()
      return false
  true

parseCloseDateTimeZoneFields = (closeAtControlGroup) ->
  selectedDate = new Date()
  closeAtDate = closeAtControlGroup.find('.motion-close-at-date').val()
  closeAtTime = closeAtControlGroup.find('.motion-close-at-time').val()
  closeAtTimeZone = closeAtControlGroup.find('.motion-close-at-time-zone').val()
  listOfTimeZones = closeAtControlGroup.find('.motion-close-at-time-zone').text()

  timeZoneAsHourOffset = getTimeZoneOffsetFromList(listOfTimeZones, closeAtTimeZone)
  month = closeAtDate.substring(3,5)
  day = closeAtDate.substring(0,2)

  selectedDate.setUTCFullYear(parseInt(closeAtDate.substring(6,10), 10))
  selectedDate.setUTCMonth(parseInt(month, 10) - 1, parseInt(day, 10))
  selectedDate.setUTCHours(parseInt(closeAtTime, 10) - timeZoneAsHourOffset)
  selectedDate

getTimeZoneOffsetFromList = (list, timeZoneName) ->
  index = list.indexOf(timeZoneName)
  timeZoneAsHourOffset = parseInt(list.substring(index - 8, index - 5))

Application.displayGraph = (this_pie, graph_id, data)->
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
    shadow: 0

hideOrShowOutcome = () ->
  if $("#outcome-input").length > 0
    if $("#outcome-input").hasClass("hidden")
      $("#outcome-display").removeClass("hidden")
    else
      $("#outcome-display").addClass("hidden")
  else
      $("#outcome-display").removeClass("hidden")
