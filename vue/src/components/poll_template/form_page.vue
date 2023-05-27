<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import PollTemplateForm from '@/components/poll_template/form'

export default
  components: {PollTemplateForm}

  data: ->
    pollTemplate: null
    group: null

  created: ->
    if groupId = parseInt(@$route.query.group_id)
      Records.groups.findOrFetchById(groupId).then (group) =>
        @group = group

        if key = @$route.query.template_key
          Records.remote.fetch(path: "poll_templates", params: {group_id: @group.id} ).then =>
            pollTemplate = Records.pollTemplates.find(key)
            @pollTemplate = pollTemplate
            @pollTemplate.group_id = @group.id
        else
          Records.pollTemplates.findOrFetchByKey(key).then (pollTemplate) =>
            @pollTemplate = Records.pollTemplates.build(pollType: 'proposal', groupId: @group.id)


    if pollTemplateId = parseInt(@$route.query.template_id)
      Records.pollTemplates.findOrFetchById(pollTemplateId).then (pollTemplate) =>
        @pollTemplate = pollTemplate


</script>
<template lang="pug">
.poll-form-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      v-card.poll-common-modal
        div.pa-4
          poll-template-form(
            v-if="pollTemplate"
            :poll-template="pollTemplate"
          )
</template>
