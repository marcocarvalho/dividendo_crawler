# frozen_string_literal: true

class DividendoCrawler::FIIDetail < DividendoCrawler::Base
  def path
    "fundsProxy/fundsCall/GetDetailFundSIG/"
  end

  def id_param_name
    "identifierFund"
  end

  #{"typeFund":7,"identifierFund":"HGCR"}

  def self.fetch(trading_code)
    fii = new
    fii.merge_params(typeFund: 7)
    fii.fetch(trading_code[0..3])
  end
end
