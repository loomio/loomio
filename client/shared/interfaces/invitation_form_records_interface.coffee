BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
InvitationFormModel  = require 'shared/models/invitation_form_model.coffee'

module.exports = class InvitationFormRecordsInterface extends BaseRecordsInterface
  model: InvitationFormModel
