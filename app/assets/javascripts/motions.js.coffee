# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("#motion-form").length > 0
    #** Edit Moition **
    date = new Date($("#motion_close_date").val())
    date_string = "#{date.getDate()}-#{date.getMonth() + 1}-#{date.getFullYear()}"
    hours = date.getHours()
    datetime_format = new Date(date_string)
    $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#input_date").datepicker("setDate", date_string)
    $("#date_hour").val(hours)

    #** New Motion **
    if $("#new-motion").length > 0
      datetime = new Date()
      datetime.setDate(datetime.getDate() + 7)
      hours = datetime.getHours()
      $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
      $("#input_date").datepicker("setDate", datetime)
      $("#date_hour").val(hours)
      $("#motion_close_date").val(datetime)

  #** Reload hidden close_date field **
  $("#input_date").change((e) ->
    date = $(this).val()
    day = date.substring(0,2)
    month = (parseInt(date.substring(3,5)) - 1).toString()
    year = date.substring(6,10)
    hour = $("#date_hour").val()
    local_datetime = new Date(year, month, day, hour)
    $("#motion_close_date").val(local_datetime)
  )
  $("#date_hour").change((e) ->
    date = $("#input_date").val()
    day = date.substring(0,2)
    month = (parseInt(date.substring(3,5)) - 1).toString()
    year = date.substring(6,10)
    hour = $(this).val()
    local_datetime = new Date(year, month, day, hour)
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
