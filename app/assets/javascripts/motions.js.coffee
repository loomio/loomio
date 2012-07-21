$ ->
  if $("#motion-form").length > 0
    #** pad out hour to two digits **
    pad2 = ((number) ->
      if number < 10
        '0' + number
      else
        number
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
    else
      #** Edit Motion **
      date = $("#motion_close_date").val()
      date_offset = new Date()
      offset = date_offset.getTimezoneOffset()/-60
      day = date.substring(8,10)
      month = date.substring(5, 7)
      year = date.substring(2,4)
      hour = (parseInt(date.substring(11,13)) + offset).toString()
      date_string = "#{day}-#{month}-#{year}"
      $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
      $("#input_date").datepicker("setDate", date_string)
      $("#date_hour").val(hour)

# Reload hidden close_date field
$ ->
  $("#input_date").change((e) ->
    remove_date_error()
    date = $(this).val()
    local_datetime = new Date()
    local_datetime.setYear(parseInt(date.substring(6,10)))
    local_datetime.setMonth((parseInt(date.substring(3,5)) - 1), parseInt(date.substring(0,2)))
    local_datetime.setHours(parseInt($("#date_hour").val()))
    $("#motion_close_date").val(local_datetime)
  )

$ ->
  $("#date_hour").change((e) ->
    remove_date_error()
    date = $("#input_date").val()
    local_datetime = new Date()
    local_datetime.setYear(parseInt(date.substring(6,10)))
    local_datetime.setMonth((parseInt(date.substring(3,5)) - 1), parseInt(date.substring(0,2)))
    local_datetime.setHours(parseInt($(this).val()))
    $("#motion_close_date").val(local_datetime)
  )

  # adds bootstrap popovers to vote buttons
$ ->
  $(".position").popover
    placement: "top"

# disable links on usernames
$ ->
  $('.comment-username a, .member-name a').click((event) ->
    event.preventDefault()
  )

#expand description text on proposal
$ ->
  if $(".motion").length > 0
    $(".see-more").click((event) ->
      $(".short-description").toggle()
      $(".long-description").toggle()
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
