<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import { useRoute }                 from 'vue-router';
import Records                      from '@/shared/services/records';
import EventBus                     from '@/shared/services/event_bus';
import LmoUrlService                from '@/shared/services/lmo_url_service';
import { isEmpty }                  from 'lodash-es';
import { approximate }              from '@/shared/helpers/format_time';
import { useWatchRecords }          from '@/composables/useWatchRecords';

const route = useRoute();
const { watchRecords } = useWatchRecords();
const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

const user                      = ref({});
const isMembershipsFetchingDone = ref(false);
const groups                    = ref([]);
const canContactUser            = ref(false);
const loadingGroupsForExecuting = ref(false);

const isEmptyUser = computed(() => isEmpty(user.value));

function init() {
  user.value = (Records.users.find(route.params.key) || Records.users.find({username: route.params.key}))[0];
  if (user.value) {
    Records.remote.get('profile/contactable', {user_id: user.value.id}).then(() => {
      canContactUser.value = true;
    });
    loadGroupsFor(user.value);
    watchRecords({
      key: user.value.id,
      collections: ['groups', 'memberships'],
      query: () => {
        groups.value = user.value.groups();
      }
    });
  }
}

function loadGroupsFor(u) {
  loadingGroupsForExecuting.value = true;
  Records.memberships.fetchByUser(u).then(() => {
    loadingGroupsForExecuting.value = false;
  });
}

onMounted(() => {
  init();
  Records.users.findOrFetchById(route.params.key).then(init, error => EventBus.$emit('pageError', error));
});
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
