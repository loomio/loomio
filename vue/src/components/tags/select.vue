<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import { ContainerMixin, HandleDirective } from 'vue-slicksort'

export default
  props:
    model:
      type: Object
      required: true
    close: Function

  directives:
    handle: HandleDirective

  data: ->
    loading: false
    allTags: @model.group().parentOrSelf().tags()

  methods:
    openNewTagModal: ->
      EventBus.$emit 'openModal',
        component: 'TagsModal',
        props:
          tag: Records.tags.build(groupId: @model.group().parentOrSelf().id)
          close: =>
            EventBus.$emit 'openModal',
              component: 'TagsSelect',
              props:
                model: @model

    openEditTagModal: (tag) ->
      EventBus.$emit 'openModal',
        component: 'TagsModal',
        props:
          tag: tag.clone()
          close: =>
            EventBus.$emit 'openModal',
              component: 'TagsSelect',
              props:
                model: @model

    submit: ->
      @loading = true
      @model.save().then =>
        Records.remote.post 'tags/priority',
          group_id: @model.groupId
          ids: @allTags.map (t) -> t.id
        .then =>
          EventBus.$emit 'closeModal'
      .finally =>
        @loading = false

    sortEnded: ->

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    h1.headline(tabindex="-1" v-t="'loomio_tags.card_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p(v-t="'loomio_tags.helptext'")
    sortable-list(v-model="allTags" :useDragHandle="true" @sort-end="sortEnded")
      sortable-item(v-for="(tag, index) in allTags" :index="index" :key="tag.id")
        v-checkbox(v-model="model.tagIds" hide-details outlined :color="tag.color" :value="tag.id")
          template(v-slot:label)
            v-chip(outlined :color="tag.color") {{tag.name}}
        v-spacer
        v-btn(icon @click="openEditTagModal(tag)")
          v-icon.text--secondary mdi-pencil
        .handle(v-handle icon)
          v-icon mdi-drag-vertical

  v-card-actions
    v-btn.tag-form_new-tag(@click="openNewTagModal" v-t="'loomio_tags.new_tag'")
    v-spacer
    v-btn.tag-form__submit(color="primary" @click="submit" v-t="'common.action.save'" :loading="loading")
</template>
