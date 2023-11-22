<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Records   from '@/shared/services/records';
import EventBus  from '@/shared/services/event_bus';
import UrlFor    from '@/mixins/url_for';
import {truncate, map} from 'lodash-es';
import {marked}    from 'marked';

import { debounce, camelCase, orderBy } from 'lodash-es';

export default {
  mixins: [UrlFor],
  data() {
    return {
      groupIds: [],
      resultsCount: 0,
      perPage: 50,
      canLoadMoreGroups: true,
      query: "",
      searching: true,
      order: null,
      orderOptions: [
        {name: this.$t('explore_page.newest_first'), val: "created_at"},
        {name: this.$t('explore_page.biggest_first'), val: "memberships_count"}
      ]
    };
  },
  created() {
    if (this.$route.query.order) {
      this.order = this.$route.query.order;
    } else {
      this.$router.replace(this.mergeQuery({ order: "memberships_count" }));
    }
  },
  mounted() {
    EventBus.$emit('currentComponent', { titleKey: 'explore_page.header', page: 'explorePage'});
    this.search();
  },

  methods: {
    groups() {
      return Records.groups.find(this.groupIds);
    },

    handleSearchResults(response) {
      Records.groups.getExploreResultsCount(this.query).then(data => {
        return this.resultsCount = data.count;
      });
      this.groupIds = this.groupIds.concat(map(response.groups, 'id'));
      this.canLoadMoreGroups = (response.groups || []).length === this.perPage;
      this.searching = false;
    },

    search: debounce(function() {
      this.groupIds = [];
      Records.groups.fetchExploreGroups(this.query, {per: this.perPage, order: this.order}).then(this.handleSearchResults);
    }
    , 250),

    loadMore() {
      this.searching = true;
      Records.groups.fetchExploreGroups(this.query, {from: this.groupIds.length, per: this.perPage, order: this.order}).then(this.handleSearchResults);
    },

    groupCover(group) {
      return { 'background-image': `url(${group.coverUrl})` };
    },

    groupDescription(group) {
      let description = group.description || '';
      if (group.descriptionFormat === 'md') {
        description = marked(description);
      }
      const parser = new DOMParser();
      const doc = parser.parseFromString(description, 'text/html');
      return truncate(doc.body.textContent, {length: 100});
    },

    handleOrderChange(val) {
      this.$router.replace(this.mergeQuery({ order: val }));
    }
  },
  computed: {
    showMessage() {
      return !this.searching && (this.query.length > 0) && (this.groups().length > 0);
    },

    searchResultsMessage() {
      if (this.groups().length === 1) {
        return 'explore_page.single_search_result';
      } else {
        return 'explore_page.multiple_search_results';
      }
    },

    noResultsFound() {
      return !this.searching && (this.groups().length === 0);
    },

    orderedGroups() {
      return orderBy(this.groups(), [camelCase(this.order)], ['desc']);
    }
  },

  watch: {
    'query'() {
      this.searching = true;
      return this.search();
    },
    '$route.query.order': {
      immediate: true,
      handler() {
        this.order = this.$route.query.order;
        return this.search();
      }
    }
  }
};
</script>

<template>

<v-main>
  <v-container class="explore-page max-width-1024 px-0 px-sm-3">
    <v-text-field v-model="query" :placeholder="$t('explore_page.search_placeholder')" id="search-field" append-icon="mdi-magnify"></v-text-field>
    <v-select @change="handleOrderChange" :items="orderOptions" item-value="val" item-text="name" :placeholder="$t('explore_page.order_by')" :value="order"></v-select>
    <loading :until="!searching"></loading>
    <div class="explore-page__no-results-found" v-show="noResultsFound" v-html="$t('explore_page.no_results_found')"></div>
    <div class="explore-page__search-results" v-show="showMessage" v-html="$t(searchResultsMessage, {resultCount: resultsCount, searchTerm: query})"></div>
    <v-row class="explore-page__groups my-4" v-show="!searching" wrap="wrap">
      <v-col :lg="6" :md="6" :sm="12" v-for="group in orderedGroups" :key="group.id">
        <v-card class="explore-page__group my-4" :to="urlFor(group)">
          <v-img class="explore-page__group-cover" :src="group.coverUrl" max-height="120"></v-img>
          <v-card-title>{{ group.name }}</v-card-title>
          <v-card-text>
            <div class="explore-page__group-description">{{groupDescription(group)}}</div>
            <v-layout class="explore-page__group-stats" justify-start="justify-start" align-center="align-center">
              <common-icon class="mr-2" name="mdi-account-multiple"></common-icon><span class="mr-4">{{group.membershipsCount}}</span>
              <common-icon class="mr-2" name="mdi-comment-text-outline"></common-icon><span class="mr-4">{{group.discussionsCount}}</span>
              <common-icon class="mr-2" name="mdi-thumbs-up-down"></common-icon><span class="mr-4">{{group.pollsCount}}</span>
            </v-layout>
          </v-card-text>
        </v-card>
      </v-col>
      <div class="lmo-show-more" v-show="canLoadMoreGroups">
        <v-btn class="explore-page__show-more" v-show="!searching" @click="loadMore()" v-t="'common.action.show_more'"></v-btn>
      </div>
    </v-row>
  </v-container>
</v-main>
</template>
