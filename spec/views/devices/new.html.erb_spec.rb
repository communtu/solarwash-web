require 'spec_helper'

describe "devices/new" do
  before(:each) do
    assign(:device, stub_model(Device,
      :name => "MyString",
      :type => 1,
      :state => 1
    ).as_new_record)
  end

  it "renders new device form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => devices_path, :method => "post" do
      assert_select "input#device_name", :name => "device[name]"
      assert_select "input#device_type", :name => "device[type]"
      assert_select "input#device_state", :name => "device[state]"
    end
  end
end
