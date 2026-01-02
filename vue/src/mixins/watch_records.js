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
              query,
              key
            } = obj
      const name = collections.concat(key || parseInt(Math.random()*10000)).join('_');
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
