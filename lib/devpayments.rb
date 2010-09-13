$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class DevPayments
  VERSION = '1.3.2'
end

require 'devpayments/pay'