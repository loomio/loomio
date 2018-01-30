angular.module('loomioApp').directive 'threadItemDirective', ['$compile', '$injector', ($compile, $injector) ->
  scope: {event: '='}
  link: ($scope, $element) ->
    kind = $scope.event.kind
    if $injector.has("#{_.camelCase(kind)}Directive")
      $compile("<#{kind} event='event' eventable='event.model()' />")($scope, (cloned, scope) -> $element.append(cloned))
]
