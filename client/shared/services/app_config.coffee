moment  = require 'moment'

module.exports = do ->
  configData = if window? and window.Loomio?
                 window.Loomio
               else
                 {bootData: {}, permittedParams: {}}

  configData.pluginConfig = (name) ->
    _.find configData.plugins.installed, (p) -> p.name == name

  configData.providerFor = (name) ->
    _.find configData.identityProviders, (provider) -> provider.name == name

  configData.timeZone = moment.tz.guess() if moment.tz
  configData
