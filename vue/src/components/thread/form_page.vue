<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';

export default {
  data() {
    return {
      discussion: null,
      isDisabled: false,
      groupId: null,
      user: null
    };
  },

  mounted() {
    this.init();
  },

  watch: {
    '$route.query.group_id': 'init',
    '$route.query.blank_template': 'init',
    '$route.query.new_template': 'init',
    '$route.query.template_id': 'init',
    '$route.params.key': 'init'
  },

  methods: {
    init() {
      let discussionId, templateId, templateKey, userId;
      this.discussion = null;

      if (this.$route.params.key) {
        Records.discussions.findOrFetchById(this.$route.params.key).then(discussion => {
          this.discussion = discussion.clone();
        });

      } else if ((templateId = parseInt(this.$route.query.template_id))) {
        Records.discussionTemplates.findOrFetchById(templateId).then(template => {
          this.discussion = template.buildDiscussion();
          if (parseInt(this.$route.query.group_id)) {
            this.discussion.groupId = parseInt(this.$route.query.group_id);
          }
        });

      } else if ((templateKey = this.$route.query.template_key)) {
        Records.discussionTemplates.findOrFetchByKey(this.$route.query.template_key, this.$route.query.group_id).then(template => {
          this.discussion = template.buildDiscussion();
          if (parseInt(this.$route.query.group_id)) {
            this.discussion.groupId = parseInt(this.$route.query.group_id);
          }
        });

      } else if ((discussionId = parseInt(this.$route.query.discussion_id))) {
        Records.discussions.findOrFetchById(discussionId).then(dt => {
          this.discussion = dt.buildCopy();
          if (dt.groupId && Session.user().groupIds().includes(dt.groupId)) {
            this.discussion.groupId = dt.groupId;
          }
        });

      } else if ((this.groupId = parseInt(this.$route.query.group_id))) {
        Records.groups.findOrFetchById(this.groupId).then(() => {
          this.discussion = Records.discussions.build({
            title: this.$route.query.title,
            groupId: this.groupId,
            descriptionFormat: Session.defaultFormat()
          });
        });

      } else if ((userId = parseInt(this.$route.query.user_id))) {
        Records.users.findOrFetchById(userId).then(user => {
          this.user = user;
          this.discussion = Records.discussions.build({
            title: this.$route.query.title,
            groupId: null,
            descriptionFormat: Session.defaultFormat()
          });
        });

      } else {
        this.discussion = Records.discussions.build({
          title: this.$route.query.title,
          descriptionFormat: Session.defaultFormat()
        });
      }
    }
  }
};

</script>
<template lang="pug">
v-main
  v-container.start-discussion-page.max-width-800.px-0.px-sm-3
    v-card
      discussion-form(
        v-if="discussion"
        :discussion='discussion'
        is-page
        :key="discussion.id"
        :user="user")
</template>
