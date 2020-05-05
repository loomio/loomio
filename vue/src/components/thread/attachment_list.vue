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
    a.lmo-pointer(v-if="attachment.preview_url" :href='attachment.download_url', target='_blank')
      img.attachment-list__preview(:src="attachment.preview_url")
    .attachment-list__item-details
      v-icon.mr-2(v-if="attachment.icon") {{ `mdi-${attachment.icon}` }}
      div
        a(:href="attachment.download_url")
          span {{ attachment.filename }}
        space
        span.lmo-grey-on-white ({{ prettifyBytes(attachment.byte_size) }})
        v-btn.ml-2(v-if="edit" icon :aria-label="$t('common.action.delete')" @click='edit')
          v-icon(size="medium") mdi-delete

</template>
<style lang="sass">
.attachment-list__item
  display: flex
  flex-direction: column
  margin: 8px 0
  line-height: 32px
  background: #f6f6f6
  border-radius: 2px

.attachment-list__item-details
  display: flex
  flex-direction: row
  align-items: center

.attachment-list__preview
  max-height: 320px
  max-width: 100%
</style>
