# frozen_string_literal: true

class DividendoCrawler::Base
  def self.list(...)
    new.list(...)
  end

  def self.fetch(...)
    new.fetch(...)
  end

  def list(prms = {})
    page = 1
    result = []

    loop do
      ps = get(params(page).merge(prms)).body

      ps = JSON.parse(ps) if reparse? # some endpoints don't return the correct header

      result << filter_results(result_from_field(ps))

      break if !ps.is_a?(Hash) || ps["page"].nil? || ps["page"]["pageNumber"].nil?

      page = ps["page"]["pageNumber"] + 1

      break if ps["page"]["pageNumber"] >= ps["page"]["totalPages"]
    end

    result.flatten
  end

  def result_from_field(response)
    return response unless result_collection_name.present?

    response[result_collection_name]
  end

  def fetch(id)
    filter(JSON.parse(get(params.merge(id_param_name => id)).body))
  end

  def reparse?
    false
  end

  def log?
    false
  end

  def result_collection_name
    "results"
  end

  def filter_results(results)
    results.map { |i| filter(i) }
  end

  def connection
    @connection ||= Faraday.new(url: base_url, headers:) do |f|
      f.request :json # encode req bodies as JSON and automatically set the Content-Type header
      f.response :logger if log?
      f.response :json # decode response bodies as JSON
    end
  end

  def encode_params(params)
    Base64.encode64(params.to_json).gsub("\n", "")
  end

  def params(page = nil)
    base_params.merge(language: "pt-br").tap do |prms|
      prms.merge!({ pageNumber: page, pageSize: 1000 }) unless page.nil?
    end
  end

  def base_params
    @base_params ||= {}
  end

  def merge_params(hash)
    @base_params = base_params.merge(hash)
  end

  def filter(item)
    return item if allowed_keys.nil? || allowed_keys == :all

    item.slice(*allowed_keys)
  end

  def allowed_keys
    :all
  end

  def get(prms)
    connection.get("#{path}#{encode_params(prms)}")
  end

  private

  def headers = { "User-Agent" => user_agent }
  def base_url = "https://sistemaswebb3-listados.b3.com.br/"

  # CVM endpoints didn't accept faraday user-agent
  def user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
  end
end
