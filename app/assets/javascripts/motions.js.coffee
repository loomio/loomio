# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("#motion-form").length > 0
    # Display date in correct format
    # ...A bunch of bullshit that we have to write because jquery's
    # datepicker wants to be a pain.
    currentVal = $("#motion_close_date").val()
    currentVal = $.datepicker.parseDate("yy-mm-dd", currentVal)
    $("#motion_close_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#motion_close_date").datepicker("setDate", currentVal)

    if $("#new-motion").length > 0
      now = new Date()
      $("#motion_close_date").datepicker("setDate", "now.getDate()+7")

  $(".bordered").click((event, ui) ->
    expandableRow = $(this).children().last()
    expandableRow.toggle()
    if expandableRow.is(":visible")
      $(this).find(".toggle-button").html('-')
    else
      $(this).find(".toggle-button").html('+')
  )

  $(".no-toggle").click((event) ->
    event.stopPropagation()
  )
