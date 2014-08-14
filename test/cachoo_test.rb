require 'cutest'
require 'cachoo'

setup do
  class Test
    extend Cachoo

    def now
      Time.now.utc
    end

    def greet(name)
      "Hello #{name}"
    end
    cachoo :now, :greet
  end

  class Other
    extend Cachoo

    def now
      Time.now.utc
    end
  end

  class OtherTime
    extend Cachoo

    def kuak
      Time.now.utc
    end
    cachoo :kuak, for: 2
  end

  Cachoo.for = 1
end

test "should be included" do
  assert Test.methods.include?(:cachoo)
end

test "should respect method arguments" do
  klass = Test.new
  assert klass.greet("Bob") != klass.greet("Dave")
end

test "should cache a method call for 1 second" do
  klass = Test.new
  now = klass.now

  assert_equal klass.now, now

  sleep 1

  assert klass.now != now
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
  sleep 1
  assert_equal kuak, time.kuak
  sleep 1
  assert kuak != time.kuak
end
