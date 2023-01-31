# Remember to touch tmp/caching-dev.txt for caching to work in dev
class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).cached_fetch
  end
  def self.uncached_call(*args, &block)
    new(*args, &block).fetch
  end

  def cached_fetch
    Rails.cache.fetch(cache_key, expires_in: expire_in || 24.hours) do
      fetch
    end
  end

  # next two methods are configuration and can be overridden by derived class
  def cache_key
    "#{self.class.name.underscore}/#{@id}"
  end
  def expire_in
    24.hours
  end
end
