AppConfig = require 'shared/services/app_config.coffee'

module.exports =
  pluginConfigFor: (name) ->
    _.find(AppConfig.plugins.installed, (p) -> p.name == name).config
