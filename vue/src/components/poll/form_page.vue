<script lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import Flash  from '@/shared/services/flash';
import PollCommonForm from '@/components/poll/common/form';
import PollCommonChooseTemplate from '@/components/poll/common/choose_template';
import { compact } from 'lodash-es';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],
  components: {PollCommonForm, PollCommonChooseTemplate},

  data() {
    return {
      loading: false,
      poll: null,
      group: null,
      topic: null
    }
  },

  created() {
    // Sorry everyone, template_id is a poll_id in this case.
    // After the first release of poll_templates we can start to modify this stuff
    let discussionId, groupId, templateId;
    if (templateId = parseInt(this.$route.query.template_id)) {
      this.loading = true;
      Records.polls.findOrFetchById(templateId).then(poll => {
        this.poll = poll.clonePoll();
        if (Session.user().groupIds().includes(poll.groupId)) {
          this.poll.groupId = poll.groupId;
          this.group = this.poll.group();
        }
        this.loading = false;
      });
    }

    if (discussionId = parseInt(this.$route.query.discussion_id)) {
      this.loading = true;
      Records.discussions.findOrFetchById(discussionId).then(discussion => {
        this.topic = discussion.topic();
        this.group = discussion.group();
        this.loading = false;
      });
    }

    if (groupId = parseInt(this.$route.query.group_id)) {
      this.loading = true;
      Records.groups.findOrFetchById(groupId).then(group => {
        this.group = group;
        this.loading = false;

        let templateKey;
        if (templateKey = this.$route.query.template_key) {
          Records.pollTemplates.fetch({params: {group_id: groupId}}).then(() => {
            const template = Records.pollTemplates.find(templateKey);
            if (template) {
              this.poll = template.buildPoll();
              this.poll.groupId = groupId;
            }
          });
        }
      });
    }

    if (this.$route.params.key) {
      this.loading = true;
      Records.polls.findOrFetchById(this.$route.params.key).then(poll => {
        this.poll = poll.clone();
        EventBus.$emit('currentComponent', {
          group: poll.group(),
          poll,
          title: poll.title,
          page: 'pollFormPage'
        });
        this.loading = false;
      }).catch(function(error) {
        EventBus.$emit('pageError', error);
        if ((error.status === 403) && !Session.isSignedIn()) {
          EventBus.$emit('openAuthModal');
        }
      });
    }
  },

  methods: {
    setPoll(poll) {
      return this.poll = poll;
    }
  },

  computed: {
    isLoggedIn() {
      return Session.isSignedIn();
    },
    breadcrumbs() {
      return compact([this.group.parentId && this.group.parent(), this.group]).map(g => {
        return {
          title: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    }
  }
};

</script>
<template lang="pug">
v-main.poll-form-page
  loading(:until="!loading")
    v-container.max-width-800
      v-breadcrumbs(v-if="group" color="primary" :items="breadcrumbs")
        template(v-slot:divider)
          common-icon(name="mdi-chevron-right")
      v-card.poll-common-form-card(v-if="poll")
        poll-common-form.px-4(
          v-if="poll"
          :poll="poll"
          @setPoll="setPoll"
          redirect-on-save
        )
      v-card.poll-common-choose-template(v-if="!poll" :title="$t('poll_common.start_a_poll')")
        poll-common-choose-template(
          v-if="!poll"
          @setPoll="setPoll"
          :topic="topic"
          :group="group"
        )
</template>
