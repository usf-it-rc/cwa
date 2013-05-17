class CwaBrowser
  attr_accessor :current_dir
  def initialize(dir)
    user = CwaIpaUser.new

    if dir !~ /#{user.homedirectory}/ and dir !~ /#{user.workdirectory}/ and dir !~ /\/shares\/.*/
      raise ArgumentError, "You cannot browse directories outside of your home, work, or group share paths."
    else
      self.current_dir = dir.chomp
    end
  end

  def up_dir
    Rails.logger.debug "up_dir() => " + self.current_dir.gsub(/(.*)\/.*$/, '\1')
    self.current_dir.gsub(/(.*)\/.*$/, '\1')
  end

  def directories
    dirs = Array.new
    lines = Redmine::CwaBrowserHelper.userexec("list #{self.current_dir} -- d")[0]
    #pipe = IO.popen("sudo -u #{User.current.login} find #{self.current_dir} ! -path #{self.current_dir} ! -type l ! -iname '.*' -maxdepth 1 -type d -printf \"%f\\n\" | sort -f")

    lines.each_line do |line| 
      entry = line.chomp.gsub("\"","")
      dirs.push entry if entry != ""
    end

    #pipe.close
    Rails.logger.debug "directories() => " + self.current_dir
    Rails.logger.debug "directories() => " + dirs.to_s
    return dirs
  end
  def files
    fs = Array.new
    lines = Redmine::CwaBrowserHelper.userexec("list #{self.current_dir} -- f")[0]
    #pipe = IO.popen("sudo -u #{User.current.login} find #{self.current_dir} ! -path #{self.current_dir} ! -type l ! -iname '.*' -maxdepth 1 -type f -printf \"%f\\n\" | sort -f")

    lines.each_line do |line| 
      entry = line.chomp.gsub("\"","")
      fs.push entry if entry != ""
    end

    #pipe.close
    Rails.logger.debug "files() => " + self.current_dir
    Rails.logger.debug "files() => " + fs.to_s
    return fs
  end
end
