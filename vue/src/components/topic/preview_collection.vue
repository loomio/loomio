<script lang="js">
import {slice, orderBy} from 'lodash-es';
export default {
  props: {
    topics: Array,
    limit: {
      type: Number,
      default: 25
    },
    order: {
      type: String,
      default: '-lastActivityAt'
    }
  },
  computed: {
    orderedTopics() {
      return slice(orderBy(this.topics, this.order), 0, this.limit);
    }
  }
};
</script>

<template lang="pug">
v-list.topic-previews(lines="two")
  topic-preview(v-for="topic in orderedTopics", :key="topic.id", :topic="topic")
</template>
