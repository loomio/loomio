AppConfig            = require 'shared/services/app_config.coffee'
BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'

module.exports = class LocaleRecordsInterface extends BaseRecordsInterface
  model:
    plural:     'moment_locales'

  constructor: (recordStore) ->
    super(recordStore)
    @remote.apiPrefix = AppConfig.assetRoot

  onInterfaceAdded: ->
    @setRemoteCallbacks
      onSuccess: (response) ->
        if response.ok
          response.text().then (data) ->
            eval(data)
        else
          throw response
