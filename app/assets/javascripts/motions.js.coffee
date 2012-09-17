DAY = 1000 * 60 * 60 * 24

$ ->
  if $("#motion-form").length > 0
    pad2 = ((number) ->
      if number < 10
        '0' + number
      else
        number.toString()
    )
    if $("#new-motion").length > 0
      #** New Motion **
      datetime = new Date()
      datetime.setDate(datetime.getDate() + 3)
      hours = pad2(datetime.getHours())
      $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
      $("#input_date").datepicker("setDate", datetime)
      $("#date_hour").val(hours)
      $("#motion_close_date").val(datetime)
      set_close_date()
    else
      #** Edit Motion **
      date = Application.timestampToDateObject($("#motion_close_date").val())
      year = date.getFullYear().toString().substring(2,4)
      month = pad2(date.getMonth() + 1)
      day = pad2(date.getDate())
      hour = pad2(date.getHours())
      date_string = "#{day}-#{month}-#{year}"
      $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
      $("#input_date").datepicker("setDate", date_string)
      $("#date_hour").val(hour)
      set_close_date()


# Reload hidden close_date field
$ ->
  $("#input_date").change((e) ->
    set_close_date()
  )

$ ->
  $("#date_hour").change((e) ->
    set_close_date()
  )

set_close_date = ->
  remove_date_error()
  date = $("#input_date").val()
  local_datetime = new Date()
  current_datetime = new Date()
  local_datetime.setYear(parseInt(date.substring(6,10), 10))
  month = date.substring(3,5)
  day = date.substring(0,2)
  local_datetime.setMonth(parseInt(month, 10) - 1, parseInt(day, 10))
  local_datetime.setHours(parseInt($("#date_hour").val(), 10))
  $("#motion_close_date").val(local_datetime)
  if (local_datetime >= current_datetime)
    $(".date-description").text("Closing date (" + days_between(local_datetime, current_datetime) + "):")
  else 
    $(".date-description").text("Closing date:")

remove_date_error = ->
  $(".validate-motion-close-date").parent().removeClass("error")
  $(".date-error-message").hide()

days_between = (local, current) ->
  days_passed = Math.round((local.getTime() - current.getTime()) / DAY)
  if (days_passed == 0)
    return "today"
  if (days_passed == 1)
    return days_passed + " day from now"
  return days_passed + " days from now"

# adds bootstrap popovers to vote buttons
$ ->
  $(".position").popover
    placement: "top"

#expand description text on proposal
$ ->
  if $(".motion").length > 0
    $(".see-more").click((event) ->
      $(".short-description").toggle()
      $(".long-description").toggle()
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
  
