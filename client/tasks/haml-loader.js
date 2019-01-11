import { getOptions } from 'loader-utils';


module.exports = function(source) {
  var loaderUtils, haml, query, result
  this.cacheable && this.cacheable(true)
  loaderUtils = require("loader-utils")
  haml = require("haml")
  // query = loaderUtils.parseQuery(this.query)
  try {
    result = haml.render(source)
  } catch (e) {
    this.emitError('HAML:' + e)
    throw e
  }
  return "module.exports = " + JSON.stringify(result) + ";"
}
