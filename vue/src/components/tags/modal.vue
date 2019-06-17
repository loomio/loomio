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
    discussionTags: @discussion.info.tags || []
    loading: false
  methods:
    updateTags: ->
      @loading = true
      Records.tags.updateModel(@discussion, @discussionTags).then =>
        EventBus.$emit 'closeModal'
      .finally =>
        @loading = false
  computed:
    groupTags: -> @discussion.group().parentOrSelf().info.tags || []

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    h1.lmo-h1.modal-title(v-t="'loomio_tags.card_title'")
    dismiss-modal-button(:close="close")
  v-card-text
    v-combobox(v-model='discussionTags' :items='groupTags' label='Select tags to apply' item-text="name" multiple solo chips)
  v-card-actions
    v-btn.md-primary.md-raised.tag-form__submit(@click="updateTags()" v-t="'common.action.save'" :loading="loading")
</template>
<style lang="scss">
</style>
