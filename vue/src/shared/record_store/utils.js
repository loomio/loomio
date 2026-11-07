import { parseISO } from 'date-fns';
import { camelCase } from 'lodash-es';

const isTimeAttribute = attributeName => /(On|At)$/.test(attributeName);

// Server JSON uses a small, fixed set of snake_case keys, and lodash camelCase
// is slow, so convert each key once.
const fieldNames = new Map();
function fieldNameFor(key) {
  let field = fieldNames.get(key);
  if (field === undefined) {
    const name = camelCase(key);
    field = {name, isTime: isTimeAttribute(name)};
    fieldNames.set(key, field);
  }
  return field;
}

function parseJSON(json) { // parse a single record
  const attributes = {};
  Object.keys(json).forEach(key => {
    const field = fieldNameFor(key);
    const value = json[key];
    attributes[field.name] = (field.isTime && value != null) ? parseISO(value) : value;
  });
  return attributes;
}

export default {
  deserialize(json) {
    const result = {};
    Object.keys(json).forEach(key => {
      const value = json[key];
      result[fieldNameFor(key).name] = Array.isArray(value) ? value.map(parseJSON) : value;
    });
    return result;
  },

  parseJSON,

  isTimeAttribute(attributeName) {
    return isTimeAttribute(attributeName);
  }
};
