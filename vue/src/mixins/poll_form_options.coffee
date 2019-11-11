import AppConfig  from '@/shared/services/app_config'
import {keys, intersection, uniq, without, compact, map, every} from 'lodash'
export default
  data: ->
    savedOptionsNames: []

  created: ->
    @savedOptionNames = @poll.pollOptionNames

  methods:
    persistOptions: ->
      @persistChosenOptions()
      @persistSavedOptions() if @addOptionsOnly

    persistSavedOptions: ->
      @poll.pollOptionNames = uniq(@savedOptionNames.concat(@poll.pollOptionNames))

    persistChosenOptions: ->
      unless every(@chosenOptionNames.map (name) => @poll.pollOptionNames.includes(name))
        @poll.pollOptionNames = uniq @chosenOptionNames.concat(@poll.pollOptionNames)

    removeOptionName: (optionName) ->
      return false unless @canRemove(optionName)
      @poll.pollOptionNames = without(@poll.pollOptionNames, optionName)
      @persistSavedOptions() if @addOptionsOnly

    colorFor: (optionName) ->
      AppConfig.pollColors.poll[@poll.pollOptionNames.indexOf(optionName) % AppConfig.pollColors.poll.length]

    canRemove: (optionName) ->
      return false if @chosenOptionNames.includes(optionName)
      return false if @addOptionsOnly && @savedOptionNames.includes(optionName)
      true

  computed:
    noNewOptions: ->
      isEqual @savedOptionNames, @poll.pollOptionNames

    chosenOptionNames: ->
      compact map(@poll.stanceData, (value, key) => key if value > 0)
