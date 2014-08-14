module Cachoo
  MUTEX = Mutex.new
  CACHE = Hash.new do |h,k|
    h[k] = Hash.new { |h,k| h[k] = nil }
  end

  def self.for=(seconds)
    @_cache_time = seconds
  end

  def self.for
    @_cache_time ||= 60
  end

  def cachoo(*method_names)
    options = method_names.find { |i| i.is_a?(Hash) && method_names.delete(i) } || {}

    Array(method_names).each do |method_name|
      method_sym = :"__uncached_#{method_name}"

      alias_method method_sym, method_name
      remove_method method_name

      define_method(method_name) do |*args|
        signature = args.map(&:hash)
        c = CACHE[method_name]
        within = if !c[:call].nil?
                   c[:call] >= Time.now.utc - options.fetch(:for, Cachoo.for)
                 end

        if c[:signature] == signature && within
          MUTEX.synchronize { CACHE[method_name][:return] }
        else
          MUTEX.synchronize do
            CACHE[method_name] = {
              call: Time.now.utc,
              signature: signature,
              return: method(method_sym).call(*args)
            }
            CACHE[method_name][:return]
          end
        end
      end
    end
  end
end
