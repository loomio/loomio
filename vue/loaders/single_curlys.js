module.exports = function singleCurlys(source, map) {
  source = source.replace(/{{/g, '{')
  source = source.replace(/}}/g, '}')
  this.callback(null, source, map);
}
