# This class will let us interact with the FreeIPA server for modifying
# and viewing group information
module Redmine::IPAGroup
  class << self
    def find_all
      json_string = {
        :method => "group_find", 
        :params => [ [], {
          :sizelimit => 0
        } ]
      }.to_json
      _ipa_json_rpc json_string
    end  

    def find_by_user(user)
      json_string = {
        :method => "group_find", 
        :params => [ [], {
          :user => [ user ]
        } ]
      }.to_json
      _ipa_json_rpc json_string
    end  

    def add_user(user, groupname)
      json_string = {
        :method => "group_add_member",
        :params => [ [], {
          :user => [ user ],
          :cn => groupname
        } ]
      }.to_json       

      resp = _ipa_json_rpc json_string
      Rails.logger.debug "add_user() => " + resp.to_s + " ==> " + resp['result']['completed'].to_s
      if resp['result']['completed'] != 0
        true
      else
        false
      end
    end

    def remove_user(user, groupname)
      json_string = {
        :method => "group_remove_member",
        :params => [ [], {
          :user => [ user ],
          :cn => groupname
        } ]
      }.to_json       

      resp = _ipa_json_rpc json_string
      Rails.logger.debug "remove_user() => " + resp.to_s
      if resp[:error] == nil
        true
      else
        false
      end
    end

    private
    def _ipa_json_rpc (json_string)
      Redmine::Cwa.simple_json_rpc(
        "https://" + Redmine::Cwa.ipa_server + "/ipa/json",
        Redmine::Cwa.ipa_account,
        Redmine::Cwa.ipa_password,
        json_string.to_s
      )
    end
  end
end
