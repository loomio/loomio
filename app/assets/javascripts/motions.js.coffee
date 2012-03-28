# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("#motion-form").length > 0
    #** Edit Moition **
    datetime_string = $("#motion_close_date").val()
    date_string = datetime_string.substring(0,10)
    time_string = datetime_string.substring(11,13)
    datetime_format = new Date(date_string)
    $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#input_date").datepicker("setDate", datetime_format)
    $("#date_hour").val(time_string)
    #** New Motion **
    if $("#new-motion").length > 0
      now = new Date()
      $("#input_date").datepicker("setDate", now.getDate()+7)
      $("#date_hour").val(now.getHours())
      $("#motion_close_date").val($(".date-input").val() + " " + $("#date_hour").val())
  #** Reload hidden close_date field **
  $(".date-input").change((e) ->
    local_datetime = $(this).val() + " " + $("#date_hour").val()
    $("#motion_close_date").val(local_datetime)
  )
  $("#date_hour").change((e) ->
    local_datetime = $(".date-input").val() + " " + $(this).val()
    $("#motion_close_date").val(local_datetime)
  )
  #** expand motion row on dashboard and match colour for legend **
  $(".bordered").click((event, ui) ->
    expandableRow = $(this).children().last()
    expandableRow.toggle()
    if expandableRow.is(":visible")
      $(this).find(".toggle-button").html('-')
      if $(this).hasClass('closed')
        $(".jqplot-table-legend").addClass('closed')
        $(".jqplot-table-legend").removeClass('voting')
      else
        $(".jqplot-table-legend").addClass('voting')
        $(".jqplot-table-legend").removeClass('closed')
    else
      $(this).find(".toggle-button").html('+')
  )
  #** prevent expansion of motion **
  $(".no-toggle").click((event) ->
    event.stopPropagation()
  )
