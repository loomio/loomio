class GroupOptions
	include ActionView::Helpers::TagHelper
	delegate :url_helpers, to: 'Rails.application.routes'

	attr_accessor :group, :user

	def initialize(group, user)
		@group = group
		@user = user
	end

	def edit
		if @user.can? :edit, @group
			content_tag(:li, content_tag(:a, I18n.t(:edit_group_settings_html),
																	 href: url_helpers.edit_group_path(group)))
		end
	end

	def leave
		if @group.users_include? @user
			membership = @user.group_membership(@group)
			content_tag(:li, content_tag(:a, I18n.t(:leave_group), href: "#",
																	 'data-title' => I18n.t(:leave_group),
																	 'data-body' => I18n.t(:confirm_leave_group, which_group: group.name),
																	 'data-confirm-path' => url_helpers.group_membership_path(group, membership),
																	 'data-method-type' => 'delete', class: 'confirm-dialog',
																	 id: 'leave group'))
		end
	end

	def archive
		if @user.can? :edit, @group
			content_tag(:li, content_tag(:a, I18n.t(:deactivate_group), href: "#",
																	 'data-title' => I18n.t(:deactivate_group),
																	 'data-body' => I18n.t(:confirm_deactivate_group, which_group: group.name),
																	 'data-confirm-path' => url_helpers.archive_group_path(@group),
																	 'data-method-type' => 'post', class: 'confirm-dialog',
																	 id: 'de-activate group'))
		end
	end
end
