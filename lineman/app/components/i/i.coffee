angular.module('loomioApp').directive 'i', ->
  restrict: 'I'
  link: (scope, elem, attrs) ->
    elem.attr 'aria-hidden', 'true'
