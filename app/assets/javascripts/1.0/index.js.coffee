#= require jquery
#= require underscore
#= require moment
#= require bootstrap

$ ->
  $('.js-add-comment-big').hide()
  $('.js-add-comment-small input').on 'focus', ->
    $('.js-add-comment-small').hide()
    $('.js-add-comment-big').show()
