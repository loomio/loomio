<script lang="js">
import Records from '@/shared/services/records';
import {map, debounce, filter, uniq, uniqBy, find, difference, escapeRegExp} from 'lodash-es';
import AbilityService from '@/shared/services/ability_service';
import NotificationsCount from './notifications_count';
import Session from '@/shared/services/session';

export default {
  components: {
    NotificationsCount
  },

  props: {
    defaultGroup: false,
    label: String,
    placeholder: String,
    hint: String,
    reset: Boolean,
    model: Object,
    existingOnly: Boolean,
    includeActor: Boolean,
    excludeMembers: Boolean,
    hideCount: Boolean,
    excludedAudiences: {
      type: Array,
      default() { return []; }
    },
    excludedUserIds: {
      type: Array,
      default() { return []; }
    },
    initialRecipients: {
      type: Array,
      default() { return []; }
    }
  },

  data() {
    return {
      query: '',
      suggestedUserIds: [],
      suggestions: [],
      availableAudiences: [],
      recipients: [],
      loading: false,
      currentUserId: Session.user().id
    };
  },

  mounted() {
    this.recipients = this.initialRecipients;
    this.fetchChatbots();
    this.fetchAvailableAudiences();
    this.fetchAndUpdateSuggestions();
  },

  watch: {
    'model.groupId'(groupId) {
      this.suggestedUserIds = [];
      this.newRecipients(this.initialRecipients);
      this.fetchChatbots();
      this.fetchAvailableAudiences();
      this.fetchAndUpdateSuggestions();
    },

    reset() {
      this.query = '';
      this.recipients = this.initialRecipients;
      this.fetchAndUpdateSuggestions();
    },

    recipients(val) {
      this.newRecipients(val);
      this.$emit('new-recipients', val);
      this.updateSuggestions();
    },

  },

  methods: {
    updateQuery(q) {
      this.query = q
      this.fetchAndUpdateSuggestions();
    },
    fetchChatbots() {
      if (!this.model.groupId) { return; }
      Records.fetch({
        path: 'chatbots',
        params: {
          group_id: this.model.groupId
        }}).then(data => {
          this.updateSuggestions();
      });
    },

    fetchSuggestions: debounce(function() {
      if (!this.query) { return; }
      const existingOnly = (this.existingOnly && {existing_only: 1}) || {};
      this.loading = true;
      Records.fetch({
        path: 'announcements/search',
        params: {
          exclude_types: 'group inviter',
          q: this.query,
          per: 20,
          include_actor: (this.includeActor && 1) || null,
          ...existingOnly,
          ...this.model.bestNamedId()
        }})
      .then(data => {
        this.suggestedUserIds = uniq(this.suggestedUserIds.concat(data['users'].map(u => u.id)));
        this.updateSuggestions();
    }).finally(() => {
        this.loading = false;
      });
    }
    , 500),

    fetchAndUpdateSuggestions() {
      this.fetchSuggestions();
      this.updateSuggestions();
    },

    fetchAvailableAudiences() {
      Records.fetch({
        path: 'announcements/available_audiences',
        params: {
          include_actor: (this.includeActor && 1) || null,
          ...this.model.bestNamedId()
        }
      }).then(data => {
        this.availableAudiences = data.audiences || [];
        this.updateSuggestions();
      });
    },

    newRecipients(val) {
      this.model.recipientAudience = (find(val, o => o.type === 'audience') || {}).id;
      this.model.recipientUserIds = map(filter(val, o => o.type === 'user'), 'id');
      this.model.recipientEmails = map(filter(val, o => o.type === 'email'), 'name');
      this.model.recipientChatbotIds = map(filter(val, o => o.type === 'chatbot'), 'id');
    },

    findUsers() {
      if (!this.query) { return []; }
      let chain = Records.users.collection.chain();

      chain = chain.find({id: {$in: difference(this.suggestedUserIds, this.excludedUserIds)}});

      chain = chain.find({
        $or: [
          {name: {'$regex': [`^${escapeRegExp(this.query)}`, "i"]}},
          {username: {'$regex': [`^${escapeRegExp(this.query)}`, "i"]}},
          {name: {'$regex': [` ${escapeRegExp(this.query)}`, "i"]}}
        ]});

      return chain.data();
    },

    expand(item) {
      const excludeMembers = (this.excludeMembers && {exclude_members: 1}) || {};
      Records.fetch({
        path: 'announcements/audience',
        params: {
          recipient_audience: item.id,
          include_actor: (this.includeActor && 1) || null,
          ...excludeMembers,
          ...this.model.bestNamedId()
        }})
      .then(data => {
        this.remove(item);
        const userIds = (data['users'] || []).map(u => u.id);
        this.suggestedUserIds = uniq(this.suggestedUserIds.concat(userIds));
        Records.users.find(userIds).forEach(u => {
          this.recipients.push({
            id: u.id,
            type: 'user',
            name: u.nameOrEmail(),
            user: u
          });
        });
      });
    },

    remove(item) {
      this.recipients = filter(this.recipients, r => !((r.id === item.id) && (r.type === item.type)));
    },

    emailToRecipient(email) {
      return {
        id: email,
        type: 'email',
        icon: 'mdi-email-outline',
        name: email
      };
    },

    audienceName(audience) {
      switch (audience.kind) {
        case 'group':
          return this.$t('announcement.audiences.group', {name: audience.name});
        case 'delegates':
          return this.$t('announcement.audiences.delegates_of_group', {name: audience.name});
        case 'discussion_group':
          return this.$t('announcement.audiences.discussion_group');
        case 'voters':
          return this.$t('announcement.audiences.voters');
        case 'decided_voters':
          return this.$t('announcement.audiences.decided_voters');
        case 'undecided_voters':
          return this.$t('announcement.audiences.undecided_voters');
      }
    },

    updateSuggestions() {
      if (this.query && this.canAddGuests) {
        // seems like a problem with vuteify when query begins with a space
        if (this.query.trimStart().length < this.query.length){
          this.query = this.query.trimStart();
          return;
        }

        const emails = uniq(this.query.match(/[^\s:,;"`<>]+?@[^\s:,;"`<>]+\.[^\s:,;"`<>]+/g) || []);

        // catch paste of multiple email addresses, or failure to press enter after an email address
        if ((emails.length > 1) || ((emails.length === 1) && [',', ' '].includes(this.query.slice(-1)))) {
          const objs = uniqBy(this.recipients.concat(emails.map(this.emailToRecipient)), 'id');
          this.recipients = objs;
          this.suggestions = objs;
          this.query = '';
          return
        } else if (emails.length === 1) {
          this.suggestions = this.recipients.concat(emails.map(this.emailToRecipient));
          return
        }
      }

      const members = this.findUsers().map(u => ({
        id: u.id,
        type: 'user',
        name: u.nameOrEmail(),
        user: u
      }));

      const audiences = this.audiences.map(a => ({
        id: a.id,
        type: 'audience',
        icon: 'mdi-account-group',
        name: a.name,
        size: a.size
      }));

      const chatbots = this.model.group().chatbots().map(b => ({
        id: b.id,
        type: 'chatbot',
        icon: 'mdi-robot',
        name: b.name
      }));

      this.suggestions = this.recipients.concat(chatbots).concat(audiences).concat(members);
    }
  },

  computed: {
    canAnnounceDiscussion() { return AbilityService.canAnnounceDiscussion(this.model) },
    canAddGuests() { return AbilityService.canAddGuests(this.model); },
    canNotifyGroup() { return AbilityService.canAnnounce(this.model); },
    modelName() { return this.model.constructor.singular; },

    audiences() {
      if (this.recipients.length > 0) { return []; }

      return this.availableAudiences.map(audience => ({
        id: audience.id,
        type: 'audience',
        icon: 'mdi-account-group',
        name: this.audienceName(audience),
        size: audience.size
      })).filter(a => {
        return !this.excludedAudiences.includes(a.id) &&
        ((this.query && a.name.match(new RegExp(escapeRegExp(this.query), 'i'))) || true);
      });
    }
  }
}

