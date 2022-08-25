<script lang="coffee">
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    groupId: Number
    discussion: Object

  data: ->
    templates: []

  mounted: ->
    Records.discussions.fetch
      params:
        group_id: @groupId
        filter: 'templates'
        exclude_types: 'user poll'
        per: 50

    @watchRecords
      key: "newDiscussionInGroup#{@groupId}"
      collections: ['discussions']
      query: =>
        @templates = Records.discussions.collection.chain().find(
          groupId: @groupId,
          template: true).data()

</script>
<template lang="pug">
div
  v-card-title
    h1.headline(tabindex="-1" v-t="'discussion_form.thread_templates'")
  v-list
    v-list-item(
      :to="'/d/new?blank_template=1&group_id='+groupId"
    )
      v-list-item-content
        v-list-item-title(v-t="'discussion_form.blank'")
    v-list-item(
      v-for="template in templates" 
      :key="template.id"
      :to="'/d/new?template_id='+template.id"
    )
      v-list-item-content
        v-list-item-title {{template.title}}
    v-list-item(
      :to="'/d/new?new_template=1&group_id='+$route.query.group_id"
    )
      v-list-item-content
        v-list-item-title(v-t="'discussion_form.new_template'")
</template>
