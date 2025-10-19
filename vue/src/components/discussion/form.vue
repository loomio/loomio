<script lang="js">
import Session        from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import ThreadService from '@/shared/services/thread_service';
import { compact } from 'lodash-es';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash   from '@/shared/services/flash';
import { I18n } from '@/i18n';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import ThreadTemplateHelpPanel from '@/components/thread_template/help_panel';
import FormatDate from '@/mixins/format_date';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, FormatDate, UrlFor],
  components: {RecipientsAutocomplete, ThreadTemplateHelpPanel},

  props: {
    discussion: Object,
    isPage: Boolean,
    user: Object
  },

  data() {
    return {
      tab: 0,
      upgradeUrl: AppConfig.baseUrl + 'upgrade',
      submitIsDisabled: false,
      searchResults: [],
      subscription: this.discussion.group().parentOrSelf().subscription,
      groupItems: [],
      initialRecipients: [],
      discussionTemplate: null,
      loaded: false,
      shouldReset: false,
      titleRules: [
        value => {
          if (value) return true
          return this.$t('common.required')
        }
      ]
    };
  },

  mounted() {
    Records.users.findOrFetchGroups().then(() => {
      if (this.discussion.discussionTemplateId) {
        Records.discussionTemplates.findOrFetchById(this.discussion.discussionTemplateId).then(template => {
          this.discussionTemplate = template;
          if ( this.discussion.isNew() &&
               (template.recipientAudience === 'group') &&
               this.discussion.groupId &&
               AbilityService.canAnnounceDiscussion(this.discussion) )
          {
            this.initialRecipients = [{
              type: 'audience',
              id: 'group',
              icon: 'mdi-account-group',
              name: I18n.global.t('announcement.audiences.group', {name: this.discussion.group().name}),
              size: this.discussion.group().acceptedMembershipsCount
            }];
          }
        })
        .finally(() => { this.loaded = true; });
      } else {
        this.loaded = true;
      }
    });

    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: records => { this.updateGroupItems(); }
    });
  },

  watch: {
    'discussion.groupId': {
      immediate: true,
      handler(groupId) {
        this.subscription = this.discussion.group().parentOrSelf().subscription;
        const users = compact([this.user]).map(u => ({
          id: u.id,
          type: 'user',
          name: u.nameOrEmail(),
          user: u
        }));
        this.initialRecipients = [];
        this.initialRecipients = this.initialRecipients.concat(users);
        this.discussion.private = this.discussion.privateDefaultValue();
        this.reset = !this.reset;
      }
    }
  },

  methods: {
    validate(field) {
      return [ () => this.discussion.errors[field] === undefined || this.discussion.errors[field][0] ]
    },

    discardDraft() {
      if (confirm(I18n.global.t('formatting.confirm_discard'))) {
        EventBus.$emit('resetDraft', 'discussion', this.discussion.id, 'description', this.discussion.description);
      }
    },

    submit() {
      const actionName = this.discussion.id ? 'updated' : 'created';
      this.discussion.setErrors();
      this.$refs.form.resetValidation();
      this.discussion.save().then(data => {
        const discussionKey = data.discussions[0].key;
        EventBus.$emit('closeModal');
        this.shouldReset = !this.shouldReset;
        Records.discussions.findOrFetchById(discussionKey, {}, true).then(discussion => {
          Flash.success(`discussion_form.messages.${actionName}`);
          this.$router.push(this.urlFor(discussion));
        });
      }).catch(error => {
        this.$refs.form.validate();
        Flash.error('common.check_for_errors_and_try_again');
      })
    },

    updateGroupItems() {
      this.groupItems = [{title: this.$t('discussion_form.none_invite_only_thread'), value: null}].concat(Session.user().groups().map(g => ({
        title: g.fullName,
        value: g.id
      })));
    },

    openEditLayout() {
      return ThreadService.actions(this.discussion, this)['edit_arrangement'].perform();
    }
  },

  computed: {
    cardTitle() {
      if (this.isMovingItems) {
        return I18n.global.t('discussion_form.moving_items_title')
      } else {
        if (this.discussion.id) {
          return I18n.global.t('discussion_form.edit_discussion_title')
        } else {
          return I18n.global.t('discussion_form.new_discussion_title')
        }
      }
    },
    titlePlaceholder() {
      if (this.discussionTemplate && this.discussionTemplate.titlePlaceholder) {
        return I18n.global.t('common.prefix_eg', {val: this.discussionTemplate.titlePlaceholder});
      } else {
        return I18n.global.t('discussion_form.title_placeholder');
      }
    },

    maxThreads() {
      return this.subscription.max_threads;
    },

    threadCount() {
      return this.discussion.group().parentOrSelf().orgDiscussionsCount;
    },

    maxThreadsReached() {
      return this.maxThreads && (this.threadCount >= this.maxThreads);
    },

    subscriptionActive() {
      return this.subscription.active;
    },

    canStartThread() {
      return this.subscriptionActive && !this.maxThreadsReached;
    },

    showUpgradeMessage() {
      return !this.discussion.id && !this.canStartThread;
    },

    isMovingItems() {
      return this.discussion.forkedEventIds.length;
    }
  }
}
</script>

