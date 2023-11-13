# frozen_string_literal: true

return if defined?(Rails)

require "active_record"

class Models
  class Base < ActiveRecord::Base
    self.configurations = {
      default_env: {
        adapter: 'postgresql',
        host: 'localhost',
        username: 'root',
        password: '',
        database: 'b3'
      }
    }

    def self.underscore(camel_cased_word)
      return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
      word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
      word.tr!("-".freeze, "_".freeze)
      word.downcase!
      word
    end

    def underscore(...)
      self.class.underscore(...)
    end
  end
end

Models::Base.establish_connection

require_relative "tracked_fii"
require_relative "fii_dividend"
require_relative "cash_dividend"
require_relative "stock_dividend"
