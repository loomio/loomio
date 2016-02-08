angular.module('loomioApp').directive 'lmoHref', ->
  restrict: 'A'
  scope:
    route: '@lmoHref'
  link: (scope, elem, attrs) ->
    scope.$watch 'route', ->
      elem.attr 'href', scope.route
    elem.bind 'click', ($event) ->
      $event.stopImmediatePropagation() if $event.ctrlKey or $event.metaKey
