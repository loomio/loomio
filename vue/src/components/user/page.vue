<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';

import { isEmpty }     from 'lodash-es';
import { approximate } from '@/shared/helpers/format_time';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, UrlFor],
  data() {
    return {
      user: {},
      isMembershipsFetchingDone: false,
      groups: [],
      canContactUser: false,
      loadingGroupsForExecuting: false
    };
  },

  created() {
    this.init();
    Records.users.findOrFetchById(this.$route.params.key).then(this.init, error => EventBus.$emit('pageError', error));
  },

  methods: {
    approximate,
    init() {
      if (this.user = (Records.users.find(this.$route.params.key) || Records.users.find({username: this.$route.params.key}))[0]) {
        Records.remote.get('profile/contactable', {user_id: this.user.id}).then(() => {
          this.canContactUser = true;
        });
        // EventBus.$emit('currentComponent', {title: this.user.name, page: 'userPage'});
        this.loadGroupsFor(this.user);
        this.watchRecords({
          key: this.user.id,
          collections: ['groups', 'memberships'],
          query: store => {
            this.groups = this.user.groups();
          }
        });
      }
    },

    loadGroupsFor(user) {
      this.loadingGroupsForExecuting = true;
      Records.memberships.fetchByUser(user).then(() => {
        this.loadingGroupsForExecuting = false;
      });
    }
  },

  computed: {
    isEmptyUser() { return isEmpty(this.user); }
  }
};

</script>

<template lang="pug">
v-main.user-page__profile
  v-container.user-page.max-width-800.mt-4.px-0.px-sm-3
    loading(v-if='isEmptyUser')
    div(v-else).user-page__content
      v-card(:title="user.name")
        v-card-text
          .d-flex.flex-column.user-page__info.mb-5.align-center.justify-center
            user-avatar.mb-5(:user='user' :size='192' :no-link="true")
            .text-medium-emphasis @{{user.username}}
            formatted-text(v-if="user" :model="user" field="shortBio")
            div(v-t="{ path: 'user_page.locale_field', args: { value: user.localeName() } }", v-if='user.localeName()')
            span
              span(v-t="'common.time_zone'")
              span : {{user.timeZone}}
            div(v-t="{ path: 'user_page.location_field', args: { value: user.location } }", v-if='user.location')
            div(v-t="{ path: 'user_page.online_field', args: { value: approximate(user.lastSeenAt) } }", v-if='user.lastSeenAt')
            v-btn.my-4.user-page__contact-user(v-if="canContactUser" color="primary" variant="elevated" :to="'/d/new?user_id=' + user.id" v-t="{ path: 'user_page.message_user', args: { name: user.firstName() } }")
      v-card.mt-4.user-page__groups(:title="$t('common.groups')")
        v-card-text
          v-list
            v-list-item.user-page__group(v-for='group in groups' :key='group.id' :to='urlFor(group)')
              template(v-slot:prepend)
                group-avatar(:group="group")
              v-list-item-title {{group.fullName}}
          loading(v-if='loadingGroupsForExecuting')
</template>
