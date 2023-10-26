/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import AppConfig from '@/shared/services/app_config';
import {keys, map} from 'lodash';

export default class LmoUrlService {
  static shareableLink(model) {
    if (model.isA('group')) {
      return this.buildModelRoute('', model.token, '', {}, {namespace: 'join/group', absolute: true});
    } else {
      return this.route({model, options: {absolute: true}});
    }
  }

  static route({model, action, params, options}) {
    if ((model != null) && (action != null)) {
      return this[model.constructor.singular](model, {}, {noStub: true}) + this.routePath(action);
    } else if (model != null) {
      return this[model.constructor.singular](model, params, options);
    } else {
      return this.routePath(action);
    }
  }

  static routePath(route) {
    return "/".concat(route).replace('//', '/');
  }

  static group(g, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    if ((g.handle != null) && !options.noStub) {
      return this.buildModelRoute('', g.handle, '', params, options);
    } else {
      return this.buildModelRoute('g', g.key, g.fullName, params, options);
    }
  }

  static discussion(d, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    const action = options.print ? null : options.action || d.title;
    return this.buildModelRoute('d', d.key, action, params, options);
  }

  static discussionPoll(p, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    if (p.discussionId) {
      return this.event(p.createdEvent());
    } else {
      return this.buildModelRoute('p', p.key, options.action || p.title, params, options);
    }
  }

  static poll(p, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.buildModelRoute('p', p.key, options.action || p.title, params, options);
  }

  static outcome(o, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.poll(o.poll(), params, options);
  }

  static pollSearch(params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.buildModelRoute('polls', '', options.action, params, options);
  }

  static searchResult(r, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.discussion(r, params, options);
  }

  static user(u, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.buildModelRoute('u', u[options.key || 'username'], null, params, options);
  }

  static comment(c, params) {
    if (params == null) { params = {}; }
    return this.route({model: c.discussion(), action: `comment/${c.id}`, params});
  }

  static membership(m, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.route({model: m.group(), action: 'memberships', params});
  }

  static membershipRequest(mr, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.route({model: mr.group(), action: 'membership_requests', params});
  }

  static event(e, params, options) {
    if (params == null) { params = {}; }
    if (options == null) { options = {}; }
    return this.discussion(e.discussion(), params, options) + `/${e.sequenceId}`;
  }

  static buildModelRoute(path, key, name, params, options) {
    let result = options.absolute ? AppConfig.baseUrl : "/";
    if ((options.namespace || path || "").length > 0) { result += `${options.namespace || path}/`; }
    result += `${key}`;
    if (!(name == null) && (options.noStub == null)) { result += "/" + this.stub(name); }
    if (options.ext != null) { result += "." + options.ext; }
    if (keys(params).length) { result += "?" + this.queryStringFor(params); }
    return result;
  }

  static stub(name) {
    return name.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase();
  }

  static queryStringFor(params) {
    if (params == null) { params = {}; }
    return map(params, (value, key) => `${key}=${value}`).join('&');
  }
}
