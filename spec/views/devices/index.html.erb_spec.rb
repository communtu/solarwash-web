require 'spec_helper'

describe "devices/index" do
  before(:each) do
    assign(:devices, [
      stub_model(Device,
        :name => "Name",
        :devicetype => 1,
        :state => 2
      ),
      stub_model(Device,
        :name => "Name",
        :devicetype => 1,
        :state => 2
      )
    ])
  end

  
end
