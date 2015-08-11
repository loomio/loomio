angular.module('loomioApp').directive 'lmoHref', ($window, $router) ->
  restrict: 'A'
  link: (scope, elem, attrs) ->
    target = attrs['lmoHref']
    elem.bind 'click', ($event) ->
      if $event.metaKey
        $window.open attrs.lmoHref, '_blank'
      else
        $router.navigate attrs.lmoHref
