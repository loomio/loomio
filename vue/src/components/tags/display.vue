<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    tags: Array
    group: Object
    showCounts: Boolean
    showOrgCounts: Boolean
    selected: String
    smaller: Boolean
    selected: String

  computed:
    groupKey: ->
      @group.key

    byName: -> 
      res = {}
      @group.tags().forEach (t) -> res[t.name] = t
      res

    tagObjects: ->
      @tags.map (name, i) =>
        id: i
        name: name
        color: (@byName[name] || {}).color
        taggingsCount: (@byName[name] || {}).taggingsCount

</script>
<template lang="pug">
span.tags-display
  v-chip.mr-1(
    v-for="tag in tagObjects"
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
