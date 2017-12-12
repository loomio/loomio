angular.module('loomioApp').factory '$exceptionHandler', ($log, AppConfig) ->
  unless AppConfig.errbit.key?
    return ->

  client = new airbrakeJs.Client
    projectId:  AppConfig.errbit.key
    projectKey: AppConfig.errbit.key
    reporter:   'xhr'
    host:       AppConfig.errbit.url

  client.addFilter( (notice) ->
    return null if notice.errors[0].type == ""
    notice
  )

  (exception, cause) ->
    $log.error(exception)
    client.notify
      error: exception,
      params:
        angular_cause: cause
