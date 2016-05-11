class DecisionSessionsController < ActionController::Base
  before_action :verify_token

  def show
  end

  private
  def decision_session
    @decision_session ||= DecisionSession.find(params[:id])
  end

  def verify_token
    unless decision_session.token_for(params[:email]) == params[:token]
      raise "token invalid"
    end
  end
end
