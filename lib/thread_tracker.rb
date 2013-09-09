class ThreadTracker < Thread

  attr_accessor :tid, :opid, :thread, :pool, :user, :timeout, :expired
  @@object_pool = []
  @@lock = Mutex.new
  
  def initialize(&block)

    self.user = User.current.login
    self.opid = Digest::SHA512.hexdigest("ThreadTrackerSalt" + 
      (Time.now.to_i+Time.now.tv_usec+Time.now.tv_nsec).to_s + block.to_s)

    # add this to op thread cache
    thread_list = Rails.cache.read("#{self.user}_thread_list")
    if thread_list.nil?
      Rails.cache.write("#{self.user}_thread_list", { self.opid => nil})
    else
      thread_list.merge!({self.opid => nil})
      Rails.cache.write("#{self.user}_thread_list", thread_list)
    end

    self.status = { :status => "Starting" }

    # add cache entry item
    Rails.cache.write(self.opid, self.status)

    # kick off actual background task
    self.thread = super do
      Thread.current.thread_variable_set(:opid, self.opid)
      begin
        yield block
      ensure
        Rails.logger.flush
      end
      Thread.current.exit
    end

    # Still need this for find_thread_by_opid to work
    @@lock.synchronize do
      @@object_pool << self
    end
    self
  end  

  def expire
    return if self.expired?
    Rails.cache.write(self.opid, Rails.cache.read(self.opid), :expires_in => 60.seconds)
    t_list = Rails.cache.read("#{User.current.login}_thread_list")
    t_list[self.opid] = Time.now + 30.seconds
    Rails.cache.write("#{User.current.login}_thread_list", t_list)
    self.expired = true
    self.kill
  end

  def expired?
    self.expired
  end

  def status=(stat)
    cur_stat = Rails.cache.read(self.opid)
    Rails.cache.write(self.opid, cur_stat.nil? ? stat : cur_stat.merge(stat))
  end

  def status
    Rails.cache.read(self.opid)
  end

  # Here's our class methods
  class << self
    # clean up old threads
    def gc
      @@lock.synchronize do
        @@object_pool.each { |t| t.expire if !t.alive? }
      end
      
      # delete any old opids from the opid list
      t_list = Rails.cache.read("#{User.current.login}_thread_list")
      if !t_list.nil?
        t_list.keys.each { |o| t_list.delete(o) if !t_list[o].nil? and t_list[o] <= Time.now }
        Rails.cache.write("#{User.current.login}_thread_list", t_list)
      end
    end

    def my_ops
      t_list = Rails.cache.read("#{User.current.login}_thread_list")
      return t_list.nil? ? nil : t_list.keys
    end 

    def current
      opid = Thread.current.thread_variable_get(:opid)
      return opid.nil? ? nil : find_thread_by_opid(opid)
    end

    def cache_status(opid)
      return { opid => Rails.cache.read(opid) }
    end

    def find_thread_by_opid(opid)
      @@lock.synchronize do
        return @@object_pool.select {|t| t.opid == opid }.first
      end
    end
  end

end
