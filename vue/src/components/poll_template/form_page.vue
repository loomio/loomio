<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash  from '@/shared/services/flash';
import PollTemplateForm from '@/components/poll_template/form';

export default {
  components: {PollTemplateForm},

  data() {
    return {
      pollTemplate: null,
      group: null
    };
  },

  created() {
    let pollTemplateId;
    if ((pollTemplateId = parseInt(this.$route.params.id))) {
      Records.pollTemplates.findOrFetchById(pollTemplateId).then(pollTemplate => {
        this.pollTemplate = pollTemplate;
      });
    } else {
      let groupId;
      if ((groupId = parseInt(this.$route.query.group_id))) {
        Records.groups.findOrFetchById(groupId).then(group => {
          let key;
          this.group = group;

          if ((key = this.$route.query.template_key)) {
            Records.remote.fetch({path: "poll_templates", params: {group_id: this.group.id} }).then(() => {
              this.pollTemplate = Records.pollTemplates.find(key);
              this.pollTemplate.groupId = this.group.id;
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
      v-card.poll-common-modal
        div.pa-4
          poll-template-form(
            v-if="pollTemplate"
            :poll-template="pollTemplate"
          )
</template>
