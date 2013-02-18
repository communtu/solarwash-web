require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_selector('h1',    text: 'AWE Benutzerverwaltung') }
    #it { should have_selector('title', text: full_title('')) }
    #it { should_not have_selector('title', text: '| Home') }
  end
  
  describe "link to new user" do
    before { visit root_path }
    #click_link "Registrieren"
    page.should have_selector 'title', text: "Neuer User:"
  end
  
  describe "Korrektes einloggen Testen" do
    before do
       visit root_path
       @user = User.create(name: "Hodor", email: "hodor@hodor.de")
       fill_in "Email", with: @user.email
       click_button submit
     end
     it { should have_selector('title', text: "Hallo #{@user.name}") }
   end
end
