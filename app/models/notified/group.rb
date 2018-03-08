class Notified::Group < Notified::Base
  def initialize(model, notifier)
    super(model).tap { @notifier = notifier }
  end

  def id
    model.id
  end

  def title
    I18n.t(:"notified.group_title", name: model.full_name, count: notified_ids.length)
  end

  def logo_url
    model.logo.presence&.url(:card) || AppConfig.theme[:icon_src]
  end

  def logo_type
    :uploaded
  end

  def notified_ids
    @notified_ids ||= Queries::UsersByVolumeQuery
                        .normal_or_loud(model)
                        .where.not(id: @notifier)
                        .pluck(:id)
  end
end
