# frozen_string_literal: true

require "active_record"

class Models
  class Base < ActiveRecord::Base
    self.configurations = {
      default_env: {
        adapter: 'postgresql',
        host: 'localhost',
        username: 'postgres',
        password: 'postgres',
        database: 'b3'
      }
    }
  end
end

Models::Base.establish_connection

require_relative "tracked_fii"
