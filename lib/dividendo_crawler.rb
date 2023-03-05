# frozen_string_literal: true

require_relative "dividendo_crawler/version"
require "base64"
require "csv"
require "faraday"
require "json"

class DividendoCrawler
  def self.save_dividends(filter = {})
    fdividends = File.new("dividends.csv", "w+")
    fields = %w(
      codeCVM companyName tradingName segment
      corporateAction lastDateTimePriorEx closingPricePriorExDate corporateActionPrice
      quotedPerShares ratio typeStock valueCash
    )
    list = Companies.reduced_list
    csv = CSV.new(fdividends, headers: fields)
    list.each_with_index do |cia, idx|
      print "#{cia['companyName']} #{cia['market']} - "
      dividends = CashDividends.list(cia["tradingName"])
      puts "#{dividends.count} |#{idx}/#{list.size}|"

      dividends.each do |div|
        dividend_format(div)
        csv << div.merge(cia).values_at(*fields)
      rescue NoMethodError => e
        puts div.inspect
        raise
      end
    end
    csv.close
    fdividends.close
  end

  def self.format_number(str)
    str&.gsub(",", ".") || "0"
  end

  def self.dividend_format(div)
    %w(closingPricePriorExDate corporateActionPrice valueCash).each do |f|
      div[f] = format_number(div[f])
    end
  end
end

require_relative "dividendo_crawler/base"
require_relative "dividendo_crawler/cash_dividends"
require_relative "dividendo_crawler/companies"
require_relative "dividendo_crawler/company"
require_relative "dividendo_crawler/isin_code"


# CREATE TABLE public.cash_dividends (
#   id integer NOT NULL,
#   code_cvm integer not null,
#   company_name text not null,
#   trading_name text not null,
#   segment text not null,
#   corporate_action text not null,
#   ex_at timestamp not null,
#   ex_closing_price numeric,
#   corporate_action_price numeric,
#   quoted_per_shares numeric,
#   ratio numeric,
#   type_stock text not null,
#   value_cash numeric not null
# );

# CREATE SEQUENCE cash_dividends_id_seq
#     AS integer
#     START WITH 1
#     INCREMENT BY 1
#     NO MINVALUE
#     NO MAXVALUE
#     CACHE 1;

# ALTER SEQUENCE cash_dividends_id_seq OWNED BY cash_dividends.id;

# create index idx_cvm_id on cash_dividends (code_cvm)
# create index idx_date on cash_dividends (ex_at)

# (id,code_cvm,company_name,trading_name,segment,corporate_action,ex_at,ex_closing_price,corporate_action_price,quoted_per_shares,ratio,type_stock,value_cash)
