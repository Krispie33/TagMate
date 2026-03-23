# app/models/machine.rb

class Machine < ApplicationRecord
  belongs_to :profile

  validates :brand, :model, presence: true

  # ─────────────────────────────────────────────
  # Constants
  # ─────────────────────────────────────────────
  BRANDS = %w[
    Samsung
    LG
    Whirlpool
    Bosch
    Haier
    Electrolux
    Miele
    Siemens
    Panasonic
    Beko
    IFB
    Other
  ].freeze

  MODELS = {
    "Samsung" => ["WW90T684DLN", "WF18T8000GW", "WD21T6300GW", "WW11BB944DGMS7", "WF45R6100AW", "WW90TA046AE",
                  "WW12BB944DGHS7", "WD80T554DBW", "WF50BG8300AW", "WW11DG5B25AW"],
    "LG" => ["F4V910WTSE", "WM4000HWA", "F6V1010WTSE", "WT7305CW", "WM3600HWA", "F4R5010WTSW", "WM6500HBA",
             "F8V910WTSE", "WT7800CW", "F4Y709WBTN1"],
    "Whirlpool" => ["WTW8127LW", "WFW9620HC", "WTW5000DW", "WFW6620HW", "WTW4816FW", "MVWB765FW", "WED9620HC",
                    "WFW8620HW", "WTW7120HW", "MVWC565FW"],
    "Bosch" => ["WAX32EH0GB", "WGG254A0GB", "WAJ28010GB", "WGG244A0GB", "WAX32KH1GB", "WGB256A0GB", "WAX32LH1GB",
                "WGB14600AU", "WAX28LH1GB", "WGB256A1GB"],
    "Haier" => ["HW100-B14979", "HW80-B14979", "HW100-B14TEAM5", "HW90-B14959U1", "HWD100-B14979", "HW120-B14979",
                "HW80-B12929", "HW70-B12929", "HWD80-B14979", "HW100-B12929"],
    "Electrolux" => ["EWF1042Q7WB", "ELFW7637AW", "EWF9042Q7WB", "ELFE7637AW", "EWF1041Q7WB", "EWW1042AEWA",
                     "ELFW7537AW", "EWF7042Q5WB", "EFLS627UIW", "EWW8094ADWA"],
    "Miele" => ["WCB200WCS", "WWD660WCS", "WDB020WCS", "WSI863WCS", "WCI870WCS", "WDD131WPS", "WCR870WPS",
                "WTD163WPM", "WCI660WPS", "WSD663WCS"],
    "Siemens" => ["WG54G2MCGB", "WM14VKH0GB", "WG42G2MCGB", "WM14UT89GB", "WG56G2MCGB", "WM14VMH0GB", "WG52G2MCGB",
                  "WM14NK20GB", "WG56B2040GB", "WN54G2MCGB"],
    "Panasonic" => ["NA-148XR1WGN", "NA-S096FR1WS", "NA-140XR1WGN", "NA-FW90X1", "NA-148MB3WGN", "NA-FS10X3WA",
                    "NA-120VC6WGN", "NA-140MB3WGN", "NA-W10X1", "NA-148VB3WGN"],
    "Beko" => ["WTL84151W", "WTL94151W", "WEC840522B", "WEX840430W", "WTL104151W", "WDEX8543430W", "WEY96052B",
               "WTL84151B", "WEC740435B", "WDEX8540430W"],
    "IFB" => ["Senator-WSS-Plus", "Executive-Wx", "Elite-Plus-Sx", "Senorita-Sx", "Neo-Diva-Sx",
              "Senator-WSS-6010", "Elite-Plus-Vx", "Neo-Diva-WX", "Senator-WXS", "Executive-Plus-Vx"]
  }.freeze

  # ─────────────────────────────────────────────
  # Helpers
  # ─────────────────────────────────────────────

  # Returns models for the machine's current brand
  def available_models
    MODELS.fetch(brand, [])
  end

  # All models across every brand, flattened
  def self.all_models
    MODELS.values.flatten
  end

  # Find which brand a model string belongs to
  def self.brand_for_model(model_name)
    MODELS.find { |_, models| models.include?(model_name) }&.first
  end
end
