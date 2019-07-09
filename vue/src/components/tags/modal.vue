<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import WatchRecords from '@/mixins/watch_records'
import { submitForm }      from '@/shared/helpers/form.coffee'

export default
  mixins: [WatchRecords]
  props:
    discussion:
      type: Object
      required: true
    close: Function
  data: ->
    discussionTags: @discussion.tagNames || []
    loading: false
  methods:
    updateTags: ->
      @loading = true
      Records.tags.updateModel(@discussion, @discussionTags).then =>
        EventBus.$emit 'closeModal'
      .finally =>
        @loading = false
  computed:
    groupTags: -> @discussion.group().parentOrSelf().tagNames || []

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    h1.headline(v-t="'loomio_tags.card_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    v-combobox(v-model='discussionTags' :items='groupTags' label='Select tags to apply' item-text="name" multiple solo deletable-chips chips)
  v-card-actions
    v-spacer
    v-btn.tag-form__submit(color="primary" @click="updateTags()" v-t="'common.action.save'" :loading="loading")
</template>
