module.exports = Vue.component 'ActionDock',
  props:
    model: Object
    actions: Array
  mounted: ->
    # debugger
  template:
    """
      <div
        layout="row"
        class="action-dock lmo-flex lmo-no-print"
      >
        <div v-for="action in actions" v-if="action.canPerform()" class="action-dock__action">
          <!-- <reactions_input class="action-dock__button--react" model="model" v-if="action.name == 'react'"></reactions_input> -->
          <button :class="`md-button--tiny action-dock__button--${action.name}`" v-if="action.name != 'react'" @click="action.perform()">
            <div v-t="'action_dock.' + action.name" class="sr-only"></div>
            <i
              class="mdi"
              :class="action.icon"
            ></i>
            <i
              v-if="action.hasPlus && !action.active()"
              class="mdi mdi-plus lmo-helper-icon"
            ></i>
            <i
              v-if="action.active && action.active()"
              md-colors="{\'color\': \'warn\'}"
              class="mdi mdi-alert-circle-outline action-dock--active lmo-helper-icon"
            ></i>
            <!-- <md-tooltip md-delay="500">
              <div translate="action_dock.{{ action.name }}"></div>
              <div ng-if="action.active()" md-colors="{\'color\': \'warn-200\'}"><i class="mdi mdi-alert-circle-outline mdi-16px lmo-margin-right"></i><span translate="action_dock.{{ action.name }}_active" ng-if="action.active()"></span></div>
            </md-tooltip> -->
          </button>
        </div>
      </div>
    """
