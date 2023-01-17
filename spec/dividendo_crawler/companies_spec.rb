# frozen_string_literal: true

RSpec.describe DividendoCrawler::Companies do
  describe "#fetch" do
    let(:expected_result) do
      [
        {
          "codeCVM" => "917581",
          "companyName" => "2W ENERGIA S.A.",
          "issuingCompany" => "2WAV"
        },
        {
          "codeCVM" => "903898",
          "companyName" => "GAIA CRED IV COMPANHIA  SECURITIZADORA DE CREDITOS",
          "issuingCompany" => "GCIV",
          "market" => "",
          "segment" => "Não Classificados",
          "tradingName"=>"GAIACREDIVSE"
        }
      ]
    end

    it "fetch all the companies" do
      VCR.use_cassette("company_list") do
        expect(described_class.list).to eq(expected_result)
      end
    end
  end
end
