# frozen_string_literal: true

RSpec.describe DividendoCrawler::Company do
  describe "#fetch" do
    it "fetch a company" do
      VCR.use_cassette("company_detail") do
        expect(described_class.fetch("25070").keys).to eq(%w(issuingCompany companyName cnpj industryClassification
                                                             website code codeCVM lastDate otherCodes))
      end
    end
  end
end
