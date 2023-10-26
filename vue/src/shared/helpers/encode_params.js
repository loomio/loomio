/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import {map, keys} from 'lodash';

export var encodeParams = params => map(keys(params), key => encodeURIComponent(key) + "=" + encodeURIComponent(params[key])).join('&');
