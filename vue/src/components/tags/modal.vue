<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import WatchRecords from '@/mixins/watch_records'
import { submitForm }      from '@/shared/helpers/form.coffee'
import { difference } from 'lodash'

export default
  mixins: [WatchRecords]
  props:
    discussion: Object
    close: Function
  data: ->
    tag: @newTag()
    submit: null
    discussionTags: []
    groupTags: []
    appliedTags: []
  methods:
    newTag: ->
      Records.tags.build
        groupId: @discussion.group().parentOrSelf().id
        color:   AppConfig.pollColors.poll[0]
  created: ->
    Records.tags.fetchByGroup(@discussion.group().parentOrSelf())
    @watchRecords
      collections: ['tags', 'discussion_tags']
      query: (store) =>
        @groupTags = Records.tags.find groupId: @discussion.group().parentOrSelf().id
        @discussionTags = Records.discussionTags.find discussionId: @discussion.id
        @appliedTags = @discussionTags.map (dtag) => dtag.tag()

    @submit = submitForm @, @tag,
      flashSuccess: 'loomio_tags.tag_created'
      successCallback: =>
        @tag = @newTag()

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    v-icon mdi-tag
    h1.lmo-h1.modal-title(v-t="'loomio_tags.apply_tags'")
    dismiss-modal-button(:close="close")
  v-card-text
    //- A PLACE TO SHOW ALL APPLIED TAGS
    v-select(v-model='appliedTags' :items='groupTags' chips label='Select tags to apply' item-text="name" item-value="id" multiple solo return-object)
    p discussionTags {{ discussionTags }}
    p **********
    p groupTags {{ groupTags }}
    p **********
    p appliedTags {{ appliedTags }}
    //- TAG CREATION
    v-text-field(v-model="tag.name" label="Create new label")
    validation-errors(:subject="tag" field="name")
  v-card-actions
    v-btn.md-primary.md-raised.tag-form__submit(@click="submit()" v-t="'common.action.save'")
</template>
<style lang="scss">
</style>
