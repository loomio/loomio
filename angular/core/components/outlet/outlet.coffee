angular.module('loomioApp').directive 'outlet', ($compile, AppConfig) ->
  scope: {model: '=?'}
  restrict: 'E'
  replace: true
  link: (scope, elem, attrs) ->

    shouldCompile = (model, experimental) ->
      return true if !experimental? or !model? or !model.group?
      model.group().parentOrSelf().enableExperiments

    # <my_directive discussion='model' />
    compileHtml = (model, component) ->
      modelDirective = "#{model.constructor.singular}='model'" if model
      $compile "<#{_.snakeCase(component)} #{modelDirective} />"

    _.map AppConfig.plugins.outlets[_.snakeCase(attrs.name)], (outlet) ->
      if shouldCompile(scope.model, outlet.experimental)
        elem.append compileHtml(scope.model, outlet.component)(scope)
