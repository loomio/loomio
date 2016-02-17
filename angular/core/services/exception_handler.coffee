angular.module('loomioApp').factory '$exceptionHandler', (AppConfig) ->
  (exception, cause) ->
    if AppConfig.reportErrors
      Airbrake.push
        error:
          message : exception.toString()
          stack : exception.stack
        params:
          user_id: AppConfig.currentUserId

    console.error "LoomioApp exception:", exception, cause
