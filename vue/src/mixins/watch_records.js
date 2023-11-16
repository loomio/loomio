import Records from '@/shared/services/records';

export default {
  data() {
    return {watchedRecords: []};
  },

  methods: {
    watchRecords(...args) {
      const obj = args[0],
            {
              collections,
              query
            } = obj,
            val = obj.key,
            key = val != null ? val : '';
      const name = `${collections.join('_')}_${this._uid}_${key}`;
      this.watchedRecords.push(name);
      Records.view({
        name,
        collections,
        query
      });
    }
  },

  beforeDestroy() {
    return this.watchedRecords.forEach(name => delete Records.views[name]);
  }
}
