require 'hashie'
require 'multi_json'

module CheckoutRu
  class Entity < Hashie::Trash
    include Hashie::Extensions::Coercion

    def to_json(options = {})
      hash = self.to_hash
      CheckoutRu.camelize_keys!(hash)
      MultiJson.dump(hash, options.merge(:pretty => true))
    end
  end
end
