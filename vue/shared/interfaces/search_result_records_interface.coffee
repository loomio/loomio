BaseRecordsInterface = require 'shared/record_store/base_records_interface'
SearchResultModel    = require 'shared/models/search_result_model'

module.exports = class SearchResultRecordsInterface extends BaseRecordsInterface
  model: SearchResultModel
  apiEndPoint: 'search'

  fetchByFragment: (fragment) ->
    @fetch
      params:
        q: fragment
        per: 5
