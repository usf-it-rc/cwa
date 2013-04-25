require "open3"
require "base64"

module Redmine::CwaBrowserHelper
  class << self
    def chmod(file, mode)
      userexec "chmod #{mode} #{file}" == 0 ? true : false
    end

    def rename(file, new_name)
      userexec "mv #{file} #{new_name}" == 0 ? true : false
    end

    def write(path, remote_file)
      name =  remote_file['datafile'].original_filename
      content = Base64.encode64(remote_file['datafile'].read)
      
      content.each_line do |line|
        userexec "base64 -d #{line} | tee -a #{path}/#{name}" or return false
      end

    end

    def delete(file)
      userexec "rm -rf #{file}" == 0 ? true : false
    end

    def file_size(file)
      (size,err,code) = userexec "stat -c \"%s\" #{file}"
      size = size.chomp.to_i
      size
    end

    # Wicked cool privileged file reader implementation
    class Redmine::CwaBrowserHelper::Retrieve
      @stdout = nil
      @stdin = nil
      @stderr = nil
      @wait_thr = nil
      
      def initialize(file)
        @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(
          "sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh dd bs=#{1024*128} if=#{file}"
          )
        pid = @wait_thr[:pid]
      end

      def each
        while (data = @stdout.read(1024*128)) != nil
          self.done if data.length < 1024*128
          yield data
        end
      end

      def done
        @stdout.close
        @stdin.close
        @stderr.close
        exit_status = @wait_thr.value
        return exit_status
      end
    end

    def tail(file,offset)
      nil
    end

    private
    def userexec(cmd)
      output = ""
      error  = ""

      stdin, stdout, stderr, wait_thr = Open3.popen3("sudo -u #{User.current.login} /usr/bin/cwabrowserhelper.sh " + cmd, :chdir => "/tmp")

      pid = wait_thr[:pid]
      stdin.close
      stdout.each_line { |line| output += line }
      stderr.each_line { |line| error += line }
      stdout.close
      stderr.close
      exit_status = wait_thr.value

      return [output,error,exit_status] 
    end

  end
end
