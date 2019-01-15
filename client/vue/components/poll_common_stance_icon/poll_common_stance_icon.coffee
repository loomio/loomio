{ fieldFromTemplate } = require 'shared/helpers/poll'

module.exports =
  props:
    stanceChoice: Object
  methods:
    useOptionIcon: ->
      fieldFromTemplate(@stanceChoice.poll().pollType, 'has_option_icons')
  template:
    """
    <div class="poll-common-stance-icon">
      <img v-if="useOptionIcon()" :src="'/img/' + stanceChoice.pollOption().name + '.svg'" alt="stanceChoice.pollOption().name" class="lmo-box--tiny poll-common-stance-icon__svg">
      <div v-if="!useOptionIcon()" :style="{'border-color': stanceChoice.pollOption().color}" class="poll-common-stance-icon__chip"></div>
    </div>
    """
