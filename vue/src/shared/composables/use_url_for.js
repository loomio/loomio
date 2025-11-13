import { useRoute } from 'vue-router';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { pickBy, identity } from 'lodash-es';

export function useUrlFor() {
  const route = useRoute();

  const urlFor = (model, action, params) => {
    return LmoUrlService.route({ model, action, params });
  };

  const mergeQuery = (obj) => {
    return { query: pickBy(Object.assign({}, route.query, obj), identity) };
  };

  return {
    urlFor,
    mergeQuery
  };
}