# API spec at https://github.com/devpayments/pay-server/wikis/api-docs
require 'rubygems'
require 'rest_client'
require 'json'

class DevPayments
  class Response
    def initialize(hash)
      @data = hash
    end
    
    InspectKey = :__inspect_key__
    def inspect
      str = "#<#{self.class}"

      Thread.current[InspectKey] ||= []
      if Thread.current[InspectKey].include?(self) then
        str << " ..."
      else
        first = true
        for k,v in @data
          str << "," unless first
          first = false

          Thread.current[InspectKey] << v
          begin
            str << " #{k}=#{v.inspect}"
          ensure
            Thread.current[InspectKey].pop
          end
        end
      end

      str << ">"
    end
    
    def method_missing(name, *args)
      @data[name.to_s]
    end
    
    def id
      @data['id']
    end
  end
  
  class Client
    DEVPAY_API = 'https://api.devpayments.com/v1'
    
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

    def retrieve(opts)
      requires!(opts, :id)
      
      r = req({
        :id => opts[:id],
        :method => 'retrieve_charge'
      })

      Response.new(r)
    end
    
    def execute(opts)
      requires!(opts, :amount, :currency)
      
      unless opts[:card] or opts[:customer]
        raise ArgumentError.new("Missing parameters: execute() requires either :card (card hashmap) or :customer (customer id).")
      end
      
      opts.merge!({
        # will override opts
        :method => 'execute_charge'
      })
      
      r = req(opts)
      Response.new(r)
    end
    
    def refund(opts)
      requires!(opts, :id)
      
      opts.merge!({
        :method => 'refund_charge'
      })
      
      r = req(opts)
      Response.new(r)
    end
        
    def create_customer(opts)
      r = req(opts.merge!(:method => 'create_customer'))
      Response.new(r)
    end
    
    def update_customer(opts)
      requires!(opts, :id)
      r = req(opts.merge(:method => 'update_customer'))
      Response.new(r)
    end
    
    def bill_customer(opts)
      requires!(opts, :id, :amount)
      r = req(opts.merge(:method => 'bill_customer'))
      Response.new(r)
    end
    
    def retrieve_customer(opts)
      requires!(opts, :id)
      r = req(opts.merge(:method => 'retrieve_customer'))
      Response.new(r)
    end
    
    def delete_customer(opts)
      requires!(opts, :id)
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
      
      if resp['error']
        case resp['error']['type']
        when 'card_error'
          raise CardError.new(resp['error']['message'])
        when 'invalid_request_error'
          raise InvalidRequestError.new(resp['error']['message'])
        when 'api_error'
          raise APIError.new(resp['error']['message'])
        else
          raise resp['error']['message']
        end
      end

      resp
    end
  end

  class Error < RuntimeError; end
  class CardError < DevPayments::Error; end
  class InvalidRequestError < DevPayments::Error; end
  class APIError < DevPayments::Error; end

  def self.client(key)
    Client.new(key)
  end
end
