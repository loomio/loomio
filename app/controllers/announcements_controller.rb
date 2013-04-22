class AnnouncementsController < ApplicationController
  def hide
    AnnouncementDismissal.create(announcement_id: params[:id], user_id: current_user.id)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
