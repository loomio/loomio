angular.module('loomioApp').directive 'lmoHrefFor', ($window, TransitionService, LmoUrlService) ->
  restrict: 'A'
  scope:
    model: '=lmoHrefFor'
    action: '@lmoHrefAction'
    transition: '@lmoHrefTransition'
    transitionOpts: '=lmoHrefTransitionOptions'
  link: (scope, elem, attrs) ->
    elem.attr 'href', LmoUrlService.route
      model: scope.model
      action: scope.action
    elem.bind 'click', ($event) ->
      attr_target = $event.target.attributes.target
      if $event.ctrlKey or $event.metaKey or (attr_target and attr_target.value == '_blank')
        $event.stopImmediatePropagation()
      else
        TransitionService.beginTransition(scope.transition, scope.transitionOpts)
