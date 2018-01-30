BaseModel = require 'shared/record_store/base_model.coffee'

module.exports = class SearchResultModel extends BaseModel
  @singular: 'searchResult'
  @plural: 'searchResults'

  @apiEndPoint: 'search'
