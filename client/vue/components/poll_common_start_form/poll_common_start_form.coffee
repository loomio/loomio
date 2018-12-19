AppConfig    = require 'shared/services/app_config'
Records      = require 'shared/services/records'
ModalService = require 'shared/services/modal_service'

{ fieldFromTemplate } = require 'shared/helpers/poll'

module.exports =
  props:
    discussion:
      type: Object
      default: () => ({})
    group:
      type: Object
      default: () => ({})
  methods:
    pollTypes: -> AppConfig.pollTypes

    startPoll: (pollType) ->
      ModalService.open 'PollCommonStartModal', poll: =>
        Records.polls.build
          pollType:              pollType
          discussionId:          @discussion.id
          groupId:               @discussion.groupId or @group.id
          pollOptionNames:       _.map @callFieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    callFieldFromTemplate: (pollType, field) ->
      fieldFromTemplate(pollType, field)

    getAriaLabelForPollType: (pollType) ->
      @$t("poll_types.#{pollType}")

  template:
    """
    <ul md-list class="decision-tools-card__poll-types">
      <li
        md-list-item
        class="decision-tools-card__poll-type"
        :class="'decision-tools-card__poll-type--' + pollType"
        @click="startPoll(pollType)"
        v-for="(pollType, index) in pollTypes()"
        :key=index
        :aria-label="getAriaLabelForPollType(pollType)"
      >
        <i
          class="mdi mdi-24px decision-tools-card__icon"
          :class="callFieldFromTemplate(pollType, 'material_icon')"
        ></i>
        <div class="decision-tools-card__content">
          <div v-t="'poll_types.' + pollType" class="decision-tools-card__poll-type-title md-body-1"></div>
          <div v-t="'poll_' + pollType + '_form.tool_tip_collapsed'" class="decision-tools-card__poll-type-subtitle md-caption"></div>
        </div>
      </li>
    </ul>
    """
