# frozen_string_literal: true

class DividendoCrawler::RadCVM < DividendoCrawler::Base
  def self.save_from_material(material)
    save(file_name_from_material(material), material["urlDownload"])
  end

  def self.file_name_from_material(material)
    puts material.inspect
    url = material["urlDownload"]
    code_cvm, trading_name = material["company"].slice("codeCVM", "tradingName").values
    seq = url.match(/numSequencia=(\d+)/)[1]
    ver = url.match(/numVersao=(\d+)/)[1]
    pro = url.match(/numProtocolo=(\d+)/)[1]
    date = material["deliveryDateTime"][0..9]

    "#{[date, seq, pro, "v#{ver}", code_cvm, trading_name.to_s.downcase].join("-")}.pdf"
  end

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
