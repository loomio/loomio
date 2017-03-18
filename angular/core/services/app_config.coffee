angular.module('loomioApp').factory 'AppConfig', ->
  configData = if window? and window.Loomio?
                 window.Loomio
               else
                 {bootData: {}, permittedParams: {}}

  configData.isLoomioDotOrg = configData.baseUrl == 'https://www.loomio.org/'
  configData.pluginConfig = (name) ->
    _.find configData.plugins.installed, (p) -> p.name == name
  configData
