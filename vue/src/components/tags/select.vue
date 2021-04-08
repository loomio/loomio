<script lang="coffee">
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'
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
    allTags: @model.group().parentOrSelf().tags()

  mounted: ->
    @watchRecords
      key: 'tags'+@model.id
      collections: ['tags']
      query: =>
        @allTags = @model.group().parentOrSelf().tags()

  computed:
    canAdminTags: ->
      @model.group().parentOrSelf().adminsInclude(Session.user())

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
      EventBus.$emit 'closeModal'

    sortEnded: ->
      setTimeout =>
        Records.remote.post 'tags/priority',
          group_id: @model.groupId
          ids: @allTags.map (t) -> t.id

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    h1.headline(tabindex="-1" v-t="'loomio_tags.card_title'")
    v-spacer
    dismiss-modal-button(:close="close")

  .px-4.pb-2
    p.text--secondary
      span(v-if="canAdminTags" v-t="'loomio_tags.helptext'")
      span(v-else v-t="'loomio_tags.only_admins_can_edit_tags'")

  div(v-if="canAdminTags")
    .pa-4(v-if="allTags.length == 0")
      p.text--secondary(v-t="'loomio_tags.no_tags_in_group'")
    sortable-list(v-model="allTags" :useDragHandle="true" @sort-end="sortEnded")
      sortable-item(v-for="(tag, index) in allTags" :index="index" :key="tag.id")
        .handle(v-handle)
          v-icon mdi-drag-vertical
        v-chip(outlined :color="tag.color") {{tag.name}}
        v-spacer
        v-btn(icon @click="openEditTagModal(tag)")
          v-icon.text--secondary mdi-pencil

    v-card-actions
      v-spacer
      v-btn.tag-form_new-tag(color="primary" @click="openNewTagModal" v-t="'loomio_tags.new_tag'")
</template>
