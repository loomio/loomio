<script setup lang="js">
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import DiscussionService from '@/shared/services/discussion_service';
import { compact } from 'lodash-es';
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { I18n } from '@/i18n';
import LmoUrlService from '@/shared/services/lmo_url_service';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import DiscussionTemplateHelpPanel from '@/components/discussion_template/help_panel';
import { useWatchRecords } from '@/composables/useWatchRecords';

const props = defineProps({
  discussion: Object,
  isPage: Boolean,
  user: Object
});

const router = useRouter();
const route = useRoute();

// url_for mixin functionality
const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

// watch_records composable
const { watchRecords } = useWatchRecords();

// Template refs
const form = ref(null);

// Data
const tab = ref(0);
const upgradeUrl = AppConfig.baseUrl + 'upgrade';
const submitIsDisabled = ref(false);
const searchResults = ref([]);
const subscription = ref(props.discussion.group().parentOrSelf().subscription);
const groupItems = ref([]);
const initialRecipients = ref([]);
const discussionTemplate = ref(null);
const loaded = ref(false);

// Methods
const validate = (field) => {
  return [ () => props.discussion.errors[field] === undefined || props.discussion.errors[field][0] ];
};

const discardDraft = () => {
  if (confirm(I18n.global.t('formatting.confirm_discard'))) {
    EventBus.$emit('resetDraft', 'discussion', props.discussion.id, 'description', props.discussion.description);
  }
};

const updateGroupItems = () => {
  groupItems.value = [{title: I18n.global.t('discussion_form.none_direct_discussion'), value: null}].concat(Session.user().groups().map(g => ({
    title: g.fullName,
    value: g.id
  })));
};

const submit = () => {
  const actionName = props.discussion.id ? 'updated' : 'started';
  props.discussion.setErrors();
  form.value.resetValidation();
  props.discussion.save().then(data => {
    EventBus.$emit('deleteDraft', 'discussion', props.discussion.id, 'description');

    const discussionKey = data.discussions[0].key;
    Records.discussions.findOrFetchById(discussionKey, {}, true).then(discussion => {
      Flash.success(`discussion_form.discussion_${actionName}`);
      router.push(urlFor(discussion));
    });
  }).catch(error => {
    form.value.validate();
    Flash.serverError(error, ['title']);
  });
};

const openEditLayout = () => {
  return DiscussionService.actions(props.discussion, null)['edit_arrangement'].perform();
};

// Computed
const cardTitle = computed(() => {
  if (isMovingItems.value) {
    return I18n.global.t('discussion_form.moving_items_title');
  } else {
    if (props.discussion.id) {
      return I18n.global.t('discussion_form.edit_discussion_title');
    } else {
      return I18n.global.t('discussion_form.new_discussion_title');
    }
  }
});

const titlePlaceholder = computed(() => {
  if (discussionTemplate.value && discussionTemplate.value.titlePlaceholder) {
    return I18n.global.t('common.prefix_eg', {val: discussionTemplate.value.titlePlaceholder});
  } else {
    return I18n.global.t('discussion_form.title_placeholder');
  }
});

const maxThreads = computed(() => {
  return subscription.value.max_threads;
});

const threadCount = computed(() => {
  return props.discussion.group().parentOrSelf().orgDiscussionsCount;
});

const maxThreadsReached = computed(() => {
  return maxThreads.value && (threadCount.value >= maxThreads.value);
});

const subscriptionActive = computed(() => {
  return subscription.value.active;
});

const canStartThread = computed(() => {
  return subscriptionActive.value && !maxThreadsReached.value;
});

const showUpgradeMessage = computed(() => {
  return !props.discussion.id && !canStartThread.value;
});

const isMovingItems = computed(() => {
  return props.discussion.forkedEventIds.length;
});

// Watcher
watch(() => props.discussion.groupId, (groupId) => {
  subscription.value = props.discussion.group().parentOrSelf().subscription;
  const users = compact([props.user]).map(u => ({
    id: u.id,
    type: 'user',
    name: u.nameOrEmail(),
    user: u
  }));
  initialRecipients.value = [];
  initialRecipients.value = initialRecipients.value.concat(users);
  props.discussion.private = props.discussion.privateDefaultValue();
}, { immediate: true });

// Mounted
onMounted(() => {
  Records.users.findOrFetchGroups().then(() => {
    const templatePromise = props.discussion.discussionTemplateId
      ? Records.discussionTemplates.findOrFetchById(props.discussion.discussionTemplateId)
      : props.discussion.discussionTemplateKey
        ? Records.discussionTemplates.findOrFetchByKey(props.discussion.discussionTemplateKey, props.discussion.groupId)
        : null;

    if (templatePromise) {
      templatePromise.then(template => {
        discussionTemplate.value = template;
        if ( props.discussion.isNew() &&
             (template.recipientAudience === 'group') &&
             props.discussion.groupId &&
             AbilityService.canAnnounceDiscussion(props.discussion) )
        {
          initialRecipients.value = [{
            type: 'audience',
            id: 'group',
            icon: 'mdi-account-group',
            name: I18n.global.t('announcement.audiences.group', {name: props.discussion.group().name}),
            size: props.discussion.group().acceptedMembershipsCount
          }];
        }
      })
      .finally(() => { loaded.value = true; });
    } else {
      loaded.value = true;
    }
  });

  watchRecords({
    collections: ['groups', 'memberships'],
    query: records => { updateGroupItems(); }
  });
});
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
      discussion-template-help-panel.mb-8(v-if="discussionTemplate" :discussion-template="discussionTemplate")
      v-select.pb-4(
        :disabled="!!discussion.id"
        v-model="discussion.groupId"
        :items="groupItems"
        :label="$t('common.group')"
        persistent-hint
      )
      //- :hint="discussion.groupId ? $t('announcement.form.visible_to_group', {group: discussion.group().name}) : $t('announcement.form.visible_to_guests')"
      v-alert.mb-4(v-if="!discussion.groupId && !discussionTemplate && !discussion.id" type="info" variant="tonal" density="compact") {{ $t('discussion_form.direct_discussion_hint') }}

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
        )

        common-notify-fields(v-if="loaded" :model="discussion" :initial-recipients="initialRecipients")
    v-card-actions(v-if="!showUpgradeMessage")
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
        span(v-if="!discussion.id" v-t="'discussion_form.start_discussion'")
        span(v-if="discussion.id" v-t="'common.action.save'")
</template>
