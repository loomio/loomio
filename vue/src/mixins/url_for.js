import LmoUrlService from '@/shared/services/lmo_url_service';
import { pickBy, identity, isEqual } from 'lodash-es';

// this is a vue mixin
export default {
  methods: {
    urlFor(model, action, params) { return LmoUrlService.route({model, action, params}); },
    mergeQuery(obj) {
      return {query: pickBy(Object.assign({}, this.$route.query, obj), identity)};
    }
  }
}
