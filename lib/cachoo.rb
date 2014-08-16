require 'cachoo/concurrent_hash'

module Cachoo
  def self.for=(seconds)
    @cachoo_cache_time = seconds
  end

  def self.for
    @cachoo_cache_time ||= 5
  end

  def create_cached_methods_module(method_names, expires_in)
    Module.new do
      def cachoo_instance_cache
        @cachoo_instance_cache ||= ConcurrentHash.new
      end

      method_names.each do |method_name|
        define_method(method_name) do |*args, &block|
          sig = [method_name, args, block].hash

          cachoo_instance_cache.fetch(sig) do
            super(*args, &block).tap do |result|
              cachoo_instance_cache[sig] = result

              Thread.new do
                sleep(expires_in)
                cachoo_instance_cache.delete(sig)
              end
            end
          end
        end
      end
    end
  end

  def cachoo(*method_names, for: Cachoo.for)
    # 'for' is a reserved word in ruby so we can only get it through the binding
    expires_in = binding.local_variable_get(:for)
    cached_methods_module = create_cached_methods_module(method_names, expires_in)
    prepend(cached_methods_module)
  end
end
