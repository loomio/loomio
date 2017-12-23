BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
SearchResultModel    = require 'shared/models/search_result_model.coffee'

module.exports = class SearchResultRecordsInterface extends BaseRecordsInterface
  model: SearchResultModel

  fetchByFragment: (fragment) ->
    @fetch
    params:
      q: fragment
      per: 5
