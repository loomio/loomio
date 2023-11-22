<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';

import { isEmpty }     from 'lodash-es';
import { approximate } from '@/shared/helpers/format_time';

export default {
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
    EventBus.$emit('currentComponent', {page: 'userPage'});
    Records.users.findOrFetchById(this.$route.params.key).then(this.init, error => EventBus.$emit('pageError', error));
  },

  methods: {
    approximate,
    init() {
      if (this.user = (Records.users.find(this.$route.params.key) || Records.users.find({username: this.$route.params.key}))[0]) {
        Records.remote.get('profile/contactable', {user_id: this.user.id}).then(() => {
          this.canContactUser = true;
        });
        EventBus.$emit('currentComponent', {title: this.user.name, page: 'userPage'});
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

<template>

<v-main class="user-page__profile">
  <v-container class="user-page max-width-800 mt-4 px-0 px-sm-3">
    <loading v-if="isEmptyUser"></loading>
    <div class="user-page__content" v-else>
      <v-card>
        <v-card-title>
          <v-layout class="align-center justify-center">
            <h1 class="headline">{{user.name}}</h1>
          </v-layout>
        </v-card-title>
        <v-card-text>
          <v-layout class="user-page__info mb-5 align-center justify-center" column="column">
            <user-avatar class="mb-5" :user="user" :size="192" :no-link="true"></user-avatar>
            <div class="text--secondary">@{{user.username}}</div>
            <formatted-text v-if="user" :model="user" column="shortBio"></formatted-text>
            <div v-t="{ path: 'user_page.locale_field', args: { value: user.localeName() } }" v-if="user.localeName()"></div><span><span v-t="'common.time_zone'"></span><span>: {{user.timeZone}}</span></span>
            <div v-t="{ path: 'user_page.location_field', args: { value: user.location } }" v-if="user.location"></div>
            <div v-t="{ path: 'user_page.online_field', args: { value: approximate(user.lastSeenAt) } }" v-if="user.lastSeenAt"></div>
            <v-btn class="my-4 user-page__contact-user" v-if="canContactUser" color="accent" outlined="outlined" :to="'/d/new?user_id=' + user.id" v-t="{ path: 'user_page.message_user', args: { name: user.firstName() } }"></v-btn>
          </v-layout>
        </v-card-text>
      </v-card>
      <v-card class="mt-4 user-page__groups">
        <v-card-text>
          <h3 class="lmo-h3 user-page__groups-title" v-t="'common.groups'"></h3>
          <v-list dense="dense">
            <v-list-item class="user-page__group" v-for="group in groups" :key="group.id" :to="urlFor(group)">
              <v-list-item-avatar>
                <v-avatar class="mr-2" tile="tile" size="48"><img :src="group.logoUrl"/></v-avatar>
              </v-list-item-avatar>
              <v-list-item-title>{{group.fullName}}</v-list-item-title>
            </v-list-item>
          </v-list>
          <loading v-if="loadingGroupsForExecuting"></loading>
        </v-card-text>
      </v-card>
    </div>
  </v-container>
</v-main>
</template>
