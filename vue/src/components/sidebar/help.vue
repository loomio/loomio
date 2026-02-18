<script setup lang="js">
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';

import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';
import PlausibleService from '@/shared/services/plausible_service';
import LmoUrlService from '@/shared/services/lmo_url_service';

const router = useRouter();
const route = useRoute();

const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

const canStartDemo = computed(() => AppConfig.features.app.demos);
const showExploreGroups = computed(() => AppConfig.features.app.explore_public_groups);
const showHelp = computed(() => AppConfig.features.app.help_link);
const showContact = computed(() => AppConfig.features.app.show_contact);

const helpURL = computed(() => {
  const siteUrl = new URL(AppConfig.baseUrl);
  return `https://help.loomio.com/en/?utm_source=${siteUrl.host}`;
});

const startOrFindDemo = () => {
  let group;
  if (group = Session.user().parentGroups().find(g => g.subscription.plan == 'demo')) {
    Flash.success('templates.login_to_start_demo');
    let url = urlFor(group);
    if (route.path != url) { router.replace(url); }
  } else {
    PlausibleService.trackEvent('start_demo');
    Flash.wait('templates.generating_demo');
    Records.post({path: 'demos/clone'}).then(data => {
      Flash.success('templates.demo_created');
      router.push(urlFor(Records.groups.find(data.groups[0].id)));
    })
  }
};
</script>

<template lang="pug">

v-list(nav lines="two")
  v-list-item(to="/explore" v-if="showExploreGroups" :title="$t('sidebar.find_a_group')")
    template(v-slot:append)
      common-icon(name="mdi-map-search")
  v-list-item.sidebar-start-demo(v-if="canStartDemo" @click="startOrFindDemo" lines="two" :title="$t('templates.start_a_demo')" :subtitle="$t('templates.play_with_an_example_group')")
    template(v-slot:append)
      common-icon(name="mdi-car-convertible")
  v-list-item(v-if="showHelp", :href="helpURL" target="_blank" lines="two" :title="$t('common.loomio_help')" :subtitle="$t('sidebar.a_detailed_guide_to_loomio')")
    template(v-slot:append)
      common-icon(name="mdi-book-open-page-variant")
  v-list-item(v-if="showContact" @click="$router.push('/contact')" lines="two" :title="$t('user_dropdown.contact_support')" :subtitle="$t('sidebar.talk_to_the_loomio_team')")
    template(v-slot:append)
      common-icon(name="mdi-face-agent")

</template>
