angular.module('loomioApp').directive 'lmoHref', ($window, $router, LmoUrlService) ->
  restrict: 'A'
  scope:
    route: '@lmoHref'
    model: '=lmoHrefModel'
  link: (scope, elem, attrs) ->
    route = LmoUrlService.model(scope.model) or scope.route
    elem.attr 'href', ''
    elem.bind 'click', ($event) ->
      if $event.metaKey
        $window.open route, '_blank'
      else
        $router.navigate route
