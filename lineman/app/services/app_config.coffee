angular.module('loomioApp').factory 'AppConfig', ->
  configData = if window? and window.Loomio?
                 window.Loomio
               else
                 # fake config data. should be in the spec/ folder
                 baseUrl: undefined # usually https://www.loomio.org
                 locales: ['en', 'es'] # etc
                 seedRecords:
                   users: []
                 permittedParams:
                   "user": []
                   "vote": []
                   "motion": []
                   "proposal": []
                   "membership_request": []
                   "membership":[]
                   "invitation":[]
                   "group": []
                   "discussion": []
                   "discussion_reader": []
                   "comment": []
                   "attachment": []
                   "contact_message": []

  configData.seedRecords.users = [] unless configData.seedRecords.users?
  configData.seedRecords.users.push configData.seedRecords.current_user

  configData
