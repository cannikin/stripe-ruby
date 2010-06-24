$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module DevPayments
  VERSION = '1.2.5'
end

require 'devpayments/pay'