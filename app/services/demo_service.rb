class DemoService
  def self.take_demo(actor)
    group = DemoGroupTemplateService.create!(template_key: "mobile", user: actor).group
    TranslationService.translate_group_content!(group, actor.locale) if actor.locale != "en"

    Sentry.metrics.count("demo.start")
    EventBus.broadcast("demo_started", actor)
    group
  end

  def self.destroy_expired_demo_groups
    Group.expired_demo.find_each do |group|
      group.destroy!
    end
  end
end
