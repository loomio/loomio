LmoUrlService = require 'shared/services/lmo_url_service'

angular.module('loomioApp').directive 'lmoHrefFor', ->
  restrict: 'A'
  scope:
    model: '=lmoHrefFor'
    action: '@lmoHrefAction'
  link: (scope, elem, attrs) ->
    elem.attr 'href', LmoUrlService.route
      model: scope.model
      action: scope.action
    elem.bind 'click', ($event) ->
      attr_target = $event.target.attributes.target
      if $event.ctrlKey or $event.metaKey or (attr_target and attr_target.value == '_blank')
        $event.stopImmediatePropagation()
