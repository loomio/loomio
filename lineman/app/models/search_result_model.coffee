angular.module('loomioApp').factory 'SearchResultModel', (BaseModel) ->
  class SearchResultModel extends BaseModel
    @singular: 'searchResult'
    @plural: 'searchResults'

    #initialize: (data) ->
      #@discussion = data.discussion
      #@proposals  = data.proposals
      #@comments   = data.comments
      #@query      = data.query
      #@priority   = data.priority
