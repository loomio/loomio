BaseModel = require 'shared/models/base_model.coffee'

module.exports = class SearchResultModel extends BaseModel
  @singular: 'searchResult'
  @plural: 'searchResults'

  @apiEndPoint: 'search'
