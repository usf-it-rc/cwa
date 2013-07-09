class CwaBrowser
  attr_accessor :current_dir, :current_share, :current_path
  def initialize(share, dir)
    user = CwaIpaUser.new

    case share
    when "home"
      path = user.homedirectory + "/" + dir.to_s
    when "shares"
      path = "/shares/" + dir
    when "work"
      path = user.workdirectory + "/" + dir.to_s
    else
      raise ArgumentError, "You cannot browse directories outside of your home, work, or group share paths."
    end

    if Redmine::CwaBrowserHelper.type(path) !~ /application\/x\-directory/
      raise ArgumentError, "No such directory!"
    end

    self.current_dir = dir.to_s.chomp.to_s
    self.current_share = share.chomp
    self.current_path = path

  end

  # Return string of one directory up
  def up_dir
    Rails.logger.debug "up_dir() => " + self.current_dir.gsub(/(.*)\/.*$/, '\1')
    self.current_dir.gsub(/(.*)\/.*$/, '\1')
  end

  # return list of directories in the current path
  def directories
    dirs = Array.new
    lines = Redmine::CwaBrowserHelper.userexec("list #{self.current_path} -- d")[0]

    lines.each_line do |line| 
      entry = line.chomp.gsub("\"","")
      dirs.push entry if entry != ""
    end

    Rails.logger.debug "directories() => " + self.current_path
    Rails.logger.debug "directories() => " + dirs.to_s
    return dirs
  end

  # return list of files in the current path
  def files
    fs = Array.new
    lines = Redmine::CwaBrowserHelper.userexec("list #{self.current_path} -- f")[0]

    lines.each_line do |line| 
      entry = line.chomp.gsub("\"","")
      fs.push entry if entry != ""
    end

    Rails.logger.debug "files() => " + self.current_path
    Rails.logger.debug "files() => " + fs.to_s
    return fs
  end
end
