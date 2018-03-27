BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'

module.exports = class BootRecordsInterface extends BaseRecordsInterface
  model:
    singular: 'boot'
    plural: 'boot'
