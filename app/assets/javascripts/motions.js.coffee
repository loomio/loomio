window.Application ||= {}

$ -> # Show form for editing outcome
  if $('.motion-outcome').text().length > 0
    hideMotionOutcomeForm()
  else
    showMotionOutcomeForm()

  $('#edit-outcome').click (e) ->
    e.preventDefault()
    showMotionOutcomeForm()
    hideMotionOutcome()


hideMotionOutcomeForm = ->
  $('#outcome-form').addClass('hidden')

showMotionOutcomeForm = ->
  $('#outcome-form').removeClass('hidden')

hideMotionOutcome = ->
  $('#outcome-display').addClass('hidden')

$ ->
  if getParameterByName("focus_outcome_input")
    $("#outcome-input textarea").focus()

$ -> # Disable links on usernames
  $('.activity-item-actor a, .member-name a').click (event) ->
    event.preventDefault()

$ -> # Toggle the list of members who  are yet to vote
  if $(".motion").length > 0
    $(".toggle-yet-to-vote").click (event) ->
      if $("#yet-to-vote").hasClass("hidden")
        $(this).text("[Hide users who have not yet decided]")
        $("#yet-to-vote").removeClass('hidden')
      else
        $(".toggle-yet-to-vote").text("[Show users who have not yet decided]")
        $("#yet-to-vote").addClass('hidden')
      event.preventDefault()

getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))
