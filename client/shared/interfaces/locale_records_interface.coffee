AppConfig            = require 'shared/services/app_config'
BaseRecordsInterface = require 'shared/record_store/base_records_interface'

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
            # some, not all (why?), moment.js locale files have return
            # statements on the end of them, but they are not wrapped in
            # functions which raises an error.
            # So we stip the return statement with this regex.
            eval data.replace(/return.+\n\n$/, "\n")
        else
          throw response
