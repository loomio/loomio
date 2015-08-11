angular.module('loomioApp').directive 'lmoHref', (LmoRedirectService) ->
  restrict: 'A'
  scope:
    route: '@lmoHref'
  link: (scope, elem, attrs) ->
    elem.attr 'href', ''
    elem.bind 'click', ($event) ->
      LmoRedirectService.redirect $event, scope.route
