angular.module('loomioApp').directive 'outlet', ($compile, AppConfig) ->
  scope: {model: '=?'}
  restrict: 'E'
  replace: true
  link: (scope, elem, attrs) ->

    shouldCompile = (outlet) ->
      # model is not associated with a group
      return true if !scope.model? or !scope.model.group?

      # outlet is servicing a standard plugin
      return true if !(outlet.experimental? or outlet.plans?)

      group = scope.model.group().parentOrSelf()
      # outlet is servicing an experimental plugin for an experiments enabled group
      return true if outlet.experimental? and group.enableExperiments

      # outlet is a premium plugin servicing a premium group
      return true if _.include(outlet.plans, group.subscriptionPlan)

      # otherwise don't show the plugin
      return false

    # <my_directive discussion='model' />
    compileHtml = (model, component) ->
      modelDirective = "#{model.constructor.singular}='model'" if model
      $compile "<#{_.snakeCase(component)} #{modelDirective} />"

    _.map AppConfig.plugins.outlets[_.snakeCase(attrs.name)], (outlet) ->
      elem.append(compileHtml(scope.model, outlet.component)(scope)) if shouldCompile(outlet)
