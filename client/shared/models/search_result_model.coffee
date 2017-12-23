BaseModel = require 'shared/models/base_model'

module.exports = class SearchResultModel extends BaseModel
  @singular: 'searchResult'
  @plural: 'searchResults'

  @apiEndPoint: 'search'
