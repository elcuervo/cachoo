# Cachoo

Expirable memoization of methods

## Installation

```bash
gem install cachoo
```

## Usage

```ruby
class Cache
  extend Cachoo

  def now
    Time.now.utc
  end
  cachoo :now # :now gets cached for 5 seconds by default
end
```

```ruby
class Cache
  extend Cachoo

  def now
    Time.now.utc
  end
  cachoo :now, for: 60*60 # :now get cached for 1 hour
end
```

You can also ahange the time globally:

```ruby
Cachoo.for = 60*60*24 # 1 day cache
```

## Why?
I hate manually expiring memoization

## Name
It's an invented word betweeh `cache` and `achoo` :)
