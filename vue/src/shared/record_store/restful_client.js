import { encodeParams } from '@/shared/helpers/encode_params';
import { omitBy, snakeCase, compact, isString, defaults, pickBy, isNil, identity } from 'lodash-es';

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}

const getCSRF = () => decodeURIComponent(__guard__(document.cookie.match("(^|;)\\s*csrftoken\\s*=\\s*([^;]+)"), x => x.pop()) || '');

export default class RestfulClient {

  constructor(resourcePlural = null) {
    this.defaultParams = {};
    this.currentUpload = null;
    this.apiPrefix = "/api/v1";
    this.onResponse = this.onResponse.bind(this);
    this.defaultParams.unsubscribe_token = new URLSearchParams(location.search).get('unsubscribe_token');
    this.defaultParams.membership_token = new URLSearchParams(location.search).get('membership_token');
    this.defaultParams.stance_token = new URLSearchParams(location.search).get('stance_token');
    this.defaultParams.discussion_reader_token = new URLSearchParams(location.search).get('discussion_reader_token');
    this.defaultParams = omitBy(this.defaultParams, isNil);
    this.processing = [];
    if (resourcePlural) { this.resourcePlural = snakeCase(resourcePlural); }
  }

  onPrepare(request)  { return request; }
  onCleanup(response) { return response; }
  onResponse(response) {
    if (response.ok) {
      return response.json().then(this.onSuccess);
    } else {
      return this.onFailure(response);
    }
  }

  onSuccess(data) { return data; }

  onFailure(response) {
    if (response.json) {
      return response.json().then(function(data) {
        data.status = response.status;
        data.statusText = response.statusText;
        data.ok = response.ok;
        throw data;
      });
    } else {
      throw response;
    }
  }
  
  onUploadSuccess(response) { return response; }

  buildUrl(path, params) {
    path = compact([this.apiPrefix, this.resourcePlural, path]).join('/');
    if (params == null) { return path; }
    return path + "?" + encodeParams(params);
  }

  memberPath(id, action) {
    return compact([id, action]).join('/');
  }

  fetchById(id, params) {
    if (params == null) { params = {}; }
    return this.getMember(id, '', params);
  }

  fetch({params, path}) {
    return this.get(path || '', params);
  }

  post(path, params) {
    return this.request(this.buildUrl(path), 'POST', this.paramsFor(params));
  }

  patch(path, params) {
    return this.request(this.buildUrl(path), 'PATCH', this.paramsFor(params));
  }

  delete(path, params) {
    return this.request(this.buildUrl(path), 'DELETE', this.paramsFor(params));
  }

  // NB: get requests place their params into the query string, rather than the request body
  get(path, params) {
    return this.request(this.buildUrl(path, this.paramsFor(params)), 'GET');
  }

  request(path, method, body) {
    if (body == null) { body = {}; }
    const opts = {
      method,
      credentials: 'same-origin',
      headers: { 
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': getCSRF()
      },
      body: JSON.stringify(body)
    };
    if (method === 'GET') { delete opts.body; }
    this.onPrepare();
    return fetch(path, opts)
    .then(this.onResponse, this.onFailure)
    .finally(this.onCleanup);
  }

  postMember(keyOrId, action, params) {
    return this.post(this.memberPath(keyOrId, action), params);
  }

  patchMember(keyOrId, action, params) {
    return this.patch(this.memberPath(keyOrId, action), params);
  }

  getMember(keyOrId, action, params) {
    if (action == null) { action = ''; }
    return this.get(this.memberPath(keyOrId, action), params);
  }

  create(params) {
    return this.post('', params);
  }

  update(id, params) {
    return this.patch(id, params);
  }

  destroy(id, params) {
    return this.delete(id, params);
  }

  discard(id, params) {
    return this.delete(id+'/discard', params);
  }

  undiscard(id, params) {
    return this.post(id+'/undiscard', params);
  }

  upload(path, file, options, onProgress) {
    if (options == null) { options = {}; }
    if (!file) { return; }
    return new Promise((resolve, reject) => {
      const data = new FormData();
      data.append(options.fileField     || 'file',     file);
      data.append(options.filenameField || 'filename', file.name.replace(/[^a-z0-9_\-\.]/gi, '_'));

      this.currentUpload = new XMLHttpRequest();
      this.currentUpload.open('POST', this.buildUrl(path), true);
      this.currentUpload.setRequestHeader('X-CSRF-TOKEN', getCSRF());
      this.currentUpload.responseType = 'json';
      this.currentUpload.addEventListener('load', () => {
        if ((this.currentUpload.status >= 200) && (this.currentUpload.status < 300)) {
          if (isString(this.currentUpload.response)) { this.currentUpload.response = JSON.parse(this.currentUpload.response); }
          this.onUploadSuccess(this.currentUpload.response);
          resolve(this.currentUpload.response);
          return this.currentUpload = null;
        }
      });
      if (onProgress) { this.currentUpload.upload.addEventListener('progress', onProgress); }
      this.currentUpload.addEventListener('error', reject);
      this.currentUpload.addEventListener('abort', reject);
      return this.currentUpload.send(data);
    });
  }

  abort() {
    if (this.currentUpload) { return this.currentUpload.abort(); }
  }

  paramsFor(params) {
    return defaults({}, this.defaultParams, pickBy(params, v => !isNil(v)));
  }
};
