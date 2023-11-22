<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import utils         from '@/shared/record_store/utils';
import VuetifyColors  from 'vuetify/lib/util/colors';

const colors = Object.keys(VuetifyColors).filter(name => name !== 'shades').map(name => VuetifyColors[name]['base']);

export default {
  data() {
    return {
      results: [],
      query: this.$route.query.query,
      loading: false,
      tags: []
    };
  },

  mounted() {
    this.fetch();
    Records.remote.get('discussion_templates/browse_tags').then(data => {
      this.tags = data;
    });
  },

  methods: {
    changed() { return this.fetch(); },
    fetch() {
      this.loading = true;
      this.results = [];
      Records.remote.get('discussion_templates/browse', {query: this.query}).then(data => {
        this.results = data.results.map(utils.parseJSON);
        this.loading = false;
      });
    },

    tagColor(tag){
      return colors[this.tags.indexOf(tag) % colors.length];
    }
  }
};

</script>
<template>

<div class="thread-templates-page">
  <v-main>
    <v-container class="max-width-800 px-0 px-sm-3">
      <v-card>
        <v-card-title class="d-flex pr-3">
          <h1 class="headline" tabindex="-1" v-t="'templates.template_gallery'"></h1>
          <v-spacer></v-spacer>
          <v-btn class="back-button" v-if="$route.query.return_to" icon="icon" :aria-label="$t('common.action.cancel')" :to="$route.query.return_to">
            <common-icon name="mdi-close"></common-icon>
          </v-btn>
        </v-card-title>
        <v-alert class="mx-4" type="info" text="text" outlined="outlined" v-t="'thread_template.these_are_public_templates'"> </v-alert>
        <div class="d-flex px-4 align-center">
          <v-combobox :loading="loading" autofocus="autofocus" filled="filled" rounded="rounded" single-line="single-line" hide-selected="hide-selected" clearable="clearable" @change="changed" append-icon="mdi-magnify" @click:append="fetch" v-model="query" :placeholder="$t('common.action.search')" @keydown.enter.prevent="fetch" hide-details="hide-details" :items="tags"></v-combobox>
        </div>
        <v-list class="append-sort-here" three-line="three-line">
          <v-list-item v-for="result in results" :key="result.id" :to="'/d/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key)+ '&group_id='+ $route.query.group_id" title="Use this template to start a new thread">
            <v-list-item-avatar>
              <v-avatar :size="38" tile="tile"><img :alt="result.groupName || result.authorName" :src="result.avatarUrl"/></v-avatar>
            </v-list-item-avatar>
            <v-list-item-content>
              <v-list-item-title class="d-flex"><span>{{result.processName || result.title}}</span>
                <v-spacer></v-spacer>
                <v-chip class="ml-1" v-for="tag in result.tags" :key="tag" outlined="outlined" xSmall="xSmall" :color="tagColor(tag)">{{tag}}</v-chip>
              </v-list-item-title>
              <v-list-item-subtitle class="text--primary">{{result.processSubtitle}}</v-list-item-subtitle>
              <v-list-item-subtitle> <span><span>{{result.authorName}}</span>
                  <mid-dot></mid-dot><span>{{result.groupName}}</span></span></v-list-item-subtitle>
            </v-list-item-content>
            <v-list-item-action>
              <v-btn class="text--secondary" icon="icon" :to="'/thread_templates/new?template_id='+result.id+'&group_id='+$route.query.group_id" title="Make a copy of this template and edit it">
                <common-icon name="mdi-pencil"></common-icon>
              </v-btn>
            </v-list-item-action>
          </v-list-item>
        </v-list>
      </v-card>
    </v-container>
  </v-main>
</div>
</template>
