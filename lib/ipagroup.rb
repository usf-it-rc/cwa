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

    # Create new IPA group
    def create_new_group(group_info)
      description = {
        :owner => group_info[:owner],
        :desc  => group_info[:desc]
      }
      json_string = {
        :method => "group_add",
        :params => [ [], {
          :cn => group_info[:group_name],
          :description => description.to_s
        } ]
      }.to_json       

      begin
        resp = _ipa_json_rpc json_string
      rescue
        return false    
      end

      Rails.logger.debug "create_new_group() => " + resp.to_s + " ==> " + resp['result']['completed'].to_s
      if resp['result']['completed'] != 0
        # Add owner
        add_user group_info[:owner], group_info[:group_name]
        true
      else
        false
      end
    end

    def delete_group(group_name)
      json_string = {
        :method => "group_del",
        :params => [ [], {
          :cn => group_name
        } ]
      }.to_json       
      resp = _ipa_json_rpc json_string
      Rails.logger.debug "delete_group() => " + resp.to_s + " ==> " + resp['result']['completed'].to_s
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
