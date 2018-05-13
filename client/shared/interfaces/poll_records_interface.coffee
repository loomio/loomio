BaseRecordsInterface = require 'shared/record_store/base_records_interface'
PollModel            = require 'shared/models/poll_model'

module.exports = class PollRecordsInterface extends BaseRecordsInterface
  model: PollModel

  fetchFor: (model, options = {}) ->
    options["#{model.constructor.singular}_key"] = model.key
    @search options

  search: (options = {}) ->
    @fetch
      path: 'search'
      params: options

  searchResultsCount: (options = {}) ->
    @fetch
      path: 'search_results_count'
      params: options

  fetchByGroup: (groupKey, options = {}) ->
    @search _.merge(options, {group_key: groupKey})
