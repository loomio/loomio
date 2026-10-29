<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import DiscussionTemplateForm from '@/components/discussion_template/form';
import { takeImportedTemplate } from '@/shared/helpers/template_file';

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
    let groupId, templateId, templateKey, importedTemplate, discussionId;
    if (templateId = parseInt(this.$route.params.id)) {
      Records.discussionTemplates.findOrFetchById(templateId).then(template => {
        this.discussionTemplate = template.clone();
      });
    } else if ((discussionId = parseInt(this.$route.query.discussion_id))) {
      Records.discussions.findOrFetchById(discussionId).then(async discussion => {
        if (discussion.discardedAt || !DiscussionTemplateService.canCreateTemplate(discussion.group())) {
          throw Object.assign(new Error('Forbidden'), {status: 403});
        }
        if (!discussion.createdTopicItem()) {
          await Records.topicItems.fetch({params: {discussion_key: discussion.key, sequence_id: 0, per: 1}});
        }
        this.group = discussion.group();
        this.discussionTemplate = discussion.buildTemplate();
      }).catch(error => {
        EventBus.$emit('pageError', error);
        if (error.status === 403 && !Session.isSignedIn()) {
          EventBus.$emit('openAuthModal');
        }
      });
    } else if (
      (groupId = parseInt(this.$route.query.group_id)) &&
      this.$route.query.import_json &&
      (importedTemplate = takeImportedTemplate('discussion_template'))
    ) {
      this.discussionTemplate = Records.discussionTemplates.build({
        ...importedTemplate,
        id: null,
        key: null,
        groupId,
        public: false
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
