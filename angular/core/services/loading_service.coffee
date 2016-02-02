angular.module('loomioApp').factory 'LoadingService', (Records) ->
  new class LoadingService
    applyLoadingFunction: (controller, functionName) ->
      executing = "#{functionName}Executing"
      loadingFunction = controller[functionName]
      controller[functionName] = (args...) ->
        return if controller[executing]
        controller[executing] = true
        loadingFunction(args...).finally -> controller[executing] = false
