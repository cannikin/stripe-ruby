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
  self.version = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  self.developer '/dev/payments', 'info@devpayments.com'
  self.rubyforge_name       = self.name
  self.extra_deps           = [['json','>= 1.4.0'], ['rest-client', '>= 1.4.1']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