</script>

<template lang="pug">
div.recipients-autocomplete
  v-autocomplete.announcement-form__input(
    :disabled="model.isA('discussion') && !canAnnounceDiscussion"
    multiple
    return-object
    hide-selected
    hide-no-data
    auto-select-first
    clear-on-select
    v-model='recipients'
    @update:search="updateQuery"
    item-title='name'
    item-value='id'
    :loading="loading"
    :label="label"
    :placeholder="placeholder"
    :items='suggestions'
    autocomplete='off'
  )
    template(v-slot:no-data)
      v-list-item
        template(v-slot:prepend)
          common-icon(v-if="!query" name="mdi-account-search")
          common-icon(v-if="query" name="mdi-information-outline")
        v-list-item-title
          span(v-if="query" v-t="'common.no_results_found'")
          span(v-else)
            span(v-if="canAddGuests" v-t="'announcement.search_by_name_or_email'")
            span(v-if="!canAddGuests" v-t="'announcement.search_by_name'")
        v-list-item-subtitle
          span(v-if="!canAddGuests && !canNotifyGroup"
               v-t="'announcement.only_admins_can_announce_or_invite'")
          span(v-if="!canAddGuests && canNotifyGroup"
               v-t="'announcement.only_admins_can_invite'")
          span(v-if="canAddGuests && !canNotifyGroup"
               v-t="'announcement.only_admins_can_announce'")
    template(v-slot:chip='{ props, internalItem }')
      v-chip.chip--select-multi(
        v-if="internalItem.raw.type =='audience'"
        v-bind="props"
        :value='internalItem.selected'
        closable
        @click:close='remove(internalItem.raw)'
        @click='expand(internalItem.raw)')
        span
          common-icon.mr-1(color="info" :name="internalItem.raw.icon")
        span {{ internalItem.title }}
      v-chip.chip--select-multi(
        v-else
        v-bind="props"
        :value='internalItem.selected'
        closable
        @click:close='remove(internalItem.raw)')
        span
          user-avatar.mr-2(
            v-if="internalItem.raw.type == 'user'"
            :user="internalItem.raw.user"
            :size="24" no-link)
          common-icon.mr-2(v-else size="small" :name="internalItem.raw.icon")
        span {{ internalItem.title }}
        span(v-if="internalItem.raw.type == 'user' && currentUserId == internalItem.value")
          space
          span ({{ $t('common.you') }})
    template(v-slot:item='{props, internalItem}')
      v-list-item.recipients-autocomplete-suggestion(v-bind="props" lines="two")
        template(v-slot:prepend)
          user-avatar.mr-2(v-if="internalItem.raw.type == 'user'" :user="internalItem.raw.user" no-link)
          common-icon.mr-2(v-else size="small" :name="internalItem.raw.icon")
        //- v-list-item-title
        //-   span {{props}}
        //-   span {{internalItem.raw.name}}
        //-   span(v-if="internalItem.raw.type == 'user' && currentUserId == internalItem.raw.id")
        //-     space
        //-     span ({{ $t('common.you') }})
        v-list-item-subtitle(v-if="internalItem.raw.user && internalItem.raw.user.email && (internalItem.raw.user.email != internalItem.raw.user.name)")
          span {{internalItem.raw.user.email}}
  notifications-count(
    v-show="!hideCount && recipients.length"
    :model='model'
    :exclude-members="excludeMembers"
    :include-actor="includeActor")
</template>
