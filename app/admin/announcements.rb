ActiveAdmin.register Announcement do
  form do |f|
    f.inputs do
      f.input :message
      f.input :locale
      f.input :starts_at
      f.input :ends_at
    end
    f.buttons
  end

  member_action :new, :method => :get do
    starts_at = Time.now
    ends_at = starts_at + 2.weeks
    @announcement = Announcement.new(starts_at: starts_at, ends_at: ends_at)
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
