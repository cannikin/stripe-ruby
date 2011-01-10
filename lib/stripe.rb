$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Stripe
  VERSION = '1.3.5'
end

require 'stripe/pay'
