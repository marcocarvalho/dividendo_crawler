# frozen_string_literal: true

class DividendoCrawler::RadCVM < DividendoCrawler::Base
  def fetch(url)
    connection(url).get
  end

  def connection(url)
    @connection ||= Faraday.new(url:, headers:)
  end
end
