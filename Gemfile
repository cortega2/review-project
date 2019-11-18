source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use Puma as the app server
gem 'puma', '~> 3.11'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Using sucker punch to create async jobs
gem 'sucker_punch', '~> 2.0'

# Using Http for the Http library
gem 'http', '~> 4.2.0'

# Using redis for communicating between the job thread and the main thread
gem 'redis', '~> 4.1.3
'
group :development, :test do
  gem 'pry', '~> 0.12.2'
  gem 'rspec-rails', '~> 3.8'
  gem 'factory_bot_rails'
  gem 'webmock', '~> 3.7.6'

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'mysql2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
