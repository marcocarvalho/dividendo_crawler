# frozen_string_literal: true

require_relative "dividendo_crawler/version"
require "base64"
require "csv"
require "faraday"
require "json"
require "byebug"
require "ruby-progressbar"

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

  def self.save_idiv_dividends
    fdividends = File.new("idiv_dividends.csv", "w+")
    fields = %w(
      companyName tradingName corporateAction lastDateTimePriorEx year closingPricePriorExDate corporateActionPrice
      ratio typeStock valueCash
    )
    csv = CSV.new(fdividends, headers: fields, quote_char: '"', write_headers: true, force_quotes: true)
    list = IndexComposition.list("IDIV").map { |i| [i["asset"], i["cod"]] }
    list.each_with_index do |(company_name, trading_name), idx|
      print "#{company_name} - |#{idx}/#{list.size}|"
      dividends = CashDividends.list(company_name)
      puts "#{dividends.count} |#{idx}/#{list.size}|"

      dividends.each do |div|
        idividend_format(div)
        finalnumber = {
          "ON" => "3",
          "PN" => "4",
          "UNT" => "11",
          "PNA" => "5",
          "PNB" => "6",
        }[div["typeStock"]] || (raise "Invalid typeStock #{div['typeStock']}")

        tname = trading_name.gsub(/\d+/, finalnumber)

        csv << [company_name, tname] + div.values_at(*fields[2..-1])
      rescue NoMethodError => e
        puts div.inspect
        raise
      end
    end

    csv.close
    fdividends.close
  end

  def self.format_number(str)
    if str.is_a?(Numeric)
      str.to_s.gsub(".", ",")
    elsif str.is_a?(String)
      str.gsub(",", "").gsub(".", ",")
    elsif str.nil?
      "0"
    else
      raise InvalidArgument, "Invalid argument #{str.inspect}"
    end
  end

  def self.dividend_format(div)
    %w(closingPricePriorExDate corporateActionPrice ratio valueCash).each do |f|
      div[f] = format_number(div[f])
    end
  end

  def self.idividend_format(div)
    dividend_format(div)
    div["year"] = Time.parse(div["lastDateTimePriorEx"]).year
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
require_relative "dividendo_crawler/suplementary"
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

# drop table public.cash_dividends if exists public.cash_dividends;

# CREATE TABLE public.cash_dividends (
#   id integer NOT NULL,
#   approved_on timestamp,
#   last_date_prior timestamp,
#   rate numeric not null,
#   payment_date timestamp NOT NULL,
#   asset_issued text NOT NULL,
#   trading_code text not null,
#   type_stock text not null,
#   related_to text,
#   label text,
#   remarks text
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

# ALTER TABLE cash_dividends ADD PRIMARY KEY (id);

# CREATE UNIQUE INDEX unique_idx_cash_dividend ON cash_dividends (approved_on, asset_issued, trading_code, related_to);

# {:assetIssued=>"BRPETRACNPR6",
#   :paymentDate=>"2023-01-19",
#   :rate=>0.074258,
#   :relatedTo=>"3º Trimestre/2022",
#   :approvedOn=>"2022-11-03",
#   :isinCode=>"BRPETRACNPR6",
#   :label=>"JRS CAP PROPRIO",
#   :lastDatePrior=>"2022-11-21",
#   :remarks=>"",
#   :trading_code=>"PETR4",
#   :typeStock=>"PN"}


# CREATE TABLE public.stock_dividends (
#   id integer NOT NULL,
#   approved_on timestamp,
#   last_date_prior timestamp,
#   multiplier numeric not null,
#   factor numeric not null,
#   asset_issued text NOT NULL,
#   trading_code text not null,
#   type_stock text,
#   related_to text,
#   label text,
#   remarks text
# );

# CREATE SEQUENCE stock_dividends_id_seq
#     AS integer
#     START WITH 1
#     INCREMENT BY 1
#     NO MINVALUE
#     NO MAXVALUE
#     CACHE 1;

# ALTER TABLE ONLY public.stock_dividends ALTER COLUMN id SET DEFAULT nextval('public.stock_dividends_id_seq'::regclass);

# ALTER SEQUENCE stock_dividends_id_seq OWNED BY stock_dividends.id;

# ALTER TABLE stock_dividends ADD PRIMARY KEY (id);

# CREATE UNIQUE INDEX unique_idx_stock_dividend ON stock_dividends (approved_on, asset_issued, trading_code, related_to);