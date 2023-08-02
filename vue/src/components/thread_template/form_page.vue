<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import ThreadTemplateForm from '@/components/thread_template/form'

export default
  components: {ThreadTemplateForm}

  data: ->
    discussionTemplate: null
    group: null

  created: ->
    if groupId = parseInt(@$route.query.group_id)
      @discussionTemplate = Records.discussionTemplates.build(groupId: groupId)
    else if templateId = parseInt(@$route.params.id)
      Records.discussionTemplates.findOrFetchById(templateId).then (template) =>
        @discussionTemplate = template

</script>
<template lang="pug">
.poll-form-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      v-card.poll-common-modal
        div.pa-4
          thread-template-form(
            v-if="discussionTemplate"
            :discussion-template="discussionTemplate"
          )
</template>
