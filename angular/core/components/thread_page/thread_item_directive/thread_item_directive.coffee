angular.module('loomioApp').directive 'threadItemDirective', ($compile, $injector) ->
  scope: {event: '='}
  link: ($scope, element) ->
    kind = $scope.event.kind
    if $injector.has("#{_.camelCase(kind)}Directive")
      element.append $compile("<#{kind} eventable='event.model()' />")($scope)
