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
      localDate = Application.timestampToDateObject(date)
      hours = localDate.getHours()
      mins = localDate.getMinutes()
      mins = "0#{mins}" if mins.toString().length == 1
      localDay = new Date(localDate.getFullYear(), localDate.getMonth(), localDate.getDate())
      todayDay = new Date(today.getFullYear(), today.getMonth(), today.getDate())
      if localDay.getTime() == todayDay.getTime()
        if hours < 12
          hours = 12 if hours == 0
          date_string = "#{hours}:#{mins} AM"
        else
          hours = 24 if hours == 12
          date_string = "#{hours-12}:#{mins} PM"
      else
        date_string = "#{localDate.getDate()} #{month[localDate.getMonth()]}"
      $(element).html(String(date_string))
      $(element).removeClass('utc-time')
      $(element).addClass('relative-time')
    )

Application.timestampToDateObject = (timestamp)->
  date = new Date()
  offset = date.getTimezoneOffset()/-60
  date.setYear(timestamp.substring(0,4))
  date.setMonth((parseInt(timestamp.substring(5,7), 10) - 1).toString(), timestamp.substring(8,10))
  date.setHours((parseInt(timestamp.substring(11,13), 10) + offset).toString())
  date.setMinutes(timestamp.substring(14,16))
  return date


$ ->
  $(".dismiss-system-notice").click( (event)->
    $.post($(this).attr("href"))
    $("#system-notice").remove()
    event.preventDefault()
  )

# The following methods are used to provide client side validation for
# - character count
# - presence required
# - date validation specific for motion-form

$ ->
  $(".validate-presence").keyup(() ->
    $(".validate-presence").parent().removeClass("error")
    $(".presence-error-message").hide()
  )

$ ->
  $(".presence-error-message").hide()
  $(".date-error-message").hide()

  $(".run-validations").click((event, ui) ->
    form = $(this).parents("form")
    form.find(".validate-presence").each((index, element) ->
      if $(element).is(":visible") && $(element).val() == ""
        parent = $(element).parent()
        parent.addClass("error")
        parent.find(".presence-error-message").show()
    )

    runCustomValidations(form)

    form.find(".control-group").each((index, group) ->
      if $(group).hasClass("error")
        event.preventDefault()
    )
  )

  runCustomValidations = (form)->
    motionCloseDateValidation(form)

  motionCloseDateValidation = (form)->
    if form.parents("#motion-form").length > 0
      time_now = new Date()
      selected_date = new Date($("#motion_close_date").val())
      if selected_date <= time_now
        $(".validate-motion-close-date").parent().addClass("error")
        $(".date-error-message").show()
        
          

$(document.body).keypress ->
  keyCode = event.which || event.keyCode
  keyChar = String.fromCharCode(keyCode)

  if check_page_focus_non_textarea()
    switch keyChar
      when "g" then show_group_dropdown()
  
check_page_focus_non_textarea = ->
  non_textarea = true
  if $('input').is(":focus")
    non_textarea = false
  if $('textarea').is(":focus")
    non_textarea = false
  return non_textarea

show_group_dropdown = ->
  $('#my_groups_header').click()

