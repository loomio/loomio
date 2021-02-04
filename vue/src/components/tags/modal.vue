<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'

export default
  props:
    model:
      type: Object
      required: true
    close: Function
  data: ->
    loading: false
  methods:
    submit: ->
      @loading = true
      @model.save().then =>
        EventBus.$emit 'closeModal'
      .finally =>
        @loading = false
  computed:
    tags: -> @model.group().parentOrSelf().tags()

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    h1.headline(tabindex="-1" v-t="'loomio_tags.card_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    v-checkbox(v-model="model.tagIds" hide-details outlined v-for="tag in tags" :key="tag.id" :color="tag.color" :value="tag.id")
      template(v-slot:label)
        v-chip(small outlined :color="tag.color") {{tag.name}}
  v-card-actions
    v-spacer
    v-btn.tag-form__submit(color="primary" @click="submit" v-t="'common.action.save'" :loading="loading")
</template>
