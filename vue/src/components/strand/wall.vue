<script lang="js">
import ThreadLoader from '@/shared/loaders/thread_loader';
import RangeSet from '@/shared/services/range_set';

export default {
  props: {threads: Array },

  data() {
    return {loaders: []};
  },

  mounted() {
    this.threads.forEach(thread => {
      const loader = new ThreadLoader(thread);
      loader.addLoadUnreadRule();
      loader.fetch();
      this.loaders.push(loader);
    });
  }
};
</script>

<template>

<div class="strand-wall">
  <v-card v-for="loader in loaders" :key="loader.id">
    <strand-card :loader="loader"></strand-card>
  </v-card>
</div>
</template>

<style lang="sass">
.strand-wall
  cool: 1
</style>
