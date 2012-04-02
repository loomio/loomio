$ ->
  $(".relativetime").each((index, element) ->
    time_utc = Date.parse($(element).text())
    time_local = new Date()
    time_local.setTime(time_utc)
    month = time_local.getMonth() + 1
    hour = time_local.getHours()
    if hour < 12
      hour_string = hour.toString() + "am"
    else if hour == 12
      hour_string = hour.toString() + "pm"
    else
      hour_string = (hour - 12).toString() + "pm"
    time_local_string = time_local.getDate() + "/" + month + "/" + time_local.getFullYear() + " at " + hour_string
    $(element).text(time_local_string)
  )
