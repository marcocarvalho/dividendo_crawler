# frozen_string_literal: true

RSpec.describe DividendoCrawler::CashDividends do
  describe "#list" do
    let(:expected_result) do
      [
        {
          "closingPricePriorExDate"=>"30,28",
          "corporateAction"=>"DIVIDENDO",
          "corporateActionPrice"=>"3,817117",
          "dateApproval"=>"03/11/2022",
          "dateClosingPricePriorExDate"=>"21/11/2022",
          "lastDatePriorEx"=>"21/11/2022",
          "lastDateTimePriorEx"=>"2022-11-21T00:00:00",
          "quotedPerShares"=>"1",
          "ratio"=>"1",
          "typeStock"=>"ON",
          "valueCash"=>"1,155823"
        },
        {
          "closingPricePriorExDate"=>"30,28",
          "corporateAction"=>"DIVIDENDO",
          "corporateActionPrice"=>"5,284650",
          "dateApproval"=>"03/11/2022",
          "dateClosingPricePriorExDate"=>"21/11/2022",
          "lastDatePriorEx"=>"21/11/2022",
          "lastDateTimePriorEx"=>"2022-11-21T00:00:00",
          "quotedPerShares"=>"1",
          "ratio"=>"1",
          "typeStock"=>"ON",
          "valueCash"=>"1,600192"
        }
      ]
    end

    it "fetch all dividends to a given company" do
      VCR.use_cassette("dividend_list") do
        expect(described_class.list("PETROBRAS")).to eq(expected_result)
      end
    end

    it "work on no dividend company" do
      VCR.use_cassette("no_dividend_list") do
        expect(described_class.list("BLABLABLA")).to eq([])
      end
    end
  end
end
