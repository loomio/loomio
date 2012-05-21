# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

current_tags = ""
current_tag_filter = "active"
$ ->
  $(".error-message").hide()
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
      datetime.setDate(datetime.getDate() + 7)
      hours = pad2(datetime.getHours())
      $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
      $("#input_date").datepicker("setDate", datetime)
      $("#date_hour").val(hours)
      $("#motion_close_date").val(datetime)
    else
      #** Edit Moition **
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


  #** presnece validations: use this function any where just assign the class .presence-required
  #   to the text field in question and the .check-presence to the submit button **
  $(".check-presence").click((event, ui) ->
    if $("#inputError").val() == ""
      $(".control-group").addClass("error")
      $(".error-message").show()
      false
  )

  $("#inputError").keyup(() ->
    $(".control-group").removeClass("error")
    $(".error-message").hide()
  )

  #** Reload hidden close_date field **
  $("#input_date").change((e) ->
    date = $(this).val()
    local_datetime = new Date()
    local_datetime.setYear(date.substring(6,10))
    local_datetime.setMonth((parseInt(date.substring(3,5)) - 1).toString())
    local_datetime.setDate(date.substring(0,2))
    local_datetime.setHours($("#date_hour").val())
    $("#motion_close_date").val(local_datetime)
  )
  $("#date_hour").change((e) ->
    date = $("#input_date").val()
    local_datetime = new Date()
    local_datetime.setYear(date.substring(6,10))
    local_datetime.setMonth((parseInt(date.substring(3,5)) - 1).toString())
    local_datetime.setDate(date.substring(0,2))
    local_datetime.setHours($(this).val())
    $("#motion_close_date").val(local_datetime)
  )

  #** character count for statement on discussion:show page **
  pluralize_characters = ((num) ->
    if(num == 1)
      return num + " character"
    else
      return num + " characters"
  )

  display_count = ((num) ->
    if(num >= 0)
      $(".character_counter").text(pluralize_characters(num) + " left")
      $(".control-group").removeClass("error")
    else
      num = num * (-1)
      $(".character_counter").text(pluralize_characters(num) + " too long")
      $(".control-group").addClass("error")
  )

  $(".limited").keyup(() ->
    chars = $(".limited").val().length
    left = 249 - chars
    display_count(left)
  )

  $(".vote").click((event) ->
    if $("control-group").hasClass("error")
      $('#new_vote').preventDefault()
    else
      $('#new_vote').submit()
  )

  #** character count for title on discussion:new page **

  $(".limit").keyup(() ->
    $(".error-message").hide()
    chars = $(".limit").val().length
    left = 150 - chars
    if(left >= 0)
      $(".character-counter").text(pluralize_characters(left) + " left")
      $(".control-group").removeClass("error")
    else
      left = left * (-1)
      $(".character-counter").text(pluralize_characters(left) + " too long")
      $(".control-group").addClass("error")
  )

  # NOTE (Jon): We should implement a better method for scoping javascript to specific pages
  # http://stackoverflow.com/questions/6167805/using-rails-3-1-where-do-you-put-your-page-specific-javascript-code
  if $("#motion").length > 0
    $("#description").html(linkify_html($("#description").html()))
    $(".comment-body").each(-> $(this).html(linkify_html($(this).html())))

