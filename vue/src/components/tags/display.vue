<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    model: Object
    showCounts: Boolean
    showOrgCounts: Boolean
    selected: String
    smaller: Boolean
    selected: String

  computed:
    groupKey: ->
      @model.group().key

    byName: -> 
      res = {}
      @model.group().tags().forEach (t) -> res[t.name] = t
      res

    tags: ->
      if @model.isA('group')
        @model.tags()
      else
        @model.tags.map (name, i) =>
          id: i
          name: name
          color: (@byName[name] || {}).color
          taggingsCount: (@byName[name] || {}).taggingsCount

</script>
<template lang="pug">
span.tags-display
  v-chip.ml-1.mb-1(
    v-for="tag in tags"
    :key="tag.id"
    :outlined="tag.name != selected"
    :small="!smaller"
    :xSmall="smaller"
    :color="tag.color"
    :to="'/g/'+groupKey+'/tags/'+tag.name"
    :class="{'mb-1': showCounts}"
  )
    span {{ tag.name }}
    span(v-if="showCounts")
      space
      span {{tag.taggingsCount}}
    span(v-if="showOrgCounts")
      space
      span {{tag.orgTaggingsCount}}
</template>
