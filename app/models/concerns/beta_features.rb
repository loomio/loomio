module BetaFeatures
  extend ActiveSupport::Concern

  included do
    serialize :enabled_beta_features, Array
    #validates_inclusion_of :enabled_beta_features, in: AVAILABLE_BETA_FEATURES
  end

  #module ClassMethods
    #def available_beta_features
      #AVAILABLE_BETA_FEATURES || []
    #end
  #end

  def beta_feature_enabled?(name)
    enabled_beta_features.include?(name)
  end
end
