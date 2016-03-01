angular.module('loomioApp').directive 'outlet', ($compile) ->
  restrict: 'E'
  replace: true
  link: (scope, elem, attrs) ->
    _.map window.Loomio.plugins.outlets[_.snakeCase(attrs.name)], (outlet) ->
      elem.append $compile("<#{_.snakeCase(outlet.component)} />")(scope)
