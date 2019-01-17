<style>
.subgroups-card{
  @include card;
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
    <div class="blank">
      <section aria-labelledby="subgroups-card__title" v-if="show()" class="subgroups-card">
        <h2 v-t="'group_page.subgroups'" class="lmo-card-heading" id="subgroups-card__title"></h2>
        <p v-t="'group_page.subgroups_placeholder'" v-if="group.subgroups().length == 0" class="lmo-hint-text"></p>
        <ul class="subgroups-card__list">
          <li v-for="subgroup in orderedSubgroups()" :key="subgroup.id" class="subgroups-card__list-item">
            <div class="subgroups-card__list-item-logo">
              <!-- <group_avatar group="subgroup" size="medium"></group_avatar> -->
            </div>
            <div class="subgroups-card__list-item-name">
              <a :href="urlFor(subgroup)">{{ subgroup.name }}</a>
            </div>
            <div class="subgroups-card__list-item-description">{{ truncate(subgroup.description) }}</div>
          </li>
        </ul>
        <div class="lmo-flex lmo-flex__space-between"></div>
        <div class="lmo-md-actions">
          <!-- <outlet name="subgroup-card-footer"></outlet> -->
          <button @click="startSubgroup()" v-if="canCreateSubgroups()" class="md-primary md-raised subgroups-card__start">
            <span v-t="'common.action.add_subgroup'"></span>
          </button>
        </div>
      </section>
    </div>
</template>
