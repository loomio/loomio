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
  local_datetime.setYear(parseInt(date.substring(6,10), 10))
  month = date.substring(3,5)
  day = date.substring(0,2)
  local_datetime.setMonth(parseInt(month, 10) - 1, parseInt(day, 10))
  local_datetime.setHours(parseInt($("#date_hour").val(), 10))
  $("#motion_close_date").val(local_datetime)

remove_date_error = ->
  $(".validate-motion-close-date").parent().removeClass("error")
  $(".date-error-message").hide()


# character count for statement on discussion:show page
pluralize_characters = (num) ->
  if(num == 1)
    return num + " character"
  else
    return num + " characters"

# display charcaters left
display_count = (num, object) ->
  if(num >= 0)
    $(".character-counter").text(pluralize_characters(num) + " left")
    object.parent().removeClass("error")
  else
    num = num * (-1)
    $(".character-counter").text(pluralize_characters(num) + " too long")
    object.parent().addClass("error")

# character count for 250 characters max
$ ->
  $(".limit-250").keyup(() ->
    $(".error-message").hide()
    chars = $(".limit-250").val().length
    left = 250 - chars
    display_count(left, $(".limit-250"))
  )

 #character count for 150 characters max
$ ->
  $(".limit-150").keyup(() ->
    $(".error-message").hide()
    chars = $(".limit-150").val().length
    left = 150 - chars
    display_count(left, $(".limit-150"))
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
