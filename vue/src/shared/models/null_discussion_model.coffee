import {each} from 'lodash'
import Vue from 'vue'
import I18n from '@/i18n.coffee'
import NullGroupModel from '@/shared/models/null_group_model'

export default class NullDiscussionModel
  @singular: 'discussion'
  @plural: 'discussions'

  constructor: ->
    defaults =
      id: null
      title: 'No thread'
      description: ''
      descriptionFormat: 'html'

    each defaults, (value, key) =>
      Vue.set(@, key, value)
      true

  polls: -> []
  discussion: -> @
  group: -> new NullGroupModel()
  markAsRead: -> false
