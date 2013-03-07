#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "Devices" do
  describe "user sign in" do
    it "allows users to sign in after they have registered" do
      user = User.create(:email    => "eikebehr@tzi.de",
                         :password => "testtest")

      visit "/users/sign_in"

      fill_in "Email",    :with => "eikebehr@tzi.de"
      fill_in "Password", :with => "testtest"

      click_button "Sign in"

      page.should have_content("Signed in successfully.")
    end
  end
end