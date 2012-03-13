# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("#motion-form").length > 0
    # A bunch of bullshit that we have to write because jquery's 
    # datepicker wants to be a pain.
    currentVal = $("#motion_close_date").val()
    currentVal = $.datepicker.parseDate("yy-mm-dd", currentVal)
    $("#motion_close_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#motion_close_date").datepicker("setDate", currentVal)
    if $("#motion_close_date").val() == ""
      $("#motion_close_date").datepicker("setDate", new Date())
