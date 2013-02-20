require 'spec_helper'

describe "devices/edit" do
  before(:each) do
    @device = assign(:device, stub_model(Device,
      :name => "MyString",
      :type => 1,
      :state => 1
    ))
  end

  it "renders the edit device form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => devices_path(@device), :method => "post" do
      assert_select "input#device_name", :name => "device[name]"
      assert_select "input#device_type", :name => "device[type]"
      assert_select "input#device_state", :name => "device[state]"
    end
  end
end
