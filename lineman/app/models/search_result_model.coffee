angular.module('loomioApp').factory 'SearchResultModel', (BaseModel) ->
  class SearchResultModel extends BaseModel
    @singular: 'searchResult'
    @plural: 'searchResults'

    relationships: ->
      @belongsTo 'discussion'
      @belongsTo 'motion'
      @belongsTo 'comment'
