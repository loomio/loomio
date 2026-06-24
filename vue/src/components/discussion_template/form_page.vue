<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash  from '@/shared/services/flash';
import DiscussionTemplateForm from '@/components/discussion_template/form';

export default {
  components: {DiscussionTemplateForm},

  data() {
    return {
      discussionTemplate: null,
      group: null,
      sourceProcessName: null
    };
  },

  mounted() {
    EventBus.$emit('content-title-visible', false);
    const isEdit = !!this.$route.params.id;
    EventBus.$emit('currentComponent', {
      titleKey: isEdit ? 'discussion_form.edit_discussion_template' : 'discussion_form.new_discussion_template',
      page: 'discussionTemplateFormPage'
    });
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
        this.sourceProcessName = this.discussionTemplate.processName;
        this.discussionTemplate.id = null;
        this.discussionTemplate.processName = null;
        this.discussionTemplate.groupId = groupId;
        this.discussionTemplate.public = false;
      });
    } else if ((templateKey = this.$route.query.template_key)) {
      groupId = parseInt(this.$route.query.group_id) || null;
      Records.discussionTemplates.findOrFetchByKey(templateKey, groupId).then(template => {
        this.discussionTemplate = template.clone();
        this.sourceProcessName = this.discussionTemplate.processName;
        this.discussionTemplate.id = null;
        this.discussionTemplate.processName = null;
        this.discussionTemplate.key = templateKey;
        this.discussionTemplate.groupId = groupId;
        this.discussionTemplate.public = false;
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
      discussion-template-form(
        v-if="discussionTemplate"
        :discussion-template="discussionTemplate"
        :source-process-name="sourceProcessName"
      )
</template>
