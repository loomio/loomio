# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("#motion-form").length > 0
    # Display date in correct format
    # ...A bunch of bullshit that we have to write because jquery's
    # datepicker wants to be a pain.
    currentVal = $("#motion_close_date").val()
    dateVal = currentVal.substring(0,10)
    timeVal = currentVal.substring(11,13)
    dateVal = $.datepicker.parseDate("YY-mm-dd", dateVal)
    $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#input_date").datepicker("setDate", dateVal)
    $("#date_hour").val(timeVal)

    if $("#new-motion").length > 0
      now = new Date()
      timeVal = now.getHours()
      $("#input_date").datepicker("setDate", "now.getDate()+7")
      $("#date_hour").val(timeVal)
      $("#motion_close_date").val($(".date-input").val() + " " + $("#date_hour").val())

  $(".date-input").change((e) ->
    $("#motion_close_date").val($(this).val() + " " + $("#date_hour").val())
  )
  $("#date_hour").change((e) ->
    $("#motion_close_date").val($(".date-input").val() + " " + $(this).val())
  )

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

  $(".no-toggle").click((event) ->
    event.stopPropagation()
  )
