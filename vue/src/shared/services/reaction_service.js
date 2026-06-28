import Records from '@/shared/services/records';
import { debounce, uniq, capitalize } from 'lodash-es';

const pending = {
  comment_ids: [],
  discussion_ids: [],
  outcome_ids: [],
  poll_ids: [],
  stance_ids: []
};

const TYPE_TO_PARAM = {
  comment:    'comment_ids',
  discussion: 'discussion_ids',
  outcome:    'outcome_ids',
  poll:       'poll_ids',
  stance:     'stance_ids'
};

const fetched = new Set();

const flush = debounce(function() {
  const params = {};
  let hasAny = false;

  Object.entries(pending).forEach(([key, ids]) => {
    if (ids.length > 0) {
      params[key] = ids.join('x');
      pending[key] = [];
      hasAny = true;
    }
  });

  if (hasAny) {
    Records.reactions.fetch({ params });
  }
}, 500);

export default {
  enqueueFetch(model) {
    const key = TYPE_TO_PARAM[model.constructor.singular];
    if (!key) return;

    const cacheKey = `${model.constructor.singular}:${model.id}`;
    if (fetched.has(cacheKey)) return;
    fetched.add(cacheKey);

    const reactableType = capitalize(model.constructor.singular);
    if (Records.reactions.find({ reactableId: model.id, reactableType }).length > 0) return;

    pending[key] = uniq([...pending[key], model.id]);
    flush();
  }
};
