/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ReactionService;
import { debounce, forEach, compact } from 'lodash';
import Records from '@/shared/services/records';

let ids = {};
const resetIds = () => ids = {
  comment_ids: [],
  discussion_ids: [],
  poll_ids: [],
  outcome_ids: [],
  stance_ids: []
};

resetIds();

const encodeIds = function(ids) {
  const o = {};
  forEach(ids, function(v, k) {
    o[k] = v.join('x') || null;
    return true;
  });
  return o;
};

const fetch = debounce(function() {
  if (Object.keys(encodeIds(ids)).length === 0) { return; }
  Records.reactions.fetch({params: encodeIds(ids)});
  return resetIds();
}
, 500);

export default new (ReactionService = class ReactionService {
  enqueueFetch(model) {
    if (typeof model.isA === 'function' ? model.isA('stance') : undefined) { ids['stance_ids'].push(model.id); }
    if (typeof model.isA === 'function' ? model.isA('comment') : undefined) { ids['comment_ids'].push(model.id); }
    if (typeof model.isA === 'function' ? model.isA('discussion') : undefined) { ids['discussion_ids'].push(model.id); }
    if (typeof model.isA === 'function' ? model.isA('poll') : undefined) { ids['poll_ids'].push(model.id); }
    if (typeof model.isA === 'function' ? model.isA('outcome') : undefined) { ids['outcome_ids'].push(model.id); }
    return fetch();
  }
});
