# app/models/machine.rb

class Machine < ApplicationRecord
  belongs_to :profile

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
    IFB
    Beko
    Other
  ].freeze

  MODELS = {
    "Samsung" => ["EcoBubble 9kg", "EcoBubble 8kg", "WashTower Combo", "AddWash 11kg", "AddWash 9kg",
                  "Bespoke AI 11kg", "Bespoke AI 9kg", "QuickDrive 8kg", "FlexWash 5.2kg", "EcoBubble 7kg"],
    "LG" => ["TurboWash 360 9kg", "TurboWash 360 8kg", "AI DD 10kg", "AI DD 9kg", "AI DD 8kg",
             "EZDispense 5.2kg", "TwinWash 9kg", "FrontLoad Steam 7kg", "TurboWash 11kg", "Vivace 9kg"],
    "Whirlpool" => ["SupremeCare 9kg", "SupremeCare 8kg", "FreshCare 7kg", "FreshCare 6kg", "6th Sense 9kg",
                    "6th Sense 8kg", "FreshCare+ 10kg", "ZEN Motor 9kg", "SteamCare 8kg", "QuietDrive 7kg"],
    "Bosch" => ["Serie 8 9kg", "Serie 8 10kg", "Serie 6 9kg", "Serie 6 8kg", "Serie 4 8kg", "Serie 4 7kg",
                "Serie 2 7kg", "HomeProfessional 9kg", "Serie 8 i-Dos 10kg", "Serie 6 i-Dos 9kg"],
    "Haier" => ["Intelius 959 10kg", "Intelius 959 9kg", "Intelius 969 10kg", "I-Pro Series 7 10kg",
                "I-Pro Series 5 9kg", "I-Pro Series 3 8kg", "HW100 Drum 10kg", "Direct Motion 9kg", "ABT 8kg", "Coral Black 10kg"],
    "Electrolux" => ["PerfectCare 9kg", "PerfectCare 8kg", "UltimateCare 900 9kg", "UltimateCare 700 8kg",
                     "UltimateCare 500 7kg", "SensorCare 8kg", "WashAndDry 8kg", "ComfortLift 8kg", "Woolmark 9kg", "EcoInverter 7kg"],
    "Miele" => ["WCB200 7kg", "WDB020 7kg", "WCI870 9kg", "WCR870 9kg", "WDD131 8kg", "WSI863 9kg", "WWD660 9kg",
                "WCI660 8kg", "WTD163 Washer-Dryer", "WSD663 Washer-Dryer"],
    "Siemens" => ["iQ700 10kg", "iQ700 9kg", "iQ500 9kg", "iQ500 8kg", "iQ300 8kg", "iQ300 7kg", "iQ100 7kg",
                  "iQ700 i-Dos 10kg", "iQ500 SelfCleaning 9kg", "iQ700 Washer-Dryer"],
    "Panasonic" => ["StainMaster+ 10kg", "StainMaster+ 9kg", "StainMaster+ 8kg", "ActiveFoam 9kg", "ActiveFoam 8kg",
                    "EcoNavi 10kg", "EcoNavi 9kg", "NA-S096 Washer-Dryer", "Heat Pump 8kg", "Slim Series 7kg"],
    "IFB" => ["Senator Plus 8kg", "Executive 7kg", "Elite Plus 7kg", "Senorita 6.5kg", "Neo Diva 6kg",
              "Senator WSS 6kg", "Executive VX 6.5kg", "Neo Diva WX 7kg", "Senator WXS 8kg", "Executive Plus 7.5kg"],
    "Beko" => ["UltraFast 9kg", "UltraFast 8kg", "SteamCure 10kg", "SteamCure 9kg", "ProSmart 9kg",
               "ProSmart 8kg", "AquaTech 10kg", "AquaTech 8kg", "AutoDose 9kg", "HygieneShield 9kg"]
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
