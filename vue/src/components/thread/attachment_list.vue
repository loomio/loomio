<script lang="coffee">
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import prettyBytes from 'pretty-bytes'

export default
  props:
    attachments: [Array, Object]
    edit:
      default: null
      type: Function
  methods:
    prettifyBytes: (s) -> prettyBytes(s)
    deleteDocument: ->
      EventBus.$emit 'openModal',
        component: 'GroupForm'
        props:
          group: @group
  computed:
    canDelete: ->
      @group && AbilityService.canEditGroup(@group)
</script>
<template lang="pug">
.attachment-list
  .attachment-list__item(v-for="attachment in attachments" :key="attachment.id")
    a.attachment-list__preview(v-if="attachment.preview_url" :href='attachment.download_url', target='_blank')
      img(:src="attachment.preview_url")
    .attachment-list__item-details
      a(:href="attachment.download_url") {{ attachment.filename }}
      v-btn.ml-2(v-if="edit" icon :aria-label="$t('common.action.delete')" @click='edit')
        v-icon(size="medium") mdi-delete

</template>
<style lang="sass">
.attachment-list__item
  display: flex
  margin: 8px 0
  line-height: 32px
  background: #f6f6f6
  border-radius: 2px

.attachment-list__item-details
  padding: 0 4px
  display: flex
  flex-direction: row
  align-items: center

.attachment-list__preview img
  max-height: 128px
  max-width: 100%
.attachment-list__preview
  width: 128px
</style>
