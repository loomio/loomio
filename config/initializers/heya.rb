Heya.configure do |config|
  # The name of the model you want to use with Heya.
  config.user_type = "User"

  # The default options to use when processing campaign steps.
  # config.campaigns.default_options = {from: "user@example.com"}

  # Campaign priority. When a user is added to multiple campaigns, they are
  # sent in this order. Campaigns are sent in the order that the users were
  # added if no priority is configured.
  # config.campaigns.priority = [
  #   "FirstCampaign",
  #   "SecondCampaign",
  #   "ThirdCampaign"
  # ]
end
