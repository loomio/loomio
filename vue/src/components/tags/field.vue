<script lang="coffee">
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'

export default
  props:
    model: Object

  methods:
    remove: (id) ->
      @model.tagIds.splice(@model.tagIds.indexOf(id), 1)
    openTagsSelectModal: ->
      EventBus.$emit 'openModal',
        component: 'TagsSelect',
        props:
          model: @model.clone()
  computed:
    items: ->
      @model.group().parentOrSelf().tags()

    actor: ->
      Session.user()

</script>

<template lang="pug">
v-autocomplete.announcement-form__input(
  v-if="model.groupId"
  multiple
  hide-selected
  v-model='model.tagIds'
  item-text='name'
  item-value='id'
  :label="$t('loomio_tags.tags')"
  :items='model.group().parentOrSelf().tags()'
  :append-outer-icon="model.isA('discussion') ? 'mdi-tag-plus' : null"
  @click:append-outer="openTagsSelectModal"
  )
  template(v-slot:no-data)
    v-list-item
      v-list-item-content
        v-list-item-title
          span(v-if="model.group().parentOrSelf().tags().length == 0" v-t="'loomio_tags.no_tags_in_group'")
          span(v-if="model.group().parentOrSelf().tags().length" v-t="'common.no_results_found'")
  template(v-slot:selection='data')
    v-chip.chip--select-multi(
      :value='data.item.id'
      close
      outlined
      :color='data.item.color'
      @click:close='remove(data.item.id)')
      span {{ data.item.name }}
  template(v-slot:item='data')
    v-chip.chip--select-multi(outlined :color='data.item.color' )
      span {{ data.item.name }}

</template>
