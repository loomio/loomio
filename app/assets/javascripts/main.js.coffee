window.Application ||= {}

Application.convertUtcToRelativeTime = ->
  if $(".utc-time").length > 0
    today = new Date()
    month = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    date_offset = new Date()
    offset = date_offset.getTimezoneOffset()/-60
    $(".utc-time").each((index, element)->
      date = $(element).html()
      local_datetime = new Date()
      local_datetime.setYear(date.substring(0,4))
      local_datetime.setMonth((parseInt(date.substring(5,7)) - 1).toString(), date.substring(8,10))
      local_datetime.setHours((parseInt(date.substring(11,13)) + offset).toString())
      local_datetime.setMinutes(date.substring(14,16))
      hours = local_datetime.getHours()
      mins = local_datetime.getMinutes()
      mins = "0#{mins}" if mins.toString().length == 1
      if local_datetime.getDate() == today.getDate()
        if hours < 12
          hours = 12 if hours == 0
          date_string = "#{hours}:#{mins} AM"
        else
          hours = 24 if hours == 12
          date_string = "#{hours-12}:#{mins} PM"
      else
        date_string = "#{local_datetime.getDate()} #{month[local_datetime.getMonth()]}"
      $(element).html(String(date_string))
      $(element).removeClass('utc-time')
      $(element).addClass('relative-time')
    )

$ ->
  $(".dismiss-system-notice").click( (event)->
    $.post($(this).attr("href"))
    $("#system-notice").remove()
    event.preventDefault()
  )

#*** open-close motions dropdown (dashborad + groups pages)***
$ ->
  $("#display-closed").click((event) ->
    $("#open-motions-list").hide()
    $("#closed-motions-list").show()
    $("#tick-closed").show()
    $("#tick-current").hide()
    $("#proposal-phase").text("Closed proposals")
    event.preventDefault()
  )
  $("#display-current").click((event) ->
    $("#open-motions-list").show()
    $("#closed-motions-list").hide()
    $("#tick-current").show()
    $("#tick-closed").hide()
    $("#proposal-phase").text("Current proposals")
    event.preventDefault()
  )

# The following methods are used to provide client side validation for
# - character count
# - presence required
# - date validation specific for motion-form
remove_date_error = () ->
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
