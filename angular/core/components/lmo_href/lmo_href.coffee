angular.module('loomioApp').directive 'lmoHref', ($window, $router) ->
  restrict: 'A'
  scope:
    route: '@lmoHref'
  link: (scope, elem, attrs) ->
    elem.bind 'click', ($event) ->
      if $event.ctrlKey or $event.metaKey
        $event.stopImmediatePropagation()
        $window.open(scope.route, '_blank')
      else
        $router.navigate(scope.route)
