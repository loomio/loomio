<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Session      from '@/shared/services/session'
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import PollTemplateService     from '@/shared/services/poll_template_service'
import PollCommonChooseTemplate from '@/components/poll/common/choose_template'
import {map, without, compact} from 'lodash'

export default
  components: {PollCommonChooseTemplate}

  props:
    discussion: Object
    group: Object

  data: ->
    selectedGroup: @group

  created: ->
    @watchRecords
      collections: ['groups']
      query: (store) => @fillGroups()

  methods:
    fillGroups: ->
      groups = []
      groupIds = Session.user().groupIds()
      Records.groups.collection.chain().
                   find(id: { $in: groupIds }, archivedAt: null, parentId: null).
                   data().forEach (parent) -> 
        groups.push(parent) if parent.pollTemplatesCount || parent.hiddenPollTemplates
        Records.groups.collection.chain().
                   find(id: { $in: groupIds }, archivedAt: null, parentId: parent.id).
                   data().forEach (subgroup) ->
          groups.push(subgroup) if subgroup.pollTemplatesCount || subgroup.hiddenPollTemplates
      @groups = groups
    selectGroup: (group) ->
      @selectedGroup = group
    setPoll: (poll) -> @$emit('setPoll', poll)
</script>

<template lang="pug">
div
  .poll-templates-select-group(v-if="!selectedGroup.id")
    p Select a group to use it's poll templates
    v-list
      v-list-item(v-for="group in groups" :key="group.id" @click="selectGroup(group)")
        v-list-item-avatar(aria-hidden="true")
          group-avatar(:group="group" v-if="!group.parentId")
        v-list-item-content
          v-list-item-title {{group.name}}
  poll-common-choose-template(
    v-else 
    @setPoll="setPoll"
    :discussion="discussion"
    :group="selectedGroup")
</template>