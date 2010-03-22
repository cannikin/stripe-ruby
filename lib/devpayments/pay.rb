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
      
      opts = opts.merge({
        # will override opts
        :method => 'execute_charge'
      })
      
      r = req(opts)
      OpenStruct.new(r)
    end
    
    def refund(opts)
      requires!(opts, :charge)
      
      r = req(opts.merge({
        :method => 'refund_charge'
      }))
      
      OpenStruct.new(r)
    end
    
    def set_customer_card(opts)
      requires!(opts, :customer, :card)
      
      opts = opts.merge({
        :method => 'set_customer_card'
      })
      
      r = req(opts)
      OpenStruct.new(r)
    end

    private
    def req(params)
      params = params.merge({
        :key => @key
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
