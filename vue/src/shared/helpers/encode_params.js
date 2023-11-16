import {map, keys} from 'lodash-es';

export var encodeParams = params => map(keys(params), key => encodeURIComponent(key) + "=" + encodeURIComponent(params[key])).join('&');
