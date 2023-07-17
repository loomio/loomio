<script lang="coffee">
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'

export default
  props:
    model: Object

  data: ->
    items: @model.group().tags().map((t) -> t.name)

  methods:
    colorFor: (name) ->
      (@model.group().tags().find((t) -> t.name == name) || {}).color

    remove: (name) ->
      @model.tags.splice(@model.tags.indexOf(name), 1)

  computed:
    actor: ->
      Session.user()

</script>

<template lang="pug">
v-combobox.tags-field__input(
  multiple
  hide-selected
  v-model='model.tags'
  :label="$t('loomio_tags.tags')"
  :items='items'
  )
  template(v-slot:selection='data')
    v-chip.chip--select-multi(
      :key="JSON.stringify(data.item)"
      :value='data.item'
      close
      outlined
      :color='colorFor(data.item)'
      @click:close='remove(data)')
      span {{ data.item }}
  template(v-slot:item='data')
    v-chip.chip--select-multi(outlined :color='colorFor(data.item)' )
      span {{ data.item }}

</template>
