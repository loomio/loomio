import AppConfig from '@/shared/services/app_config.coffee'

export pluginConfigFor = (name) ->
  _.find(AppConfig.plugins.installed, (p) -> p.name == name).config
