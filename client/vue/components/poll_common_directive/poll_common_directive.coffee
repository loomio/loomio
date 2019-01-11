module.exports =
  props:
    poll: Object
    stance: Object
    outcome: Object
    stanceChoice: Object
    back: Object
    name: String
  data: ->
    dpoll: @poll
  methods:
    componentName: ->
      model = @stance or @outcome or @stanceChoice or (poll: ->)
      @dpoll = @dpoll or model.poll()

      if Vue.options.components[_.camelCase("poll-#{@dpoll.pollType}-#{@name}-directive")]
        "poll-#{@dpoll.pollType}-#{@name}"
      else
        "poll-common-#{@name}"
  template:
    """
    <component :is="componentName()" :poll='dpoll' :stance='stance' :stance-choice='stanceChoice' :outcome='outcome' :back='back'></component>
    """
