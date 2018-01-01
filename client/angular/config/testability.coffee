AppConfig = require 'shared/services/app_config.coffee'

if AppConfig.environment == 'test'
  testability = angular.getTestability(document.getQuerySelector('html'))
  _superWhenStable = testability.whenStable
  testability.whenStable = (callback) ->
    if AppConfig.pendingFetch
      AppConfig.pendingFetch.then -> _superWhenStable(callback)
    else
      _superWhenStable(callback)
