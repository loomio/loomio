BaseModel = require 'shared/models/base_model'

angular.module('loomioApp').factory 'SearchResultModel', ->
  class SearchResultModel extends BaseModel
    @singular: 'searchResult'
    @plural: 'searchResults'

    @apiEndPoint: 'search'
