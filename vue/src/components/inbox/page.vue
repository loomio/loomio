<script lang="js">
import AppConfig     from '@/shared/services/app_config';
import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import EventBus      from '@/shared/services/event_bus';
import ThreadFilter from '@/shared/services/thread_filter';
import ThreadPreviewCollection from '@/components/thread/preview_collection';
import {sum, values, sortBy} from 'lodash-es';

export default
{
  components: {
    ThreadPreviewCollection
  },

  data() {
    return {
      threadLimit: 50,
      views: {},
      groups: [],
      loading: false,
      unreadCount: 0,
      filters: [
        'only_threads_in_my_groups',
        'show_unread',
        'show_recent',
        'hide_muted',
        'hide_dismissed'
      ]
    };
  },

  created() {
    this.init();
    EventBus.$on('signedIn', () => this.init());
  },

  methods: {
    startGroup() {
      EventBus.$emit('openModal', {
        component: 'GroupNewForm',
        props: { group: Records.groups.build() }
      });
    },

    init(options) {
      if (options == null) { options = {}; }
      if (Session.isSignedIn()) {
        this.loading = true;
        Records.discussions.fetchInbox(options).then(() => { return this.loading = false; });
      }

      EventBus.$emit('currentComponent', {
        titleKey: 'inbox_page.unread_threads',
        page: 'inboxPage'
      }
      );

      this.watchRecords({
        collections: ['discussions', 'groups'],
        query: store => {
          this.groups = sortBy(Session.user().inboxGroups(), 'name');
          this.views = {};
          this.groups.forEach(group => {
            this.views[group.key] = ThreadFilter({filters: this.filters, group});
          });
          this.unreadCount = sum(values(this.views), v => v.length);
        }
      });
    }
  }
};

</script>

<template>

<v-main>
  <v-container class="inbox-page thread-preview-collection__container max-width-1024 px-0 px-sm-3" grid-list-lg="grid-list-lg">
    <h1 class="display-1 my-4" tabindex="-1" v-observe-visibility="{callback: titleVisible}" v-t="'inbox_page.unread_threads'"></h1>
    <section class="dashboard-page__loading" v-if="unreadCount == 0 && loading" aria-hidden="true">
      <div class="thread-previews-container">
        <loading-content class="thread-preview" :lineCount="2" v-for="(item, index) in [1,2,3,4,5,6,7,8,9,10]" :key="index"></loading-content>
      </div>
    </section>
    <section class="inbox-page__threads" v-if="unreadCount > 0 || !loading">
      <div class="inbox-page__no-threads" v-show="unreadCount == 0"><span v-t="'inbox_page.no_threads'"></span><span>🙌</span></div>
      <div class="inbox-page__no-groups" v-show="groups.length == 0">
        <p v-t="'inbox_page.no_groups.explanation'"></p>
        <button class="lmo-btn-link--blue" v-t="'inbox_page.no_groups.start'" @click="startGroup()"></button>&nbsp;<span v-t="'inbox_page.no_groups.or'"></span>&nbsp;<span v-html="$t('inbox_page.no_groups.join_group')"></span>
      </div>
      <div class="inbox-page__group" v-for="group in groups" :key="group.id">
        <v-card class="mb-3" v-if="views[group.key].length > 0">
          <v-card-title>
            <group-avatar class="mr-2" :group="group" :size="40"></group-avatar>
            <router-link class="inbox-page__group-name" :to="'/g/' + group.key"><span class="subheading">{{group.name}}</span></router-link>
          </v-card-title>
          <thread-preview-collection :threads="views[group.key]" :limit="threadLimit"></thread-preview-collection>
        </v-card>
      </div>
    </section>
  </v-container>
</v-main>
</template>
