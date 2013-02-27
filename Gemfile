source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem 'bootstrap-sass', '~> 2.3.0.1'
gem 'bcrypt-ruby', '3.0.1'
gem "font-awesome-rails"  
gem 'simple_form'
gem 'foreigner'
gem 'has_scope'
gem 'ui_datepicker-rails3'
gem 'haml'
gem 'bootstrap-tooltip-rails'
gem "validates_date_time"
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'devise'
gem 'faker'
gem 'timecop'
gem "gccxml_gem", "~> 0.9.3"
gem "rbgccxml", "~> 1.0.3"
gem "bit-struct", "~> 0.13.6"
gem 'whenever', :require => false
gem 'activeadmin', github: 'Daxter/active_admin', branch: 'bugfix/1773-execjs'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'spork'
  gem 'guard-spork'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :development do
  gem 'annotate'
end
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'capybara'
  gem 'rb-fsevent', '0.9.1', :require => false
  gem 'growl'
  gem 'factory_girl_rails'
end

group :production do
  gem 'execjs'
  gem 'therubyracer'
end