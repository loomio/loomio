import Records from '@/shared/services/records';
import { nextWatchRecordsName } from '@/shared/helpers/watch_records_name';

export default {
  data() {
    return {watchedRecords: []};
  },

  methods: {
    watchRecords(...args) {
      const obj = args[0],
            {
              collections,
              query,
              key
            } = obj
      const name = nextWatchRecordsName(collections, key);
      this.watchedRecords.push(name);
      Records.view({
        name,
        collections,
        query
      });
    }
  },

  unmounted() {
    this.watchedRecords.forEach(name => delete Records.views[name]);
  },
}
