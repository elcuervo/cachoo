module Cachoo
  class ConcurrentHash < Hash
    def initialize
      @lock = Mutex.new
      super
    end

    def []=(key, value)
      @lock.synchronize { super }
    end

    def delete(key)
      @lock.synchronize { super }
    end
  end
end
