require 'rails_helper'

describe AutodetectTimeZone do
  let(:user) { create(:user) }

  class DummyController
    include AutodetectTimeZone
  end

  before :each do
    @dummy_controller = DummyController.new
    @dummy_controller.stub(current_user: user)
  end

  after do
    @dummy_controller.stub_chain(:request, :cookies).
                      and_return({"time_zone" => @time_zone})
    @dummy_controller.send(:set_time_zone_from_javascript)
  end

  it "sets user.time_zone to whatever is in the cookie" do
    @time_zone = "Wellington"
    user.should_receive(:update_attribute).with(:time_zone, @time_zone)
  end

  it "doesn't set user.time_zone if undefined" do
    @time_zone = "undefined"
    user.should_not_receive(:update_attribute).with(:time_zone, @time_zone)
  end

  it "doesn't set user.time_zone if detected time_zone is blank" do
    @time_zone = ""
    user.should_not_receive(:update_attribute).with(:time_zone, @time_zone)
  end

  it "doesn't update time_zone if it's the same" do
    @time_zone = "Wellington"
    user.update_attribute(:time_zone, @time_zone)
    user.should_not_receive(:update_attribute).with(:time_zone, @time_zone)
  end

  it "doesn't error if there isn't a current_user" do
    @time_zone = "Wellington"
    @dummy_controller.stub(current_user: LoggedOutUser.new)
  end
end
