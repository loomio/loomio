BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
IdentityModel        = require 'shared/models/identity_model.coffee'

module.exports = class IdentityRecordsInterface extends BaseRecordsInterface
  model: IdentityModel

  performCommand: (id, command) ->
    @remote.getMember(id, command)
