module ActiveRecord
  class Base
    def self.find_or_create(key, params)
      where("#{key} = ?", params[key]).first || create(params)
    end
  end
end
