angular.module('loomioApp').directive 'lmoHrefFor', (LmoUrlService) ->
  restrict: 'A'
  scope:
    model: '=lmoHrefFor'
    action: '@lmoHrefAction'
  link: (scope, elem, attrs) ->
    elem.attr 'href', LmoUrlService.route
      model: scope.model
      action: scope.action
    elem.bind 'click', ($event) ->
      $event.stopImmediatePropagation() if $event.ctrlKey or $event.metaKey
