<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import { compact } from 'lodash-es';

export default {
  data() {
    return {
      templates: [],
      actions: {},
      group: null,
      returnTo: Session.returnTo(),
      isSorting: false,
      showSettings: false
    };
  },

  mounted() {
    Records.discussionTemplates.fetch({
      params: {
        group_id: this.$route.query.group_id,
        per: 50
      }
    });

    this.watchRecords({
      key: `discussionTemplates${this.$route.query.group_id}`,
      collections: ['discussionTemplates'],
      query: () => this.query()
    });

    EventBus.$on('sortThreadTemplates', () => { return this.isSorting = true; });
  },

  methods: {
    sortEnded() {
      this.isSorting = false;
      setTimeout(() => {
        const ids = this.templates.map(p => p.id || p.key);
        Records.remote.post('discussion_templates/positions', {group_id: this.group.id, ids});
      });
    },

    query() {
      this.group = Records.groups.findById(parseInt(this.$route.query.group_id));
      this.templates = Records.discussionTemplates.collection.chain().find({
        groupId: parseInt(this.$route.query.group_id),
        discardedAt: (this.showSettings && {$ne: null}) || null
      }).simplesort('position').data();

      if (this.group) {
        this.actions = {};
        this.templates.forEach((template, i) => {
          this.actions[i] = DiscussionTemplateService.actions(template, this.group);
        });
      }
    }
  },

  computed: {
    userIsAdmin() {
      return this.group && this.group.adminsInclude(Session.user());
    },

    breadcrumbs() {
      if (!this.group) { return []; }
      return compact([this.group.parentId && this.group.parent(), this.group]).map(g => {
        return {
          text: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    }
  },
  watch: {
    '$route.query': 'query',
    'showSettings': 'query'
  }
};
</script>
<template>

<div class="thread-templates-page">
  <v-main>
    <v-container class="max-width-800 px-0 px-sm-3">
      <div class="d-flex">
        <v-breadcrumbs class="px-4" :items="breadcrumbs">
          <template v-slot:divider="v-slot:divider">
            <common-icon name="mdi-chevron-right"></common-icon>
          </template>
        </v-breadcrumbs>
      </div>
      <v-card>
        <v-card-title class="d-flex pr-3">
          <h1 class="headline" v-if="!showSettings" tabindex="-1" v-t="'thread_template.start_a_new_thread'"></h1>
          <h1 class="headline" v-if="showSettings" tabindex="-1" v-t="'thread_template.hidden_templates'"></h1>
          <v-spacer></v-spacer>
          <v-btn v-if="showSettings" icon="icon" @click="showSettings = false">
            <common-icon name="mdi-close"></common-icon>
          </v-btn>
        </v-card-title>
        <v-alert class="mx-4" v-if="!showSettings && group && group.discussionsCount < 2" type="info" text="text" outlined="outlined" v-t="'thread_template.these_are_templates'"> </v-alert>
        <v-list class="append-sort-here" two-line="two-line">
          <div class="d-flex">
            <v-subheader v-if="!showSettings" v-t="'templates.templates'"></v-subheader>
            <v-spacer></v-spacer>
            <div class="mr-3" v-if="userIsAdmin">
              <v-menu v-if="!showSettings" offset-y="offset-y">
                <template v-slot:activator="{on, attrs}">
                  <v-btn icon="icon" v-bind="attrs" v-on="on" :title="$t('common.admin_menu')">
                    <common-icon name="mdi-cog"></common-icon>
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item :to="'/thread_templates/new?group_id='+$route.query.group_id+'&return_to='+returnTo">
                    <v-list-item-title v-t="'discussion_form.new_template'"></v-list-item-title>
                  </v-list-item>
                  <v-list-item @click="showSettings = true">
                    <v-list-item-title v-t="'thread_template.hidden_templates'"></v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </div>
          </div>
          <template v-if="isSorting">
            <sortable-list v-model="templates" @sort-end="sortEnded" append-to=".append-sort-here" lock-axis="y" axis="y">
              <sortable-item v-for="(template, index) in templates" :index="index" :key="template.id || template.key">
                <v-list-item :key="template.id">
                  <v-list-item-content>
                    <v-list-item-title>{{template.processName || template.title}}</v-list-item-title>
                    <v-list-item-subtitle>{{template.processSubtitle}}</v-list-item-subtitle>
                  </v-list-item-content>
                  <v-list-item-action class="handle" style="cursor: grab">
                    <common-icon name="mdi-drag-vertical"></common-icon>
                  </v-list-item-action>
                </v-list-item>
              </sortable-item>
            </sortable-list>
          </template>
          <template v-if="!isSorting">
            <v-list-item class="thread-templates--template" v-for="(template, i) in templates" :key="template.id" :to="'/d/new?' + (template.id ? 'template_id='+template.id : 'template_key='+template.key)+ '&group_id='+ $route.query.group_id + '&return_to='+returnTo">
              <v-list-item-content>
                <v-list-item-title>{{template.processName || template.title}}</v-list-item-title>
                <v-list-item-subtitle>{{template.processSubtitle}}</v-list-item-subtitle>
              </v-list-item-content>
              <v-list-item-action>
                <action-menu :actions="actions[i]" small="small" icon="icon" :name="$t('action_dock.more_actions')"></action-menu>
              </v-list-item-action>
            </v-list-item>
          </template>
        </v-list>
      </v-card>
      <div class="d-flex justify-center my-2" v-if="!showSettings && userIsAdmin">
        <v-btn :to="'/thread_templates/browse?group_id=' + $route.query.group_id + '&return_to='+returnTo"><span v-t="'thread_template.browse_public_templates'"></span></v-btn>
      </div>
    </v-container>
  </v-main>
</div>
</template>
