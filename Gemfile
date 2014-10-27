source 'https://rubygems.org'

gem 'berkshelf'

group :plugins do
  gem 'vagrant-berkshelf'
  gem 'vagrant-omnibus'
end

group :lint do
  gem 'thor-foodcritic'
  gem 'foodcritic'
  gem 'rubocop'
end

group :integration do
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
  gem 'serverspec', '~>2.0'
end

group :unit do
  gem 'chefspec'
end
