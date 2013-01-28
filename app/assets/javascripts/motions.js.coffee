DAY = 1000 * 60 * 60 * 24

#** New Motion **
$ ->
  if $("#motion-form").length > 0
    local_datetime = $('#local_time').val()
    yy = local_datetime.substring(0,4)
    mm = local_datetime.substring(5,7)
    dd = local_datetime.substring(8,10)
    hh = local_datetime.substring(11,13).toString()
    $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#input_date").datepicker("setDate", dd + "-" + mm + "-" + yy)
    $("#date_hour").val(hh)
    setCloseDate()

#** Edit Motion **
$ ->
  $("#edit-close-date").on('shown', (e) ->
    local_datetime = $('#local_time').val()
    yy = local_datetime.substring(0,4)
    mm = local_datetime.substring(5,7)
    dd = local_datetime.substring(8,10)
    hh = local_datetime.substring(11,13).toString()
    date_string = "#{dd}-#{mm}-#{yy}"
    $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#input_date").datepicker("setDate", date_string)
    $("#date_hour").val(hh)
    setCloseDate()
  )

# Reload hidden close_date field
$ ->
  $("#input_date").change((e) ->
    setCloseDate()
  )

$ ->
  $("#date_hour").change((e) ->
    setCloseDate()
  )

# convert string formats 'dd-mm-yyyy', 'hh', 'OO' to datetime
buildUtcDatetime = (dateStr, dateHrs, offset) ->
  datetime = new Date()
  datetime.setYear(parseInt(dateStr.substring(6,10), 10))
  month = dateStr.substring(3,5)
  day = dateStr.substring(0,2)
  datetime.setMonth(parseInt(month, 10) - 1, parseInt(day, 10))
  datetime.setUTCHours((parseInt(dateHrs, 10) - offset))
  return datetime

setCloseDate = ->
  removeDateError()
  currentDatetime = new Date()
  utcDatetime = new Date()
  offset = $("#local_time").val().substring(21,23)
  utcDatetime = buildUtcDatetime($("#input_date").val(),
                                      $("#date_hour").val(), offset)
  $("#motion_close_date").val(utcDatetime)
  if (utcDatetime >= currentDatetime)
    $(".date-description").text("Closing date (" + days_between(utcDatetime, currentDatetime) + "):")
  else
    $(".date-description").text("Closing date:")

removeDateError = ->
  $(".validate-motion-close-date").parent().removeClass("error")
  $(".date-error-message").hide()

days_between = (local, current) ->
  days_passed = Math.round((local.getTime() - current.getTime()) / DAY)
  if (days_passed == 0)
    return "today"
  if (days_passed == 1)
    return days_passed + " day from now"
  return days_passed + " days from now"

# disable links on usernames
$ ->
  $('.activity-item-actor a, .member-name a').click((event) ->
    event.preventDefault()
  )

$ ->
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

# check for error and submit vote
$ ->
  $(".vote").click((event) ->
    if $(".control-group").hasClass("error")
      event.preventDefault()
    else
      $('#new_vote').submit()
      event.preventDefault()
  )

# show form for editing outcome
$ ->
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



