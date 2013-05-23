class WocController < CampaignsController

  protected

  def get_campaign
    Campaign.find_by_name("woc")
  end

  def success_message
    "<p>Success! You have registered '#{@email}'
     to participate in the Wellington Online Collaboration.</p>
     <p>You should hear from us within 24hrs. Drop us a line if
     you have any queries: contact@loomio.org</p>"
  end

  def success_url
    collaborate_url(:success => 'yes')
  end

  def assign_meta_data
    @title = "Loomio - Wellington Online Collaboration: Alcohol Management Strategy"
    @meta_title = "Loomio - Wellington Online Collaboration: Alcohol Management Strategy"
    @meta_description = "People all over Wellington are getting together online to work with their " +
                        "City Council to collaborate on an Alcohol Management Strategy for the city. " +
                        "Click here to participate!"
  end
end
