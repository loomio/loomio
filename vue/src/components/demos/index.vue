<script lang="js">
import AuthModalMixin      from '@/mixins/auth_modal';
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import EventBus           from '@/shared/services/event_bus';
import Flash              from '@/shared/services/flash';
import AbilityService     from '@/shared/services/ability_service';
import RecordLoader       from '@/shared/services/record_loader';
import PlausibleService from '@/shared/services/plausible_service';

export default 
{
  mixins: [ AuthModalMixin ],
  data() {
    return {
      templates: [],
      loaded: false,
      processing: false,
      trials: AppConfig.features.app.trials
    };
  },

  mounted() {
    EventBus.$emit('content-title-visible', false);
    EventBus.$emit('currentComponent', {
      titleKey: 'templates.try_loomio',
      page: 'threadsPage',
      search: {
        placeholder: this.$t('navbar.search_all_threads')
      }
    }
    );
  },

  watch: {
    '$route.query': 'refresh'
  },

  methods: {
    startDemo() {
      if (Session.isSignedIn()) {
        this.cloneTemplate();
      } else {
        this.openAuthModal();
      }
    },

    cloneTemplate() {
      PlausibleService.trackEvent('start_demo');
      Flash.wait('templates.generating_demo');
      this.processing = true;
      Records.post({path: 'demos/clone'}).then(data => {
          Flash.success('templates.demo_created');
          this.$router.push(this.urlFor(Records.groups.find(data.groups[0].id)));
        }).finally(() => {
          this.processing = false;
      });
    }
  }
};

</script>

<template>

<v-main>
  <v-container class="templates-page max-width-1024 px-0 px-sm-3">
    <h1 class="display-1 my-4" tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'templates.try_loomio'"></h1>
    <div class="d-flex justify-center"><iframe class="mx-auto" width="560" height="315" src="https://www.youtube-nocookie.com/embed/oIEKA9WTIDc" title="Loomio demo group introduction" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture;" allowfullscreen></iframe></div>
    <v-overlay :value="processing"></v-overlay>
    <div class="d-flex justify-center mt-8">
      <div>
        <p class="text-center">
          <v-btn @click="startDemo()" v-t="'templates.start_demo'" color="primary"></v-btn>
        </p>
      </div>
    </div>
  </v-container>
</v-main>
</template>
