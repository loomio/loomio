
<script lang="coffee">
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'vue/mixins/url_for'
truncate       = require 'vue/mixins/truncate'

module.exports =
  mixins: [urlFor, truncate]
  props:
    group: Object
  created: ->
    # Records.groups.fetchByParent(@group).then =>
    #   EventBus.broadcast $rootScope, 'subgroupsLoaded', @group
  methods:
    orderedSubgroups: ->
      _.sortBy @group.subgroups(), 'name'

    show: ->
      @group.isParent()

    canCreateSubgroups: ->
      AbilityService.canCreateSubgroups(@group)

    startSubgroup: ->
       ModalService.open 'GroupModal', group: => Records.groups.build(parentId: @group.id)
</script>

<template>
  <v-card aria-labelledby="subgroups-card__title" v-if="show()" class="subgroups-card mb-2">
    <v-card-text>
      <h2 v-t="'group_page.subgroups'" class="lmo-card-heading" id="subgroups-card__title"></h2>
      <p v-t="'group_page.subgroups_placeholder'" v-if="group.subgroups().length == 0" class="lmo-hint-text"></p>
      <ul class="subgroups-card__list">
        <li v-for="subgroup in orderedSubgroups()" :key="subgroup.id" class="subgroups-card__list-item">
          <div class="subgroups-card__list-item-logo">
            <!-- <group_avatar group="subgroup" size="medium"></group_avatar> -->
          </div>
          <div class="subgroups-card__list-item-name">
            <router-link :to="urlFor(subgroup)">{{ subgroup.name }}</router-link>
          </div>
          <div class="subgroups-card__list-item-description">{{ truncate(subgroup.description) }}</div>
        </li>
      </ul>
      <div class="lmo-flex lmo-flex__space-between"></div>
    </v-card-text>
    <v-card-actions>
      <!-- <outlet name="subgroup-card-footer"></outlet> -->
      <v-btn flat @click="startSubgroup()" v-if="canCreateSubgroups()" class="subgroups-card__start">
        <span v-t="'common.action.add_subgroup'"></span>
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
<style lang="scss">
@import 'app.scss';

.subgroups-card{
}

.subgroups-card__list{
  list-style: none;
  padding: 0;
  margin: 0;
}

.subgroups-card__list-item{
  clear: both;
  min-height: 50px;
  margin-bottom: 12px;
}

.subgroups-card__list-item-logo{
  width: 50px;
  height: 50px;
  float: left;
}

.subgroups-card__list-item-name{
  @include md-body-2;
  margin-left: 60px;
}

.subgroups-card__list-item-description{
  margin-left: 60px;
}

.subgroups-card__add-subgroup-link {
  @include cardMinorAction;
  @include lmoBtnLink;
}

</style>
