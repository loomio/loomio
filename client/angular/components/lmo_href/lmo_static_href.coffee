angular.module('loomioApp').directive 'lmoStaticHref', ($window) ->
  restrict: 'A'
  scope:
    route: '@lmoStaticHref'
  link: (scope, elem, attrs) ->
    scope.$watch 'route', ->
      elem.attr 'href', scope.route
    elem.bind 'click', ($event) ->
      if $event.ctrlKey or $event.metaKey
        $window.open(scope.route)
      else
        $window.location.href = scope.route
