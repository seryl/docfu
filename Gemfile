source "https://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

gem "mixlib-cli", "~> 1.3.0"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", "~> 2.13.0"
  gem "yard", "~> 0.8.6.1"
  gem "cucumber", ">= 0"
  gem "bundler", "~> 1.3.5"
  gem "jeweler", :git => "https://github.com/aia/jeweler.git", :branch => 'simplecov'
  gem (RUBY_VERSION.gsub('.', '').to_i >= 190 ? "simplecov" : "rcov"), ">= 0"
end
