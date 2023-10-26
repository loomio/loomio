<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash  from '@/shared/services/flash';
import ThreadTemplateForm from '@/components/thread_template/form';

export default {
  components: {ThreadTemplateForm},

  data() {
    return {
      discussionTemplate: null,
      group: null
    };
  },

  created() {
    let groupId, templateId, templateKey;
    if (templateId = parseInt(this.$route.params.id)) {
      Records.discussionTemplates.findOrFetchById(templateId).then(template => {
        this.discussionTemplate = template.clone();
      });
    } else if ((templateId = parseInt(this.$route.query.template_id)) && (groupId = parseInt(this.$route.query.group_id))) {
      Records.discussionTemplates.findOrFetchById(templateId).then(template => {
        this.discussionTemplate = template.clone();
        this.discussionTemplate.id = null;
        this.discussionTemplate.groupId = groupId;
        this.discussionTemplate.public = false;
      });
    } else if ((templateKey = this.$route.query.template_key) && (groupId = parseInt(this.$route.query.group_id))) {
      Records.discussionTemplates.findOrFetchByKey(templateKey, groupId).then(template => {
        this.discussionTemplate = template.clone();
      });
    } else if (groupId = parseInt(this.$route.query.group_id)) {
      this.discussionTemplate = Records.discussionTemplates.build({groupId});
    }
  }
};

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
