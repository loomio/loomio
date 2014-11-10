angular.module('loomioApp').directive 'focusOn', ($timeout) ->
  (scope, element, attrs) ->
    console.log "focusOn: ", attrs.focusOn
    scope.$on attrs.focusOn, (e) ->
      $timeout ->
        element[0].focus()
      , 50
