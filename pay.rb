require 'rubygems'
require 'rest_client'
require 'json'

module DevCC
  class Client
    DCC_API = 'http://localhost:4567/api'
    DCC_PAGE_ROOT = 'http://collison.ie:4600/pay'

    def initialize(token, key)
      @token = token
      @key = key
    end

    def prepare_charge(amt, url, extra={})
      req({
        :amount => amt,
        :currency => 'usd',
        :url => url,
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
      r = req({
        :charge => c,
        :card => ccdets,
        :method => 'execute_charge'
      })
    end

    private
    def req(params)
      params = params.merge({
        :key => @key,
        :token => @token,
        :sig => ''
      })

      d = RestClient.post(DCC_API, params)
      resp = JSON.load(d)

      unless(resp['success'])
        e = resp['error']
        msg = e ? e : 'Unknown error'
        Error.new(msg).raise
      end

      resp['resp']
    end
  end

  class Error < RuntimeError; end

  def self.client(token, key)
    Client.new(token, key)
  end
end
