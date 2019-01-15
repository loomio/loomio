module.exports =
  props:
    model: Object
    actions: Array
  template:
    """
      <div
        layout="row"
        class="action-dock lmo-flex lmo-no-print"
      >
        <div v-for="action in actions" v-if="action.canPerform()" class="action-dock__action">
          <!-- <reactions_input class="action-dock__button--react" model="model" v-if="action.name == 'react'"></reactions_input> -->
          <v-btn icon :class="`md-button--tiny action-dock__button--${action.name}`" v-if="action.name != 'react'" @click="action.perform()">
            <div v-t="'action_dock.' + action.name" class="sr-only"></div>
            <v-icon>{{action.icon}}</v-icon>
            <!-- <md-tooltip md-delay="500">
              <div translate="action_dock.{{ action.name }}"></div>
              <div ng-if="action.active()" md-colors="{\'color\': \'warn-200\'}"><i class="mdi mdi-alert-circle-outline mdi-16px lmo-margin-right"></i><span translate="action_dock.{{ action.name }}_active" ng-if="action.active()"></span></div>
            </md-tooltip> -->
          </v-btn>
        </div>
      </div>
    """
