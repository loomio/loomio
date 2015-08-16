angular.module('loomioApp').directive 'lmoHrefFor', (LmoUrlService, LmoRedirectService) ->
  restrict: 'A'
  scope:
    model: '=lmoHrefFor'
    action: '@lmoHrefAction'
  link: (scope, elem, attrs) ->
    elem.attr 'href', ''
    elem.bind 'click', ($event) ->
      LmoRedirectService.redirect $event, LmoUrlService.route
        model: scope.model
        action: scope.action
