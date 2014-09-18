require 'rails_helper'

describe RobotsController do

  describe "#show" do

    around(:each) do |test|
      @allow_robots = ENV['ALLOW_ROBOTS']
      test.run
      ENV['ALLOW_ROBOTS'] = @allow_robots
    end

    it "returns private robots.txt when ALLOW_ROBOTS is false" do 
      ENV['ALLOW_ROBOTS'] = 'N'
      get :show, format: :txt

      response.should render_template :private_robots
    end

    it "returns public robots.txt when ALLOW_ROBOTS is true" do 
      ENV['ALLOW_ROBOTS'] = 'Y'
      get :show, format: :txt

      response.should render_template :public_robots
    end

  end

  describe ".robot_file" do
    it "returns a private robots.txt when passed falsish string" do
      controller.send(:robot_file, false).should eq   :private_robots
      controller.send(:robot_file, "false").should eq :private_robots
      controller.send(:robot_file, "f").should eq     :private_robots
      controller.send(:robot_file, "no").should eq    :private_robots
      controller.send(:robot_file, "n").should eq     :private_robots
      controller.send(:robot_file, "0").should eq     :private_robots
    end

    it "returns a public robots.txt when passed truish string" do
      controller.send(:robot_file, true).should eq    :public_robots
      controller.send(:robot_file, "true").should eq  :public_robots
      controller.send(:robot_file, "t").should eq     :public_robots
      controller.send(:robot_file, "yes").should eq   :public_robots  
      controller.send(:robot_file, "y").should eq     :public_robots 
      controller.send(:robot_file, "1").should eq     :public_robots     
    end
  end
end