<template lang="pug">
v-form(ref="form" @submit.prevent="submit")
  v-card.discussion-form(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" :title="cardTitle")
    template(v-slot:append)
      dismiss-modal-button(
        v-if="!isPage"
        aria-hidden='true'
        :model="discussion")
      v-btn(
        v-if="isPage && discussion.id"
        icon
        variant="text"
        aria-hidden='true'
        :to="urlFor(discussion)"
      )
        common-icon(name="mdi-close")
      v-btn.back-button(variant="text" v-if="isPage && $route.query.return_to" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
        common-icon(name="mdi-close")

    v-card-item
      thread-template-help-panel.mb-8(v-if="discussionTemplate" :discussion-template="discussionTemplate")
      v-select.pb-4(
        :disabled="!!discussion.id"
        v-model="discussion.groupId"
        :items="groupItems"
        :label="$t('common.group')"
        persistent-hint
      )
      //- :hint="discussion.groupId ? $t('announcement.form.visible_to_group', {group: discussion.group().name}) : $t('announcement.form.visible_to_guests')"

      div(v-if="showUpgradeMessage")
        p(v-if="maxThreadsReached" v-html="$t('discussion.max_threads_reached', {upgradeUrl: upgradeUrl, maxThreads: maxThreads})")
        p(v-if="!subscriptionActive" v-html="$t('discussion.subscription_canceled', {upgradeUrl: upgradeUrl})")

      .discussion-form__group-selected(v-if='!showUpgradeMessage')
        v-text-field#discussion-title.discussion-form__title-input(
          :label="$t('discussion_form.title_label')"
          :placeholder="titlePlaceholder"
          :rules="validate('title')"
          v-model='discussion.title' maxlength='255'
        )

        tags-field(:model="discussion")

        lmo-textarea(
          :model='discussion'
          field="description"
          :label="$t('discussion_form.context_label')"
          :placeholder="$t('discussion_form.context_placeholder')"
          :shouldReset="shouldReset"
        )

        common-notify-fields(v-if="loaded" :model="discussion" :initial-recipients="initialRecipients")
    v-card-actions
      help-btn(path='en/user_manual/threads/starting_threads')
      v-btn.discussion-form__edit-layout(v-if="discussion.id" @click="openEditLayout")
        span(v-t="'thread_arrangement_form.edit'")
      v-spacer
      v-btn.mr-2(@click="discardDraft" variant="text")
        span(v-t="'common.reset'")
      v-btn.discussion-form__submit(
        variant="elevated"
        color="primary"
        @click="submit()"
        :disabled="submitIsDisabled"
        :loading="discussion.processing"
      )
        span(v-if="!discussion.id" v-t="'discussion_form.start_thread'")
        span(v-if="discussion.id" v-t="'common.action.save'")
</template>
