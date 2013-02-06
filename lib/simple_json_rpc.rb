module Redmine::Cwa
  class << self
    def simple_json_rpc(url, user, password, json_string)
      begin
        c = Curl::Easy.http_post(url, json_string) do |curl|
          curl.cacert = 'ca.crt'
          curl.http_auth_types = :basic
          curl.username = user
          curl.password = password
          curl.ssl_verify_host = false
          curl.ssl_verify_peer = false
          curl.verbose = true
          curl.headers['referer'] = url
          curl.headers['Accept'] = 'application/json'
          curl.headers['Content-Type'] = 'application/json'
          curl.headers['Api-Version'] = '2.2'
        end
      rescue
        raise 'Could not connect to FreeIPA!'
      end
  
      h = JSON.parse(c.body_str).to_hash

      Rails.logger.debug "Redmine::Cwa.simple_json_rpc() => " + h.to_s
  
      # If we get an error AND its not "user not found"
      if h['error'] != nil and h['error']['code'] != 4001
        raise h['error']['message']
      else
        h
      end
    end
  end
end
