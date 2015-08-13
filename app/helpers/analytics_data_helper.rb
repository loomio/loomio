module AnalyticsDataHelper
  def analytics_data_tag
    tg = {dimension4: Loomio::Version.current,
          dimension6: 0}

    if current_user
     tg.merge!({dimension5: current_user.id})
    end

    if @group.present? and @group.persisted?
      tg.merge!({
        dimension1: @group.id,
        dimension2: @group.organisation_id,
        dimension3: @group.cohort_id,
      })
    end

    tg
  end
end
