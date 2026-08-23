<script lang="js">
export default {
    props: {
      topic_item: Object,
      itemable: Object
    }
};
</script>

<template lang="pug">
section.strand-item__discussion-edited
  strand-item-headline(:topic_item="topic_item" :itemable="itemable", :dateTime="topic_item.createdAt")
  p {{topic_item.recipientMessage}}
</template>
