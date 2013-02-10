# This class will let us interact with the FreeIPA server for modifying
# and viewing group information
module Redmine::IPAGroup
  class << self
    attr_accessor :gid, :owner, :groupname, :comment, :operation,
                :ipa_server, :ipa_user, :ipa_password

    def initialize(&block)
      yield self if block !=nil
    end

    def find_by_user(user)
      json_string = {
        :method => "group_find", 
        :params => [ [], {
          :user => [ user ]
        } ]
      }.to_json

      resp = Redmine::Cwa.simple_json_rpc(
        "https://" + Redmine::Cwa.ipa_server + "/ipa/json",
        Redmine::Cwa.ipa_account,
        Redmine::Cwa.ipa_password,
        json_string.to_s
      )
      resp
    end  

    def save
      json_string = { 
        :method => self.operation, 
        :params => [ [], { 
          :groupname => self.groupname,
          :gid => self.gid,
          :comment => "belongs to " + self.owner.to_s
        } ] 
      }.to_json
    
      resp = Redmine::Cwa.simple_json_rpc(
        Redmine::Cwa.ipa_server,
        Redmine::Cwa.ipa_user,
        Redmine::Cwa.ipa_password,
        json_string.to_s
      )
    end
  end
end
