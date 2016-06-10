angular.module('loomioApp').directive 'outlet', ($compile, AppConfig) ->
  restrict: 'E'
  replace: true
  link: (scope, elem, attrs) ->
    _.map AppConfig.plugins.outlets[_.snakeCase(attrs.name)], (outlet) ->
      elem.append $compile("<#{_.snakeCase(outlet.component)} />")(scope)
