RecordStore = require 'shared/record_store/record_store.coffee'
AppConfig   = require 'shared/services/app_config.coffee'
loki        = require 'lokijs'

db      = new loki('default.db')
records = new RecordStore(db)

records.addRecordsInterface require('shared/interfaces/boot_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/comment_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/discussion_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/event_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/group_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/membership_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/membership_request_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/notification_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/user_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/search_result_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/contact_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/invitation_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/invitation_form_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/version_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/draft_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/translation_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/oauth_application_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/session_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/registration_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/poll_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/poll_option_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/stance_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/stance_choice_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/outcome_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/poll_did_not_vote_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/identity_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/contact_message_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/group_identity_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/reaction_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/contact_request_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/document_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/login_token_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/message_channel_records_interface.coffee')
records.addRecordsInterface require('shared/interfaces/locale_records_interface.coffee')
AppConfig.records = records

AppConfig.records = records
module.exports = records
