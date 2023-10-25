<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import AnnouncementService from '@/shared/services/announcement_service';
import {map, debounce, without, compact, filter, uniq, uniqBy, find, difference} from 'lodash';
import AbilityService from '@/shared/services/ability_service';
import NotificationsCount from './notifications_count';

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
      recipients: [],
      loading: false
    };
  },

  mounted() {
    this.recipients = this.initialRecipients;
    this.fetchChatbots();
    this.fetchAndUpdateSuggestions();
  },

  watch: {
    'model.groupId'(groupId) {
      this.suggestedUserIds = [];
      this.newRecipients(this.initialRecipients);
      this.fetchChatbots();
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

    query(q) {
      this.$emit('new-query', q);
      this.fetchAndUpdateSuggestions();
    }
  },

  methods: {
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
      chain = chain.find({emailVerified: true});

      chain = chain.find({
        $or: [
          {name: {'$regex': [`^${this.query}`, "i"]}},
          {username: {'$regex': [`^${this.query}`, "i"]}},
          {name: {'$regex': [` ${this.query}`, "i"]}}
        ]});

      return chain.data();
    },

    expand(item) {
      const excludeMembers = (this.excludeMembers && {exclude_members: 1}) || {};
      if (this.model.anonymous && ['decided_voters', 'undecided_voters'].includes(item.id)) {
        Flash.warning('announcement.cannot_reveal_when_anonymous');
        return false; 
      }
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

    updateSuggestions() {
      if (this.query && this.canAddGuests) {
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
    canAddGuests() { return AbilityService.canAddGuests(this.model); },
    canNotifyGroup() { return AbilityService.canAnnounce(this.model); },
    modelName() { return this.model.constructor.singular; },

    audiences() {
      let ret = [];
      if (this.recipients.length === 0) {
        AnnouncementService.audiencesFor(this.model).forEach(audience => {
          switch (audience) {
            case 'group':
              ret.push({
                id: 'group',
                name: this.$t('announcement.audiences.group', {name: this.model.group().name}),
                size: this.model.group().membershipsCount,
                icon: 'mdi-account-group'
              });
            case 'discussion_group':
              ret.push({
                id: 'discussion_group',
                name: this.$t('announcement.audiences.discussion_group'),
                size: this.model.discussion().membersCount,
                icon: 'mdi-forum'
              });
            case 'voters':
              ret.push({
                id: 'voters',
                name: this.$t('announcement.audiences.voters', {pollType: this.model.poll().translatedPollType()}),
                size: this.model.poll().votersCount,
                icon: 'mdi-forum'
              });
            case 'decided_voters':
              ret.push({
                id: 'decided_voters',
                name: this.$t('announcement.audiences.decided_voters'),
                size: this.model.poll().decidedVotersCount,
                icon: 'mdi-forum'
              });
            case 'undecided_voters':
              ret.push({
                id: 'undecided_voters',
                name: this.$t('announcement.audiences.undecided_voters'),
                size: this.model.poll().undecidedVotersCount,
                icon: 'mdi-forum'
              });
          }
        });

        if (!this.excludedAudiences.includes('group')) {
          const groups = (() => { switch (this.model.constructor.singular) {
            case 'poll': case 'discussion': case 'outcome':
              return compact([
                this.model.group(),
                (this.model.group().parentId && this.model.group().parent()),
              ].concat(
                without(this.model.group().parentOrSelf().subgroups(), this.model.group())
              )
              );
            default:
              return [];
          } })();

          groups.filter(AbilityService.canNotifyGroup).forEach(group => {
            if (group.membershipsCount) {
              return ret.push({
                id: `group-${group.id}`,
                name: this.$t('announcement.audiences.group', {name: group.name}),
                size: group.membershipsCount,
                icon: 'mdi-forum'
              });
            }
          });
        }
      }

      return ret.filter(a => {
        return !this.excludedAudiences.includes(a.id) &&
        ((this.query && a.name.match(new RegExp(this.query, 'i'))) || true);
      });
    }
  }
}

</script>

<template lang="pug">
div.recipients-autocomplete
  //- chips attribute is messing with e2es; no behaviour change noticed
  v-autocomplete.announcement-form__input(
    multiple
    return-object
    auto-select-first
    hide-selected
    v-model='recipients'
    @change="query = null"
    :search-input.sync="query"
    item-text='name'
    hide-no-data
    :loading="loading"
    :label="label"
    :placeholder="placeholder"
    :items='suggestions'
    )
    template(v-slot:no-data)
      v-list-item
        v-list-item-icon
          v-icon(v-if="!query") mdi-account-search
          v-icon(v-if="query") mdi-information-outline
        v-list-item-content
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
    template(v-slot:selection='data')
      v-chip.chip--select-multi(
        v-if="data.item.type =='audience'"
        :value='data.selected'
        close
        color='primary'
        @click:close='remove(data.item)'
        @click='expand(data.item)')
        span
          v-icon.mr-1(small) {{data.item.icon}}
        span {{ data.item.name }}
      v-chip.chip--select-multi(
        v-else
        :value='data.selected'
        close
        outlined
        color='primary'
        @click:close='remove(data.item)')
        span
          user-avatar.mr-1(
            v-if="data.item.type == 'user'"
            :user="data.item.user"
            :size="24" no-link)
          v-icon.mr-1(v-else small) {{data.item.icon}}
        span {{ data.item.name }}
        span(v-if="data.item.type == 'user' && currentUserId == data.item.id")
          space
          span ({{ $t('common.you') }})
    template(v-slot:item='data')
      v-list-item-avatar
        user-avatar(v-if="data.item.type == 'user'", :user="data.item.user", :size="24" no-link)
        v-icon.mr-1(v-else small) {{data.item.icon}}
      v-list-item-content.announcement-chip__content
        v-list-item-title
          span {{data.item.name}}
          span(v-if="data.item.type == 'user' && currentUserId == data.item.id")
            space
            span ({{ $t('common.you') }})
  notifications-count(
    v-show="recipients.length"
    :model='model'
    :exclude-members="excludeMembers"
    :include-actor="includeActor")
</template>
