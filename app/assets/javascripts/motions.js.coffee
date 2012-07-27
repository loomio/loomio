# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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
  local_datetime.setYear(parseInt(date.substring(6,10)))
  month = date.substring(3,5)
  month = month[1] if month[0] == "0"
  day = date.substring(0,2)
  day = day[1] if day[0] == "0"
  local_datetime.setMonth(parseInt(month) - 1, parseInt(day))
  local_datetime.setHours(parseInt($("#date_hour").val()))
  $("#motion_close_date").val(local_datetime)


# The following methods are used to provide client side validation for
# - character count
# - presence required
# - date validation specific for motion-form

remove_date_error = ->
  $(".validate-motion-close-date").parent().removeClass("error")
  $(".date-error-message").hide()

$ ->
  $(".validate-presence").keyup(() ->
    $(".validate-presence").parent().removeClass("error")
    $(".presence-error-message").hide()
  )

$ ->
  $(".presence-error-message").hide()
  $(".date-error-message").hide()

  $(".run-validations").click((event, ui) ->
    $(".validate-presence").each((index, element) ->
      if $(element).val() == ""
        $(element).parent().addClass("error")
        $(".presence-error-message").show()
    )

    runCustomValidations()

    $(".control-group").each((index, group) ->
      if $(group).hasClass("error")
        event.preventDefault()
    )
  )

  runCustomValidations = ->
    motionCloseDateValidation()

  motionCloseDateValidation = ->
    if $("#motion-form").length > 0
      time_now = new Date()
      selected_date = new Date($("#motion_close_date").val())
      if selected_date <= time_now
        $(".validate-motion-close-date").parent().addClass("error")
        $(".date-error-message").show()

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
