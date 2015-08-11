angular.module('loomioApp').directive 'lmoHref', ($window, $router, LmoUrlService) ->
  restrict: 'A'
  scope:
    path: '@lmoHref'
    model: '=lmoHrefModel'
  link: (scope, elem, attrs) ->
    route = LmoUrlService.route(path: scope.path, model: scope.model, params: scope.params)
    elem.attr 'href', ''
    elem.bind 'click', ($event) ->
      if $event.metaKey
        $window.open route, '_blank'
      else
        $router.navigate route
