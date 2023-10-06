<script lang="coffee">
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import { ContainerMixin, HandleDirective } from 'vue-slicksort'

export default
  props:
    group:
      type: Object
      required: true
    close: Function

  directives:
    handle: HandleDirective

  data: ->
    allTags: @group.tags()

  mounted: ->
    @watchRecords
      key: 'tags'+@group.id
      collections: ['tags']
      query: =>
        @allTags = @group.tags()

  computed:
    canAdminTags: ->
      @group.adminsInclude(Session.user())

  methods:
    query: ->
      @allTags = @group.tags()

    openNewTagModal: ->
      EventBus.$emit 'openModal',
        component: 'TagsModal',
        props:
          tag: Records.tags.build(groupId: @group.id)
          close: =>
            EventBus.$emit 'openModal',
              component: 'TagsSelect',
              props:
                group: @group

    openEditTagModal: (tag) ->
      EventBus.$emit 'openModal',
        component: 'TagsModal',
        props:
          tag: tag.clone()
          close: =>
            EventBus.$emit 'openModal',
              component: 'TagsSelect',
              props:
                group: @group

    submit: ->
      EventBus.$emit 'closeModal'

    sortEnded: ->
      setTimeout =>
        Records.remote.post 'tags/priority',
          group_id: @group.id
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
      span(v-else v-t="{path: 'loomio_tags.only_admins_can_edit_tags', args: {group: group.parentOrSelf().name}}")

  div(v-if="canAdminTags")
    .pa-4(v-if="allTags.length == 0")
      p.text--secondary(v-t="'loomio_tags.no_tags_in_group'")
    sortable-list(v-model="allTags", :useDragHandle="true", @sort-end="sortEnded" append-to=".app-is-booted"  lock-axis="y" axis="y")
      sortable-item(v-for="(tag, index) in allTags", :index="index", :key="tag.id")
        v-list-item
          .handle(v-handle)
            v-icon mdi-drag-vertical
          v-chip(:color="tag.color" v-handle outlined) {{tag.name}}
          v-spacer
          v-btn(icon @click="openEditTagModal(tag)")
            v-icon.text--secondary mdi-pencil

    v-card-actions
      v-spacer
      v-btn.tag-form_new-tag(color="primary" @click="openNewTagModal" v-t="'loomio_tags.new_tag'")
</template>
