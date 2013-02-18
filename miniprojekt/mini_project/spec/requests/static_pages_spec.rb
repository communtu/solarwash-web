require 'spec_helper'

describe "Static pages" do

  subject { page }
  before { User.create(name: "Hodor", email: "hodor@hodor.de") }
  describe "Home page" do
    before { visit root_path }

    it { should have_selector('h1',    text: 'AWE Benutzerverwaltung') }
    #it { should have_selector('title', text: full_title('')) }
    #it { should_not have_selector('title', text: '| Home') }
  end
  
  describe "link to new user" do
    before do
      visit root_path
      click_link "Registrieren"
    end
    it { should have_selector 'h1', text: "New user" }
  end
  
  describe "Korrektes einloggen Testen" do
    before do
       visit signin_path
       @user = User.new(name: "Hodor", email: "hodor@hodor.de")
       fill_in "Email", with: @user.email
       click_button "Einloggen"
     end
     it { should have_link('Ausloggen', href: signout_path) }
     
     describe "Richtiges Ausloggen" do
      before { click_link "Ausloggen" }
      it { should have_link('Einloggen', href: signin_path) } 
      it { should_not have_link('Ausloggen', href: signout_path) }
     end
     
   end
   
   describe "Falsche einloggen Testen" do
     before do
        visit signin_path
        @user = User.new(name: "Hodor", email: "hodor@hodor.de")
        fill_in "Email", with: "falsche@email.com"
        click_button "Einloggen"
      end
      it { should_not have_selector('title', text: "Hallo #{@user.name}") }
    end
  
end
