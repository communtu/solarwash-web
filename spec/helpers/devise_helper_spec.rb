require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the DevicesHelper. For example:
#
# describe DevicesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe DeviseHelper do
  def signin
    user = User.new(  name: "Stephan Brinkmann",
                      email: "sbrink@tzi.de",
                      password: '12345678', 
                      password_confirmation: '12345678',
                      apartmentnumber: 1)
    user.skip_confirmation! 
    user.save!
    
    visit "/users/sign_in"

    fill_in "Email",    :with => "sbrink@tzi.de"
    fill_in "Passwort", :with => "12345678"

    click_button "Anmelden"
  end
end
