# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

#focus decision statement when making vote
$ ->
  # Only execute on group page
  $('#vote-statement').bind 'shown', (event) =>
    $('#vote-statement .statement').focus()
