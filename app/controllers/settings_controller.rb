class SettingsController < ApplicationController
  before_filter :authenticate_admin_user!

end