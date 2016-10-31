angular.module('loomioApp').factory 'AppConfig', ->
  configData = if window? and window.Loomio?
                 window.Loomio
               else
                 {currentUserData: {}, permittedParams: {}}

  configData.currentUserData.users = [] unless configData.currentUserData.users?
  configData.currentUserData.users.push configData.currentUserData.current_user
  configData.isLoomioDotOrg = configData.baseUrl == 'https://www.loomio.org/'
  configData.pluginConfig = (name) ->
    _.find configData.plugins.installed, (p) -> p.name == name
  configData
