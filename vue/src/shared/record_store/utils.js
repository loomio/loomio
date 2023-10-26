/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let Utils;
import parseISO from 'date-fns/parseISO';
import { each, keys, map, camelCase, isArray} from 'lodash';

const transformKeys = function(attributes, transformFn) {
  const result = {};
  each(keys(attributes), function(key) {
    result[transformFn(key)] = attributes[key];
    return true;
  });
  return result;
};

const isTimeAttribute = attributeName => /At$/.test(attributeName);

export default new (Utils = class Utils {
  deserialize(json) {
    const result = {};
    const attributes = transformKeys(json, camelCase);
    each(keys(attributes), name => {
      if (isArray(attributes[name])) {
        return result[name] = map(attributes[name], this.parseJSON);
      } else {
        return result[name] = attributes[name];
      }
  });
    return result;
  }

  parseJSON(json) { // parse a single record
    const attributes = transformKeys(json, camelCase);
    each(keys(attributes), function(name) {
      if (attributes[name] != null) {
        if (isTimeAttribute(name)) {
          attributes[name] = parseISO(attributes[name]);
        } else {
          attributes[name] = attributes[name];
        }
      }
      return true;
    });
    return attributes;
  }

  isTimeAttribute(attributeName) {
    return isTimeAttribute(attributeName);
  }
});
