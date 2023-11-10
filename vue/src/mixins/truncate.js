import {truncate} from 'lodash-es';
export default {
  methods: {
    truncate(string, length, separator) {
      if (length == null) { length = 100; }
      if (separator == null) { separator = ' '; }
      return truncate(string, {length, separator});
    }
  }
};
