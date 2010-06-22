# API spec at https://github.com/devpayments/pay-server/wikis/api-docs

require 'rubygems'
require 'rest_client'
require 'json'
require 'ostruct'

module DevPayments
  class Client
    DEVPAY_API = 'https://api.devpayments.com/api'
    DEVPAY_PAGE_ROOT = 'https://devpayments.com/pay'
    
    def requires!(hash, *params)
      params.each do |param| 
        if param.is_a?(Array)
          raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first) 

          valid_options = param[1..-1]
          raise ArgumentError.new("Parameter: #{param.first} must be one of #{valid_options.to_sentence(:words_connector => 'or')}") unless valid_options.include?(hash[param.first])
        else
          raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param) 
        end
      end
    end    

    def initialize(key)
      @key = key
      @version = loaded_version
    end

    def prepare(opts)
      requires!(opts, :amount)
      
      opts.merge!({:method => 'prepare_charge'})
      
      if opts[:extra]      
        opts[:extra] = JSON.dump(opts[:extra])
      end
            
      r = req(opts)
      OpenStruct.new(r)
    end

    def retrieve(opts)
      requires!(opts, :charge)
      
      r = req({
        :charge => opts[:charge],
        :method => 'retrieve_charge'
      })

      r['extra'] = JSON.load(r['extra']) if(r['extra']) 
      
      OpenStruct.new(r)
    end
    
    def execute(opts)
      requires!(opts, :card)
      unless opts[:charge] or opts[:amount]
        raise ArgumentError.new("Missing parameters: execute() requires either :charge (charge token) or :amount.")
      end
      
      opts.merge!({
        # will override opts
        :method => 'execute_charge'
      })
      
      r = req(opts)
      OpenStruct.new(r)
    end
    
    def refund(opts)
      requires!(opts, :charge)
      
      opts.merge!({
        :method => 'refund_charge'
      })
      
      r = req(opts)
      OpenStruct.new(r)
    end
        
    def create_customer(opts)
      requires!(opts, :customer)
      r = req(opts.merge!(:method => 'create_customer'))
      OpenStruct.new(r)
    end
    
    def update_customer(opts)
      requires!(opts, :customer)
      r = req(opts.merge(:method => 'update_customer'))
      OpenStruct.new(r)
    end
    
    def set_customer_subscription(opts)
      requires!(opts, :customer, :amount, :per)
      r = req(opts.merge(:method => 'set_customer_subscription'))
      OpenStruct.new(r)
    end
    
    def bill_customer(opts)
      requires!(opts, :customer, :amount)
      r = req(opts.merge(:method => 'bill_customer'))
      OpenStruct.new(r)
    end
    
    def retrieve_customer(opts)
      requires!(opts, :customer)
      r = req(opts.merge(:method => 'retrieve_customer'))
      OpenStruct.new(r)
    end
    
    def delete_customer(opts)
      requires!(opts, :customer)
      r = req(opts.merge(:method => 'delete_customer'))      
    end
    
    private
    def loaded_version
      version_file = File.join(File.dirname(__FILE__), '../../VERSION')
      File.exists?(version_file) ? File.read(version_file).strip : 'unknown'
    end
    
    def req(params)
      params = params.merge({
        :key => @key,
        :client => {
          :type => 'binding',
          :language => 'ruby',
          :version => @version
        }
      })

      d = RestClient.post(DEVPAY_API, params)
      resp = JSON.load(d.body)

      unless(resp['success'])
        e = resp['error']
        msg = e ? e : 'Unknown error'
        raise Error.new(msg)
      end

      resp['resp']
    end
  end

  class Error < RuntimeError; end

  def self.client(key)
    Client.new(key)
  end
end
