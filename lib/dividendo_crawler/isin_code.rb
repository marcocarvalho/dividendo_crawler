# frozen_string_literal: true

class DividendoCrawler::IsinCode < DividendoCrawler::Base
  # https://sistemaswebb3-listados.b3.com.br/isinProxy/IsinCall/GetDetail/eyJpc2luIjoiQlJIR0NSQ1RGMDAwIn0=
  def path
    "isinProxy/IsinCall/GetDetail/"
  end

  def id_param_name
    "isin"
  end

  def self.fetch(isin_code)
    new.fetch(isin_code)
  end
end
