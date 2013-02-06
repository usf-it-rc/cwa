module Redmine::Cwa
  class << self
    # Use plain old CAS REST service to verify the supplied credentials
    def simple_cas_validator(user, password, url)
      params = {
        :username => user,
        :password => password,
      }

      c = Curl::Easy.http_post(url + '/v1/tickets?', params.to_query) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.verbose = false
      end

      c.response_code == 201 ? true : false
    end
  end
end
