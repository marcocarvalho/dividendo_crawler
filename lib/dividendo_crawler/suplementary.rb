# frozen_string_literal: true

class DividendoCrawler::Suplementary < DividendoCrawler::Base
  def path
    "listedCompaniesProxy/CompanyCall/GetListedSupplementCompany/"
  end

  # "codeCVM":"25070"

  def allowed_keys
    %w(tradingName
       numberCommonShares
       numberPreferredShares
       totalNumberShares
       code
       codeCVM
       stockDividends
       subscriptions)
  end

  def filter(item)
    new_item = super(item.first)
    new_item["numberCommonShares"] = format_decimal(new_item["numberCommonShares"])
    new_item["numberPreferredShares"] = format_decimal(new_item["numberPreferredShares"])
    new_item["totalNumberShares"] = format_decimal(new_item["totalNumberShares"])
    new_item["stockDividends"] = format_stock_dividends(new_item["stockDividends"])
    # new_item["subscriptions"] = format_subscriptions(new_item["code"], new_item["subscriptions"])
    new_item
  end

  def format_stock_dividends(items)
    items.map { |item| format_stock_dividend(item) }
  end

  def type_to_number(type)
    {
      "OR" => "3",
      "PR" => "4",
      "UNT" => "11",
      "PA" => "5",
      "PB" => "6",
    }[type]
  end

  # "assetIssued"=>"BRPETRACNPR6",
  # "factor"=>"33,33333333300",
  # "approvedOn"=>"25/03/1994",
  # "isinCode"=>"BRPETRACNPR6",
  # "label"=>"BONIFICACAO",
  # "lastDatePrior"=>"25/03/1994",
  # "remarks"=>""
  def format_stock_dividend(item)
    new_item = { **item }
    _, code, type = new_item["assetIssued"].match(/.{2}(.{4}).{3}(.{2})\d/).to_a
    tp = type_to_number(type)
    warn "Unknown type: #{type} from isin code: #{new_item["assetIssued"]}" if tp.nil?
    new_item["trading_code"] = "#{code}#{tp}"
    new_item["multiplier"] = multiplier(new_item["factor"], new_item["label"])
    new_item
  end

  def multiplier(factor, label)
    case label.downcase.to_sym
    when :desdobramento, :bonificacao
      (factor.gsub(",", ".").to_f / 100) + 1
    when :grupamento
      factor.gsub(",", ".").to_f
    else
      warn "Unknown label: #{label} for multiplier: #{factor}"
      0
    end
  end

  def format_subscriptions(items)
    items.map { |item| format_subscription(item) }
  end

  def id_param_name
    "issuingCompany"
  end

  def self.fetch(code_cvm)
    new.fetch(code_cvm)
  end
end
