require 'rubygems'
require 'rest_client'
require 'json'
require 'ostruct'

module DevPayments
  class Client
    DEVPAY_API = 'https://api.devpayments.com/api'
    DEVPAY_PAGE_ROOT = 'https://devpayments.com/pay'

    def initialize(token, key)
      @token = token
      @key = key
    end

    def prepare_charge(amt, extra={})
      req({
        :amount => amt,
        :currency => 'usd',
        :url => '',
        :extra => JSON.dump(extra),
        :method => 'prepare_charge'
      })
    end

    def retrieve_charge(c)
      r = req({
        :charge => c,
        :method => 'retrieve_charge'
      })

      r['extra'] = JSON.load(r['extra']) if(r['extra']) 
      r
    end

    def execute_charge(c, ccdets)
      req({
        :charge => c,
        :card => ccdets,
        :method => 'execute_charge'
      })
    end
    
    def refund_charge(c)
      req({:charge => c, :method => 'credit_charge'})
    end

    private
    def req(params)
      params = params.merge({
        :key => @key,
        :token => @token,
        :sig => ''
      })

      d = RestClient.post(DEVPAY_API, params)
      resp = JSON.load(d)

      unless(resp['success'])
        e = resp['error']
        msg = e ? e : 'Unknown error'
        raise Error.new(msg)
      end

      resp['resp']
    end
  end

  class Error < RuntimeError; end

  def self.client(token, key)
    Client.new(token, key)
  end
end
