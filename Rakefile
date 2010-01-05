require 'rubygems'
gem 'hoe', '>= 2.0.0'
require 'hoe'
require 'fileutils'
require './lib/devpayments'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'devpayments' do
  self.developer '/dev/payments', 'info@devpayments.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name
  self.extra_deps           = [['json','>= 1.1.0'], ['rest-client', '>= 1.0.3']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
