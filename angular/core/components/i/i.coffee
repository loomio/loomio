angular.module('loomioApp').directive 'i', ->
  restrict: 'E'
  link: (scope, elem, attrs) ->
    elem.attr 'aria-hidden', 'true'
