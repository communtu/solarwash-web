#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'
require 'helpers/devise_helper_spec'

describe "Devise" do
  describe "user sign in" do
    it "allows users to sign in after they have registered" do
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

      page.should have_content("Abmelden")
    end
  end
end