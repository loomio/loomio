window.Application ||= {}

### INITIALIZATION ###

$ ->
  if getParameterByName("focus_outcome_input")
    $("#outcome-input textarea").focus()


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

$ -> # Show form for editing outcome
  $("#edit-outcome").click (event) ->
    $("#outcome-form").show()
    $("#outcome-display").hide()
    event.preventDefault()


getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))
