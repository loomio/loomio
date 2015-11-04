angular.module('loomioApp').factory 'SearchResultModel', (BaseModel) ->
  class SearchResultModel extends BaseModel
    @singular: 'searchResult'
    @plural: 'searchResults'

    @apiEndPoint: 'search'
