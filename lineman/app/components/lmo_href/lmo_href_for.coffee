angular.module('loomioApp').directive 'lmoHrefFor', (LmoUrlService, LmoRedirectService) ->
  restrict: 'A'
  scope:
    route: '=lmoHrefFor'
  link: (scope, elem, attrs) ->
    elem.attr 'href', ''
    elem.bind 'click', ($event) ->
      route = if scope.route.model?
        scope.route
      else
        { model: scope.route }
      LmoRedirectService.redirect $event, LmoUrlService.route(route)
