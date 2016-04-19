angular.module('loomioApp').factory 'AppConfig', ->
  configData = if window? and window.Loomio?
                 window.Loomio
               else
                 {seedRecords: {}, permittedParams: {}}

  configData.seedRecords.users = [] unless configData.seedRecords.users?
  configData.seedRecords.users.push configData.seedRecords.current_user
  configData.isLoomioDotOrg = configData.baseUrl == 'https://www.loomio.org/'
  configData
