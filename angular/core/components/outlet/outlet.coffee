angular.module('loomioApp').directive 'outlet', ($compile, AppConfig) ->
  scope: {model: '=?'}
  restrict: 'E'
  replace: true
  link: (scope, elem, attrs) ->

    shouldCompile = (outlet, model) ->
      return true if !outlet.experimental or !model? or !model.group?
      model.group().parentOrSelf().enableExperiments

    # <my_directive discussion='model' />
    compileHtml = (component, model) ->
      modelDirective = "#{model.constructor.singular}='model'" if model
      $compile "<#{_.snakeCase(component)} #{modelDirective} />"

    _.map AppConfig.plugins.outlets[_.snakeCase(attrs.name)], (outlet) ->
      if shouldCompile(outlet, scope.model)
        elem.append compileHtml(outlet.component, scope.model)(scope)
