module Cachoo
  MUTEX = Mutex.new
  CACHE = Hash.new do |h,k|
    h[k] = Hash.new { |h,k| h[k] = nil }
  end

  def self.for=(seconds)
    @_cache_time = seconds
  end

  def self.sync(&block)
    MUTEX.synchronize(&block)
  end

  def self.for
    @_cache_time ||= 60
  end

  def cachoo(*method_names)
    options = method_names.find { |i| i.is_a?(Hash) && method_names.delete(i) } || {}
    expires_in = options.fetch(:for, Cachoo.for)

    Array(method_names).each do |method_name|
      method_sym = :"__uncached_#{method_name}"

      alias_method method_sym, method_name
      remove_method method_name

      define_method(method_name) do |*args|
        Thread.new do
          sleep expires_in
          Cachoo.sync { CACHE.delete(method_name) }
        end

        sig = args.map(&:hash)
        c = CACHE[method_name]

        return Cachoo.sync { CACHE[method_name][:return] } if c[:sig] == sig

        Cachoo.sync do
          ret = method(method_sym).call(*args)
          CACHE[method_name] = { sig: sig, return: ret }
          ret
        end
      end
    end
  end
end
