require 'cwa_rest'
include ::CwaRest

class CwaIpaUser
  # This gets us all of our accessor methods for plugin settings
  # and ipa-based attributes
  @@ipa_result = Hash.new
  @@fields = Hash.new
  attr_accessor :passwd

  def initialize
    user = User.current
    make_user_fields(user)
    ipa_query(user.login)
  end

  # this exposes ldap attributes and custom fields as methods
  def method_missing(name, *args, &blk)
    # If its an option in the settings hash, return it
    if args.empty? && blk.nil?
      user = User.current

      # Populate custom fields for user
      make_user_fields(user)

      if @@fields != nil && @@fields[user.login].has_key?(name)
        return @@fields[user.login][name.to_sym]
      end

      # Query IPA server or return cached values
      ipa_query(user.login)

      if @@ipa_result.has_key?(user.login) &&
        @@ipa_result[user.login].try(:[], :result) &&
        @@ipa_result[user.login][:result].try(:[], name.to_s)
        return @@ipa_result[user.login][:result][name.to_s].first
      end
      super
    else
      super
    end
  end

  # List of allowed shells
  def available_shells
     { "/bin/sh" => 0, "/bin/bash" => 1, "/bin/ash" => 2, "/bin/zsh" => 3,  "/bin/csh" => 4, "/bin/tcsh" => 5 }
  end

  def provisioned?
    @@ipa_result[User.current.login] != nil
  end

  # Force a full query on the next ipa_query run
  def refresh
    user = User.current
    if @@ipa_result.has_key?(user.loggin) && @@ipa_result[user.login] != nil
      if @@ipa_result[user.login].has_key?(:timestamp)
        @@ipa_result[user.login][:timestamp] -= 60.seconds
      end
    end
    ipa_query(user.login)
    make_user_fields(user)
  end

  # 
  def valid_passwd?
    self.passwd =~ ::CwaConstants::PASSWD_REGEX &&
      Redmine::Cwa.simple_cas_validator(User.current.login, self.passwd)
  end

  # Update parameters in IPA
  def update(params)
    param_list = Hash.new
    params.keys.each do |k|
      param_list.merge!({ k => params[k] })    
    end

    begin
      r = CwaRest.client({
        :verb => :POST,
        :url  => "https://" + Redmine::Cwa.ipa_server + "/ipa/json",
        :user => Redmine::Cwa.ipa_account,
        :password => Redmine::Cwa.ipa_password,
        :json => {
          'method' => 'user_mod',
          'params' => [ [], { 'uid' => User.current.login }.merge(param_list) ]
        }
      })
    rescue
      return false
    end

    self.refresh
    return true
  end

  def workdirectory
    self.homedirectory.gsub(/\/home\//, "/work/")
  end

  def create
    Rails.logger.debug "provision() => { " + User.current.login + ", " + self.passwd.to_s + ", user_add }"
    begin
      provision User.current.login, self.passwd, "user_add"
    rescue Exception => e
      raise e.message
    end
    self.refresh
  end

  def destroy
    begin
      provision User.current.login, nil, "user_del"
    rescue Exception => e
      raise e.message
    end
    self.refresh
  end

  # Get wonderful attributes from IPA server
  private
  def ipa_query(uid)
    if @@ipa_result[uid].try(:[], :timestamp) && (Time.now - @@ipa_result[uid][:timestamp]) <= 30.seconds
      return
    end
      
    Rails.logger.debug "ipa_query() => " + @@ipa_result[uid].to_s

    begin 
      r = CwaRest.client({
        :verb => :POST,
        :url  => "https://" + Redmine::Cwa.ipa_server + "/ipa/json",
        :user => Redmine::Cwa.ipa_account,
        :password => Redmine::Cwa.ipa_password,
        :json => {
          'method' => 'user_show',
          'params' => [ [], { 'uid' => uid } ]
        }
      })
    rescue Exception => e
      raise e.message
    end
 
    Rails.logger.debug "ipa_query() => " + r.to_s
    if r != nil && r['result'] != nil 
      @@ipa_result = { uid => { :timestamp => Time.now, :result => r['result']['result'] } }
    else
      @@ipa_result = { uid => nil }
    end
  end

  # Populate custom_fields as accessible attributes
  def make_user_fields(user)
    @@fields[user.login] = Hash.new
    user.available_custom_fields.each do |field|
      @@fields[user.login][field.name.to_sym] = user.custom_field_value(field.id)
    end
    @@fields
  end

  # Do the work of adding or removing the user
  def provision(user, password, action)
    Rails.logger.debug "provision() => Current fields: " + @@fields[User.current.login].to_s

    if action == "user_add"
      raise 'You entered an incorrect password' if !self.valid_passwd?
      param_list = {
        'uid'  => user,
        'homedirectory' => "/home/#{user.each_char.first.downcase}/#{user.downcase}",
        'userpassword' => password
      }

      param_list.merge!({ 'uidnumber' => self.namsid }) if self.namsid != nil
      param_list.merge!({ 'givenname' => User.current.firstname })
      param_list.merge!({ 'sn' => User.current.lastname })
    else
      param_list = {
        'uid' => user
      }
    end

    Rails.logger.debug "provision() => param_list = " + param_list.to_s

    # Add the account to IPA
    begin
      r = CwaRest.client({
        :verb => :POST,
        :url  => "https://" + Redmine::Cwa.ipa_server + "/ipa/json",
        :user => Redmine::Cwa.ipa_account,
        :password => Redmine::Cwa.ipa_password,
        :json => { 'method' => action, 'params' => [ [], param_list ] }
      })
    rescue Exception => e
      raise e.message
    end

    # Force password expiry update
    if action == "user_add"
      pwexp = `/var/lib/redmine/plugins/cwa/support/pwexpupdate.sh #{user}`
      if $?.success?
        Rails.logger.info "User password expiry updated. " + pwexp
      else
        Rails.logger.info "Failed to update user password expiry! " + pwexp
      end
    end

    # TODO: parse out the details and return appropriate messages 
    if r['error'] != nil
      raise r['error']['message']
    end

    # Let NAMS know this is now an RC.USF.EDU user
    begin 
      r = CwaRest.client({
        :verb => :POST,
        :url  => Redmine::Cwa.msg_url,
        :user => Redmine::Cwa.msg_user,
        :password => Redmine::Cwa.msg_password,
        :json => { 
          'apiVersion' => '1',
          'createProg' => 'EDU:USF:RC:cwa',
          'messageData' => {
            'host' => 'rc.usf.edu',
            'username' => user,
            'accountStatus' => action == "user_add" ? 'active' : 'disabled',
            'accountType' => 'Unix'
          }
        }
      })
    rescue Exception => e
      raise e.message
    end
  end
end
