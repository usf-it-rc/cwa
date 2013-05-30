require 'cwa_rest'
include ::CwaRest

class CwaIpaUser
  # This gets us all of our accessor methods for plugin settings
  # and ipa-based attributes
  attr_accessor :passwd, :user

  def initialize
    self.user = User.current

    Rails.cache.fetch("cached_user_fields_#{self.user.login}", :expires_in => 60.seconds) do
      make_user_fields
    end

    Rails.cache.fetch("cached_ipa_result_#{self.user.login}", :expires_in => 60.seconds) do
      ipa_query
    end
  end

  # this exposes ldap attributes and custom fields as methods
  def method_missing(name, *args, &blk)
    # If its an option in the fields hash, return it
    if args.empty? && blk.nil?
      fields = Rails.cache.fetch("cached_user_fields_#{self.user.login}", :expires_in => 60.seconds) do
        make_user_fields
      end

      Rails.logger.debug "MM() => #{fields.to_s}"

      if fields != nil && fields.has_key?(name)
        return fields[name.to_sym]
      end

      # Query IPA server or return cached values
      result = Rails.cache.fetch("cached_ipa_result_#{self.user.login}", :expires_in => 60.seconds) do
        ipa_query
      end

      Rails.logger.debug "MM() => #{result.to_s}"

      if result != nil && result.has_key?(name.to_s)
        return result[name.to_s].first
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
    result = Rails.cache.fetch("cached_ipa_result_#{self.user.login}", :expires_in => 60.seconds) do
      ipa_query
    end
    result != nil
  end

  # Force a full query on the next ipa_query run
  def refresh
    Rails.cache.clear("cached_ipa_result_#{self.user.login}") and 
      Rails.cache.clear("cached_user_fields_#{self.user.login}")
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
    Rails.logger.debug "create() => { " + User.current.login + ", " + self.passwd.to_s + ", user_add }"
    begin
      provision self.passwd, "user_add"
    rescue Exception => e
      raise e.message
    end
    self.refresh
  end

  def destroy
    begin
      provision nil, "user_del"
    rescue Exception => e
      raise e.message
    end
    self.refresh
  end

  # Get wonderful attributes from IPA server
  private
  def ipa_query
    begin 
      r = CwaRest.client({
        :verb => :POST,
        :url  => "https://" + Redmine::Cwa.ipa_server + "/ipa/json",
        :user => Redmine::Cwa.ipa_account,
        :password => Redmine::Cwa.ipa_password,
        :json => {
          'method' => 'user_show',
          'params' => [ [], { 'uid' => self.user.login } ]
        }
      })
    rescue Exception => e
      raise e.message
    end
 
    Rails.logger.debug "ipa_query() => " + r.to_s
    if r != nil && r['result'] != nil 
      r['result']['result']
    else
      nil
    end
  end

  # Populate custom_fields as accessible attributes
  def make_user_fields
    fields = Hash.new
    self.user.available_custom_fields.each do |field|
      fields[field.name.to_sym] = self.user.custom_field_value(field.id)
    end
    fields
  end

  # Do the work of adding or removing the user
  def provision(password, action)
    if action == "user_add"
      raise 'You entered an incorrect password' if !self.valid_passwd?
      param_list = {
        'uid'  => self.user.login.downcase,
        'homedirectory' => "/home/#{self.user.login.each_char.first.downcase}/#{self.user.login.downcase}",
        'userpassword' => password
      }

      param_list.merge!({ 'uidnumber' => self.namsid }) if self.namsid != nil
      param_list.merge!({ 'givenname' => self.user.firstname })
      param_list.merge!({ 'sn' => self.user.lastname })
    else
      param_list = {
        'uid' => self.user.login.downcase
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
      pwexp = `/var/lib/redmine/plugins/cwa/support/pwexpupdate.sh #{self.user.login.downcase}`
      if $?.success?
        Rails.logger.info "User password expiry updated. " + pwexp.to_s
      else
        Rails.logger.info "Failed to update user password expiry! " + pwexp.to_s
      end
    end

    # TODO: parse out the details and return appropriate messages 
    Rails.logger.debug "provision() => " + r.to_s
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
            'username' => self.user.login,
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
