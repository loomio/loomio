class WeThePeopleController < CampaignsController

  protected

  def get_campaign
    Campaign.find_by_name("we the people")
  end

  def success_message
    "<p>Success! You have registered '#{@email}'
     to participate in We The People on Loomio.</p>
     <p>You should hear from us within 24hrs. Drop us a line if
     you have any queries: contact@loomio.org</p>"
  end

  def success_url
    we_the_people_url(:success => 'yes')
  end

  def assign_meta_data
    @title = "Loomio - We The People"
    @meta_title = "Loomio - We The People"
    @meta_description = "People all over New Zealand are getting together online to compare notes, " +
                        "swap opinions and shape up some deeper questions for the constitutional review. " +
                        "Click here to participate!"
  end
end
