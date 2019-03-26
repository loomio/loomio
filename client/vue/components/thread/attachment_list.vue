<script lang="coffee">
module.exports =
  props:
    attachments: Array
</script>
<template lang="pug">
.attachment-list
  .attachment-list__item(v-for="attachment in attachments" :key="attachment.id")
    span {{ attachment }}
    a.lmo-pointer(v-if="attachment.preview_url" :href='attachment.download_url', target='_blank')
      img(:src="attachment.preview_url")
    .attachment-list__item-details
      a(:href="attachment.download_url")
        div
          v-icon(v-if="attachment.icon") {{ `mdi-${attachment.icon}` }}
          span {{ attachment.filename }}
</template>
<style lang="scss">

.attachment-list__item {
  display: flex;
  flex-direction: column;
  margin: 8px 0;
  line-height: 32px;
  background: #f6f6f6;
  border-radius: 2px;
}

.attachment-list__item-details {
  display: flex;
  flex-direction: row;
}
</style>
