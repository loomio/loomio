angular.module('loomioApp').factory 'SearchResultModel', (BaseModel) ->
  class SearchResultModel extends BaseModel
    @singular: 'search_result'
    @plural: 'search_results'

    initialize: (data) ->
      @discussion = data.discussion
      @proposals  = data.proposals
      @comments   = data.comments
      @query      = data.query
      @priority   = data.priority
