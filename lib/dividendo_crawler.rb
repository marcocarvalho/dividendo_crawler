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

  def self.save_idiv_dividends()
    fdividends = File.new("idiv_dividends.csv", "w+")
    fields = %w(
      codeCVM companyName tradingName segment
      corporateAction lastDateTimePriorEx closingPricePriorExDate corporateActionPrice
      quotedPerShares ratio typeStock valueCash
    )
    csv = CSV.new(fdividends, headers: fields)
    list = IndexComposition.list.map { |i| i["asset"] }
    list.each_with_index do |trading_name, idx|
      print "#{trading_name} - |#{idx}/#{list.size}|"
      dividends = CashDividends.list(trading_name)
      puts "#{dividends.count} |#{idx}/#{list.size}|"

      dividends.each do |div|
        dividend_format(div)
        csv << div.values_at(*fields)
      rescue NoMethodError => e
        puts div.inspect
        raise
      end
    end
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
require_relative "dividendo_crawler/fii_dividends"
require_relative "dividendo_crawler/fii_detail"
require_relative "dividendo_crawler/company_comunication_categories"
require_relative "dividendo_crawler/company_comunication_material"
require_relative "dividendo_crawler/rad_cvm"
require_relative "dividendo_crawler/index_composition"
require_relative "models/base"
require_relative "services"

# {"assetIssued"=>"BRHGCRR21M10",
#   "paymentDate"=>"14/04/2022",
#   "rate"=>"0,50000000000",
#   "relatedTo"=>"Março/2022",
#   "approvedOn"=>"31/03/2022",
#   "isinCode"=>"BRHGCRR21M10",
#   "label"=>"RENDIMENTO",
#   "lastDatePrior"=>"31/03/2022",
#   "remarks"=>""}

# CREATE TABLE public.tracked_fiis (
#   id integer NOT NULL,
#   trading_code text NOT NULL,
#   cnpj text not NULL,
#   next_sync_at timestamp
# );

# CREATE SEQUENCE tracked_fiis_id_seq
#   AS integer
#   START WITH 1
#   INCREMENT BY 1
#   NO MINVALUE
#   NO MAXVALUE
#   CACHE 1;

# ALTER SEQUENCE tracked_fii_id_seq OWNED BY tracked_fiis.id;

# ALTER TABLE ONLY public.tracked_fiis
#     ADD CONSTRAINT tracked_fiis_pkey PRIMARY KEY (id);

# ALTER TABLE ONLY public.tracked_fiis ALTER COLUMN id SET DEFAULT nextval('public.tracked_fiis_id_seq'::regclass);

# create unique index idx_trading_name_tracked_fiis on tracked_fiis (cnpj, trading_code);
# create index idx_next_approval_tracked_fiis on tracked_fiis (next_approval);

# CREATE TABLE public.fii_dividends (
#   id integer NOT NULL,
#   trading_name text NOT NULL,
#   payment_at timestamp NOT NULL,
#   rate numeric NOT NULL,
#   related_to text NOT NULL,
#   approved_at timestamp NOT NULL,
#   isin_code text NOT NULL,
#   label text NOT NULL,
#   ex_at timestamp NOT NULL, -- lastDatePrior
#   remarks text
# );

# CREATE SEQUENCE fii_dividends_id_seq
#     AS integer
#     START WITH 1
#     INCREMENT BY 1
#     NO MINVALUE
#     NO MAXVALUE
#     CACHE 1;

#ALTER TABLE ONLY public.fii_dividends ALTER COLUMN id SET DEFAULT nextval('public.fii_dividends_id_seq'::regclass);

# ALTER SEQUENCE fii_dividends_id_seq OWNED BY fii_dividends.id;

# ALTER TABLE ONLY public.fii_dividends
#     ADD CONSTRAINT fii_dividends_pkey PRIMARY KEY (id);

# ALTER TABLE ONLY public.cash_dividends
#     ADD CONSTRAINT cash_dividends_pkey PRIMARY KEY (id);

# create index idx_trading_name_fii on fii_dividends (trading_name);
# create index idx_date_fii on cash_dividends (ex_at);
# create unique index idx_payment_at_trading_name on fii_dividends (payment_at, isin_code, trading_name);

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

# ALTER TABLE ONLY public.cash_dividends ALTER COLUMN id SET DEFAULT nextval('public.cash_dividends_id_seq'::regclass);

# ALTER SEQUENCE cash_dividends_id_seq OWNED BY cash_dividends.id;

# create index idx_cvm_id on cash_dividends (code_cvm)
# create index idx_date on cash_dividends (ex_at)

# (id,code_cvm,company_name,trading_name,segment,corporate_action,ex_at,ex_closing_price,corporate_action_price,quoted_per_shares,ratio,type_stock,value_cash)
