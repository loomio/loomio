$ -> # Disable links on usernames
  $('.activity-item-actor a, .member-name a').click((event) ->
    event.preventDefault()
  )

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
  $(".vote").click((event) ->
    if $(".control-group").hasClass("error")
      event.preventDefault()
    else
      $('#new_vote').submit()
      event.preventDefault()
  )


$ -> # Show form for editing outcome
  $("#edit-outcome").click((event) ->
    $("#outcome-input").toggle()
    $("#outcome-display").toggle()
    event.preventDefault()
  )

$ ->
  if $("#outcome-input").length > 0
    if $("#outcome-input").hasClass("hidden")
      $("#outcome-display").removeClass("hidden")
    else
      $("#outcome-display").addClass("hidden")
  else
      $("#outcome-display").removeClass("hidden")
