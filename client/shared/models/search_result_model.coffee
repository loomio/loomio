BaseModel = require 'shared/record_store/base_model'

module.exports = class SearchResultModel extends BaseModel
  @singular: 'searchResult'
  @plural: 'searchResults'
