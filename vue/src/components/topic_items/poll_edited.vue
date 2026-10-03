<script lang="js">
export default {
  props: {
    topic_item: Object,
    itemable: Object
  }
}
</script>

<template lang="pug">
section.topic-item__poll-edited
  topic-item-headline(:topic_item="topic_item" :itemable="itemable", :dateTime="topic_item.createdAt")
  p.topic-item__body(v-if="topic_item.changeNote" style="white-space: pre-wrap") {{ topic_item.changeNote }}
</template>
