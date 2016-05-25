angular.module('loomioApp').directive 'lmoHref', (TransitionService) ->
  restrict: 'A'
  scope:
    route: '@lmoHref'
    transition: '@lmoHrefTransition'
    transitionOpts: '@lmoHrefTransitionOptions'
  link: (scope, elem, attrs) ->
    scope.$watch 'route', ->
      elem.attr 'href', scope.route
    elem.bind 'click', ($event) ->
      if $event.ctrlKey or $event.metaKey
        $event.stopImmediatePropagation()
      else
        TransitionService.beginTransition(scope.transition, scope.transitionOpts)
