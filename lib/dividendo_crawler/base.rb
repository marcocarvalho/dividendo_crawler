# frozen_string_literal: true

class DividendoCrawler::Base
  attr_accessor :last_params

  class EmptyBodyError < StandardError; end

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
      @last_params = params(page).merge(prms)
      ps = get(@last_params).body

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
    get_params = {id_param_name => id}.merge(params)
    response = get(get_params)
    ret = response.body
    begin
      filter(JSON.parse(ret))
    rescue JSON::ParserError
      puts "Response: #{response.inspect}"
      puts "Params: #{get_params}"
      raise
    end
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
    return format_item(item) if allowed_keys.nil? || allowed_keys == :all

    format_item(item.slice(*allowed_keys))
  end

  def format_item(item)
    item
  end

  def format_integer(string)
    return string if string.nil? || string.empty?

    string.gsub(/\D/, "").to_i
  end

  def format_decimal(string)
    return string if string.nil? || string.empty?

    string.gsub(".", "").gsub(",", ".").to_f
  end

  def to_iso_date(string)
    return string if string.nil? || string.empty?

    string.split("/").reverse.join("-")
  end

  def allowed_keys
    :all
  end

  ClearLineEscape = "\r\e[K".freeze

  def get(prms)
    response = nil
    retries = 0
    exponential_backoff = 2
    begin
      response = connection.get("#{path}#{encode_params(prms)}")
      raise EmptyBodyError if response.body.to_s.empty? && (200..299).cover?(response.status) && retries <= 8

      response
    rescue EmptyBodyError => e
      retries += 1

      timeout = 2 ** retries * 0.5

      puts "#{ClearLineEscape}Empty body received, retrying in #{timeout}. Attempt ##{retries}..."

      sleep(timeout)

      retry
    end
  end

  private

  def headers = { "User-Agent" => user_agent }
  def base_url = "https://sistemaswebb3-listados.b3.com.br/"

  # CVM endpoints didn't accept faraday user-agent
  def user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
  end
end
