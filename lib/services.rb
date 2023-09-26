# frozen_string_literal: true

module Services
end

Dir[Pathname.new(File.dirname(__FILE__)).join("services/**/*.rb")].each do |f|
  require(f)
end
