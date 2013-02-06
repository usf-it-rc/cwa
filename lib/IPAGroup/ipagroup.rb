class IPAGroup
  attr_accessor :gid, :owner, :groupname, :comment, :operation,
                :ipa_server, :ipa_user, :ipa_password

  def initialize(&block)
    yield self if block !=nil
  end

  def find_by_user(user)
    json_string = {
      :method => "group_show", 
      :username => user
    }

    resp = Redmine::Cwa.simple_json_rpc(
      self.ipa_server,
      self.ipa_user,
      self.ipa_password,
      json_string
    )
    
    JSON.parse(resp).to_hash
  end  

  def save
    json_string = { 
      :method => self.operation, 
      :params => [ [], 
        { 
          :groupname => self.groupname,
          :gid => self.gid,
          :comment => "belongs to " + self.owner.to_s
        } 
      ] 
    }.to_json
    
    resp = Redmine::Cwa.simple_json_rpc(
      self.ipa_server,
      self.ipa_user,
      self.ipa_password,
      json_string
    )
  end
end
