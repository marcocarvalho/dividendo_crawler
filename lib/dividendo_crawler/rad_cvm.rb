# frozen_string_literal: true

class DividendoCrawler::RadCVM < DividendoCrawler::Base
  def self.save(file, url)
    response = new.fetch(url)

    if file.respond_to?(:write)
      file.write(response.body)
    else
      File.write(file, response.body)
    end
  end

  def fetch(url)
    connection(url).get
  end

  def connection(url)
    @connection ||= Faraday.new(url:, headers:)
  end
end
