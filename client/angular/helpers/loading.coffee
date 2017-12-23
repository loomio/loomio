module.exports =
  listenForLoading: ($scope) ->
    $scope.$on 'processing',     -> $scope.isDisabled = true
    $scope.$on 'doneProcessing', -> $scope.isDisabled = false

  applyLoadingFunction: ($scope, functionName) ->
    executing = "#{functionName}Executing"
    loadingFunction = $scope[functionName]
    $scope[functionName] = (args...) ->
      return if $scope[executing]
      $scope[executing] = true
      loadingFunction(args...).finally -> $scope[executing] = false
