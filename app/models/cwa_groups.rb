class CwaGroups
  attr_accessor :my_groups, :owned_groups
  # Get list of groups I own from JSON-RPC
  def groups_i_own
    Redmine::IPAGroup.owned_by_user(User.current.login)
  end 

  # Get list of groups I belong to from JSON-RPC
  def member_of_groups
    g = Redmine::IPAGroup.find_by_user(User.current.login)['result']['result']
    res = Array.new

    g.each {|r| res << r}

    self.my_groups = Array.new

    res.each do |r|
      Rails.logger.debug "Totally putting " + r['cn'].first + " => " + r['description'].first + " in :groups..."
      self.my_groups << { :cn => r['cn'].first, :desc => r['description'].first }
    end

    self.my_groups
  end

  def add_to_my_group

  end

  def del_from_my_group
 
  end
end
