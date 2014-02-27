class BetaFeaturesController < BaseController

  def show
  end

  def create
    current_user.beta_features = params[:user][:beta_features].reject{|b| b.blank? }
    if current_user.save!
      flash[:success] = t(:'beta_features.beta_features_updated')
      redirect_to root_path
    end
  end

end
