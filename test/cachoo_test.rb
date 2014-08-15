require 'cutest'
require 'cachoo'

setup do
  Cachoo.for = 0.5

  class Test
    extend Cachoo

    def now
      Time.now.to_f
    end

    def greet(name, &block)
      "Hello #{name} #{block.call}"
    end
    cachoo :now, :greet
  end

  class Other
    extend Cachoo

    def now
      Time.now.to_f
    end
  end

  class OtherTime
    extend Cachoo

    def kuak
      Time.now.to_f
    end
    cachoo :kuak, for: 1
  end
end

test "should be included" do
  assert Test.methods.include?(:cachoo)
end

test "should respect method arguments" do
  obj = Test.new
  assert obj.greet("Bob"){ "foo" } != obj.greet("Bob"){ "bar" }
end

test "should consider blocks as part of the args hash" do
  klass = Class.new do
            extend Cachoo
            def foo(&block)
              "#{Time.now.to_f} #{block.call}"
            end
            cachoo :foo, for: 1
          end

  obj = klass.new

  block_foo = -> { "foo" }
  block_bar = -> { "bar" }

  first_result = obj.foo(&block_foo)
  second_result = obj.foo(&block_bar)
  third_result = obj.foo(&block_foo)

  assert_equal first_result, third_result
  assert first_result != second_result
end

test "should cache a method call for 1 second" do
  obj = Test.new
  now = obj.now

  assert_equal obj.now, now

  sleep 1

  assert obj.now != now
end

test "cache different classes" do
  k1 = Test.new
  k2 = Other.new

  now = k1.now
  sleep 1
  assert now != k2.now
end

test "cache for different timespans" do
  time = OtherTime.new
  kuak = time.kuak

  assert_equal kuak, time.kuak
  sleep 0.5
  assert_equal kuak, time.kuak
  sleep 1
  assert kuak != time.kuak
end

test "each instance should have independent caches" do
  i1 = Test.new
  i2 = Test.new

  i1_result1 = i1.now
  i2_result1 = i2.now
  i1_result2 = i1.now
  i2_result2 = i2.now

  assert_equal i1_result1, i1_result2
  assert_equal i2_result1, i2_result2
  assert i1_result1 != i2_result1
end
