source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'bootstrap-sass', '~> 2.3.0.0'
gem 'bcrypt-ruby', '3.0.1'
gem "font-awesome-rails"  


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails', '2.11.0'
  gem 'guard-rspec'
  gem 'spork'
  gem 'guard-spork', :github => 'guard/guard-spork'
  gem 'faker'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :development do
  gem 'annotate', '2.5.0'
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

gem 'jquery-rails'

group :test do
  gem 'capybara', '1.1.2'
  gem 'rb-fsevent', '0.9.1', :require => false
  gem 'growl', '1.0.3'
  gem 'factory_girl_rails', '4.1.0'
end

group :production do
  gem 'pg'
end