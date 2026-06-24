<script lang="js">
import Records from '@/shared/services/records';
import PollTemplateForm from '@/components/poll_template/form';
import EventBus from '@/shared/services/event_bus';

export default {
  components: {PollTemplateForm},

  data() {
    return {
      pollTemplate: null,
      group: null,
      sourceProcessName: null
    };
  },

  mounted() {
    EventBus.$emit('content-title-visible', false);
    const isEdit = !!this.$route.params.id;
    EventBus.$emit('currentComponent', {
      titleKey: isEdit ? 'poll_common.edit_poll_template' : 'poll_common.new_poll_template',
      page: 'pollTemplateFormPage'
    });
  },

  created() {
    let pollTemplateId, groupId;
    if ((pollTemplateId = parseInt(this.$route.params.id))) {
      Records.pollTemplates.findOrFetchById(pollTemplateId).then(pollTemplate => {
        this.pollTemplate = pollTemplate;
      });
    } else if ((pollTemplateId = parseInt(this.$route.query.template_id)) && (groupId = parseInt(this.$route.query.group_id))) {
      Records.pollTemplates.findOrFetchById(pollTemplateId).then(pollTemplate => {
        this.pollTemplate = pollTemplate.clone();
        this.sourceProcessName = this.pollTemplate.processName;
        this.pollTemplate.id = null;
        this.pollTemplate.processName = null;
        this.pollTemplate.groupId = groupId;
        this.pollTemplate.example = false;
      });
    } else {
      if ((groupId = parseInt(this.$route.query.group_id))) {
        Records.groups.findOrFetchById(groupId).then(group => {
          let key;
          this.group = group;

          if ((key = this.$route.query.template_key)) {
            Records.remote.fetch({path: "poll_templates", params: {group_id: this.group.id} }).then(() => {
              this.pollTemplate = Records.pollTemplates.find(key);
              if (this.pollTemplate) {
                this.sourceProcessName = this.pollTemplate.processName;
                this.pollTemplate.processName = null;
                this.pollTemplate.groupId = this.group.id;
                this.pollTemplate.example = false;
              } else {
                this.pollTemplate = Records.pollTemplates.build({pollType: 'proposal', groupId: this.group.id});
              }
            });
          } else {
            this.pollTemplate = Records.pollTemplates.build({pollType: 'proposal', groupId: this.group.id});
          }
        });
      } else {
        console.error("no group or template id found");
      }
    }
  }
};

</script>
<template lang="pug">
.poll-form-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      poll-template-form(
        v-if="pollTemplate"
        :poll-template="pollTemplate"
        :source-process-name="sourceProcessName"
      )
</template>
