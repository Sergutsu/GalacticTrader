module Models.Good exposing (Good, GoodType(..), allGoods, goodName, goodBasePrice, goodBaseStock, goodCategory)

{-| This module defines the types and functions related to goods in the Galactic Trader game.
It includes all tradable commodities and their base properties.
-}


type alias Good =
    { price : Int
    , stock : Int
    , baseStock : Int  -- The base/initial stock level for price calculations
    , goodType : GoodType
    }


type GoodType
    -- Basic Resources
    = Water
    | FoodRations
    | Minerals
    | Metals
    | Gases
    | RadioactiveMaterials
    | Crystals
    | ExoticMinerals
    
    -- Processed Materials
    | RefinedMetals
    | IndustrialChemicals
    | Plastics
    | ConstructionMaterials
    | Electronics
    | MachineParts
    | Robotics
    | Nanomaterials
    
    -- Consumer Goods
    | ConsumerGoods
    | LuxuryGoods
    | MedicalSupplies
    | Pharmaceuticals
    | Alcohol
    | Narcotics
    | Tobacco
    | Clothing
    | Furniture
    | ElectronicsGoods
    | HouseholdGoods
    
    -- Technology
    | Computers
    | ResearchEquipment
    | ScientificInstruments
    | AIComponents
    | Cybernetics
    | HolographicTechnology
    | QuantumProcessors
    | FusionReactors
    
    -- Military
    | Weapons
    | Ammunition
    | Armor
    | MilitaryVehicles
    | MilitarySupplies
    | MilitaryRobots
    | MilitaryDrones
    | StarshipWeapons
    | StarshipShields
    | StarshipEngines
    
    -- Spacecraft
    | SmallCraft
    | Shuttles
    | Freighters
    | MiningShips
    | ScienceVessels
    | MilitaryShips
    | CapitalShips
    | SpaceStations
    
    -- Special
    | Artifacts
    | Relics
    | AncientTechnology
    | AlienArtifacts
    | BlackMarketGoods
    | Slaves
    | WMDs
    
    -- Services
    | Information
    | HackingTools
    | SecuritySystems
    | MedicalServices
    | Entertainment
    | Prostitution
    | Smuggling
    | BountyHunting
    | MercenaryServices
    | Piracy
    
    -- Raw Materials
    | OrganicMaterials
    | BiohazardousMaterials
    | ToxicWaste
    | ScrapMetal
    | Recyclables
    | Fuel
    | Oxygen
    | Hydrogen
    | Helium3
    | Antimatter
    | DarkMatter
    | ExoticMatter
    | QuantumFoam
    | Neutronium
    | Unobtanium


{-| Get the display name of a good
-}
goodName : GoodType -> String
goodName goodType =
    case goodType of
        -- Basic Resources
        Water -> "Water"
        FoodRations -> "Food Rations"
        Minerals -> "Minerals"
        Metals -> "Metals"
        Gases -> "Industrial Gases"
        RadioactiveMaterials -> "Radioactive Materials"
        Crystals -> "Crystals"
        ExoticMinerals -> "Exotic Minerals"
        
        -- Processed Materials
        RefinedMetals -> "Refined Metals"
        IndustrialChemicals -> "Industrial Chemicals"
        Plastics -> "Plastics"
        ConstructionMaterials -> "Construction Materials"
        Electronics -> "Electronics"
        MachineParts -> "Machine Parts"
        Robotics -> "Robotics"
        Nanomaterials -> "Nanomaterials"
        
        -- Consumer Goods
        ConsumerGoods -> "Consumer Goods"
        LuxuryGoods -> "Luxury Goods"
        MedicalSupplies -> "Medical Supplies"
        Pharmaceuticals -> "Pharmaceuticals"
        Alcohol -> "Alcohol"
        Narcotics -> "Narcotics"
        Tobacco -> "Tobacco"
        Clothing -> "Clothing"
        Furniture -> "Furniture"
        ElectronicsGoods -> "Electronics Goods"
        HouseholdGoods -> "Household Goods"
        
        -- Technology
        Computers -> "Computers"
        ResearchEquipment -> "Research Equipment"
        ScientificInstruments -> "Scientific Instruments"
        AIComponents -> "AI Components"
        Cybernetics -> "Cybernetics"
        HolographicTechnology -> "Holographic Technology"
        QuantumProcessors -> "Quantum Processors"
        FusionReactors -> "Fusion Reactors"
        
        -- Military
        Weapons -> "Weapons"
        Ammunition -> "Ammunition"
        Armor -> "Armor"
        MilitaryVehicles -> "Military Vehicles"
        MilitarySupplies -> "Military Supplies"
        MilitaryRobots -> "Military Robots"
        MilitaryDrones -> "Military Drones"
        StarshipWeapons -> "Starship Weapons"
        StarshipShields -> "Starship Shields"
        StarshipEngines -> "Starship Engines"
        
        -- Spacecraft
        SmallCraft -> "Small Craft"
        Shuttles -> "Shuttles"
        Freighters -> "Freighters"
        MiningShips -> "Mining Ships"
        ScienceVessels -> "Science Vessels"
        MilitaryShips -> "Military Ships"
        CapitalShips -> "Capital Ships"
        SpaceStations -> "Space Stations"
        
        -- Special
        Artifacts -> "Artifacts"
        Relics -> "Relics"
        AncientTechnology -> "Ancient Technology"
        AlienArtifacts -> "Alien Artifacts"
        BlackMarketGoods -> "Black Market Goods"
        Slaves -> "Slaves"
        WMDs -> "Weapons of Mass Destruction"
        
        -- Services
        Information -> "Information"
        HackingTools -> "Hacking Tools"
        SecuritySystems -> "Security Systems"
        MedicalServices -> "Medical Services"
        Entertainment -> "Entertainment"
        Prostitution -> "Prostitution"
        Smuggling -> "Smuggling Services"
        BountyHunting -> "Bounty Hunting"
        MercenaryServices -> "Mercenary Services"
        Piracy -> "Piracy Services"
        
        -- Raw Materials
        OrganicMaterials -> "Organic Materials"
        BiohazardousMaterials -> "Biohazardous Materials"
        ToxicWaste -> "Toxic Waste"
        ScrapMetal -> "Scrap Metal"
        Recyclables -> "Recyclables"
        Fuel -> "Fuel"
        Oxygen -> "Oxygen"
        Hydrogen -> "Hydrogen"
        Helium3 -> "Helium-3"
        Antimatter -> "Antimatter"
        DarkMatter -> "Dark Matter"
        ExoticMatter -> "Exotic Matter"
        QuantumFoam -> "Quantum Foam"
        Neutronium -> "Neutronium"
        Unobtanium -> "Unobtanium"


{-| Get the base price of a good
-}
goodBasePrice : GoodType -> Int
goodBasePrice goodType =
    case goodType of
        -- Basic Resources (10-100)
        Water -> 10
        FoodRations -> 15
        Minerals -> 20
        Metals -> 30
        Gases -> 25
        RadioactiveMaterials -> 50
        Crystals -> 40
        ExoticMinerals -> 80
        
        -- Processed Materials (50-200)
        RefinedMetals -> 50
        IndustrialChemicals -> 60
        Plastics -> 40
        ConstructionMaterials -> 45
        Electronics -> 100
        MachineParts -> 120
        Robotics -> 200
        Nanomaterials -> 300
        
        -- Consumer Goods (20-500)
        ConsumerGoods -> 50
        LuxuryGoods -> 200
        MedicalSupplies -> 150
        Pharmaceuticals -> 180
        Alcohol -> 30
        Narcotics -> 250
        Tobacco -> 40
        Clothing -> 25
        Furniture -> 100
        ElectronicsGoods -> 150
        HouseholdGoods -> 80
        
        -- Technology (200-1000)
        Computers -> 200
        ResearchEquipment -> 500
        ScientificInstruments -> 400
        AIComponents -> 800
        Cybernetics -> 700
        HolographicTechnology -> 600
        QuantumProcessors -> 1000
        FusionReactors -> 900
        
        -- Military (100-2000)
        Weapons -> 200
        Ammunition -> 100
        Armor -> 300
        MilitaryVehicles -> 500
        MilitarySupplies -> 150
        MilitaryRobots -> 800
        MilitaryDrones -> 600
        StarshipWeapons -> 1500
        StarshipShields -> 1800
        StarshipEngines -> 2000
        
        -- Spacecraft (1000-10000)
        SmallCraft -> 1000
        Shuttles -> 2000
        Freighters -> 5000
        MiningShips -> 4000
        ScienceVessels -> 6000
        MilitaryShips -> 8000
        CapitalShips -> 10000
        SpaceStations -> 50000
        
        -- Special (500-10000)
        Artifacts -> 1000
        Relics -> 2000
        AncientTechnology -> 5000
        AlienArtifacts -> 10000
        BlackMarketGoods -> 500
        Slaves -> 300
        WMDs -> 5000
        
        -- Services (100-5000)
        Information -> 100
        HackingTools -> 300
        SecuritySystems -> 400
        MedicalServices -> 200
        Entertainment -> 150
        Prostitution -> 100
        Smuggling -> 500
        BountyHunting -> 1000
        MercenaryServices -> 2000
        Piracy -> 5000
        
        -- Raw Materials (5-500)
        OrganicMaterials -> 20
        BiohazardousMaterials -> 100
        ToxicWaste -> 5
        ScrapMetal -> 10
        Recyclables -> 8
        Fuel -> 15
        Oxygen -> 12
        Hydrogen -> 10
        Helium3 -> 50
        Antimatter -> 500
        DarkMatter -> 400
        ExoticMatter -> 300
        QuantumFoam -> 200
        Neutronium -> 1000
        Unobtanium -> 10000


{-| Get the base stock level for a good
-}
goodBaseStock : GoodType -> Int
goodBaseStock goodType =
    case goodType of
        -- High availability
        Water -> 1000
        FoodRations -> 800
        Minerals -> 600
        Metals -> 500
        Gases -> 400
        ScrapMetal -> 300
        Recyclables -> 400
        Fuel -> 700
        Oxygen -> 900
        Hydrogen -> 800
        
        -- Medium availability
        Plastics -> 300
        ConstructionMaterials -> 250
        ConsumerGoods -> 200
        Clothing -> 150
        HouseholdGoods -> 180
        
        -- Low availability
        RadioactiveMaterials -> 100
        Crystals -> 80
        Electronics -> 120
        MachineParts -> 100
        MedicalSupplies -> 150
        Alcohol -> 200
        Tobacco -> 180
        
        -- Very low availability
        ExoticMinerals -> 20
        RefinedMetals -> 50
        IndustrialChemicals -> 60
        Robotics -> 30
        Nanomaterials -> 10
        LuxuryGoods -> 40
        Pharmaceuticals -> 60
        Computers -> 50
        Weapons -> 40
        Ammunition -> 60
        Armor -> 30
        
        -- Extremely limited
        ResearchEquipment -> 5
        ScientificInstruments -> 8
        AIComponents -> 3
        Cybernetics -> 2
        HolographicTechnology -> 4
        QuantumProcessors -> 1
        FusionReactors -> 1
        MilitaryVehicles -> 5
        MilitarySupplies -> 20
        MilitaryRobots -> 3
        MilitaryDrones -> 4
        StarshipWeapons -> 2
        StarshipShields -> 2
        StarshipEngines -> 2
        SmallCraft -> 3
        Shuttles -> 2
        Freighters -> 1
        MiningShips -> 1
        ScienceVessels -> 1
        MilitaryShips -> 1
        CapitalShips -> 0  -- Not typically available in markets
        SpaceStations -> 0  -- Not typically available in markets
        Artifacts -> 1
        Relics -> 0  -- Extremely rare
        AncientTechnology -> 0  -- Extremely rare
        AlienArtifacts -> 0  -- Extremely rare
        BlackMarketGoods -> 10
        Slaves -> 5  -- Illegal in most places
        WMDs -> 0  -- Illegal everywhere
        Information -> 50
        HackingTools -> 10
        SecuritySystems -> 20
        MedicalServices -> 30
        Entertainment -> 40
        Prostitution -> 30
        Smuggling -> 10
        BountyHunting -> 5
        MercenaryServices -> 3
        Piracy -> 2
        OrganicMaterials -> 100
        BiohazardousMaterials -> 30
        ToxicWaste -> 50
        Helium3 -> 40
        Antimatter -> 5
        DarkMatter -> 2
        ExoticMatter -> 1
        QuantumFoam -> 1
        Neutronium -> 0  -- Extremely rare
        Unobtanium -> 0  -- Mythical


{-| Get the category of a good
-}
goodCategory : GoodType -> String
goodCategory goodType =
    case goodType of
        -- Basic Resources
        Water -> "Basic Resources"
        FoodRations -> "Basic Resources"
        Minerals -> "Basic Resources"
        Metals -> "Basic Resources"
        Gases -> "Basic Resources"
        RadioactiveMaterials -> "Basic Resources"
        Crystals -> "Basic Resources"
        ExoticMinerals -> "Basic Resources"
        
        -- Processed Materials
        RefinedMetals -> "Processed Materials"
        IndustrialChemicals -> "Processed Materials"
        Plastics -> "Processed Materials"
        ConstructionMaterials -> "Processed Materials"
        Electronics -> "Processed Materials"
        MachineParts -> "Processed Materials"
        Robotics -> "Processed Materials"
        Nanomaterials -> "Processed Materials"
        
        -- Consumer Goods
        ConsumerGoods -> "Consumer Goods"
        LuxuryGoods -> "Consumer Goods"
        MedicalSupplies -> "Consumer Goods"
        Pharmaceuticals -> "Consumer Goods"
        Alcohol -> "Consumer Goods"
        Narcotics -> "Consumer Goods"
        Tobacco -> "Consumer Goods"
        Clothing -> "Consumer Goods"
        Furniture -> "Consumer Goods"
        ElectronicsGoods -> "Consumer Goods"
        HouseholdGoods -> "Consumer Goods"
        
        -- Technology
        Computers -> "Technology"
        ResearchEquipment -> "Technology"
        ScientificInstruments -> "Technology"
        AIComponents -> "Technology"
        Cybernetics -> "Technology"
        HolographicTechnology -> "Technology"
        QuantumProcessors -> "Technology"
        FusionReactors -> "Technology"
        
        -- Military
        Weapons -> "Military"
        Ammunition -> "Military"
        Armor -> "Military"
        MilitaryVehicles -> "Military"
        MilitarySupplies -> "Military"
        MilitaryRobots -> "Military"
        MilitaryDrones -> "Military"
        StarshipWeapons -> "Military"
        StarshipShields -> "Military"
        StarshipEngines -> "Military"
        
        -- Spacecraft
        SmallCraft -> "Spacecraft"
        Shuttles -> "Spacecraft"
        Freighters -> "Spacecraft"
        MiningShips -> "Spacecraft"
        ScienceVessels -> "Spacecraft"
        MilitaryShips -> "Spacecraft"
        CapitalShips -> "Spacecraft"
        SpaceStations -> "Spacecraft"
        
        -- Special
        Artifacts -> "Special"
        Relics -> "Special"
        AncientTechnology -> "Special"
        AlienArtifacts -> "Special"
        BlackMarketGoods -> "Special"
        Slaves -> "Special"
        WMDs -> "Special"
        
        -- Services
        Information -> "Services"
        HackingTools -> "Services"
        SecuritySystems -> "Services"
        MedicalServices -> "Services"
        Entertainment -> "Services"
        Prostitution -> "Services"
        Smuggling -> "Services"
        BountyHunting -> "Services"
        MercenaryServices -> "Services"
        Piracy -> "Services"
        
        -- Raw Materials
        OrganicMaterials -> "Raw Materials"
        BiohazardousMaterials -> "Raw Materials"
        ToxicWaste -> "Raw Materials"
        ScrapMetal -> "Raw Materials"
        Recyclables -> "Raw Materials"
        Fuel -> "Raw Materials"
        Oxygen -> "Raw Materials"
        Hydrogen -> "Raw Materials"
        Helium3 -> "Raw Materials"
        Antimatter -> "Raw Materials"
        DarkMatter -> "Raw Materials"
        ExoticMatter -> "Raw Materials"
        QuantumFoam -> "Raw Materials"
        Neutronium -> "Raw Materials"
        Unobtanium -> "Raw Materials"


{-| A list of all available goods in the game
-}
allGoods : List GoodType
allGoods =
    [ -- Basic Resources
      Water
    , FoodRations
    , Minerals
    , Metals
    , Gases
    , RadioactiveMaterials
    , Crystals
    , ExoticMinerals
    
    -- Processed Materials
    , RefinedMetals
    , IndustrialChemicals
    , Plastics
    , ConstructionMaterials
    , Electronics
    , MachineParts
    , Robotics
    , Nanomaterials
    
    -- Consumer Goods
    , ConsumerGoods
    , LuxuryGoods
    , MedicalSupplies
    , Pharmaceuticals
    , Alcohol
    , Narcotics
    , Tobacco
    , Clothing
    , Furniture
    , ElectronicsGoods
    , HouseholdGoods
    
    -- Technology
    , Computers
    , ResearchEquipment
    , ScientificInstruments
    , AIComponents
    , Cybernetics
    , HolographicTechnology
    , QuantumProcessors
    , FusionReactors
    
    -- Military
    , Weapons
    , Ammunition
    , Armor
    , MilitaryVehicles
    , MilitarySupplies
    , MilitaryRobots
    , MilitaryDrones
    , StarshipWeapons
    , StarshipShields
    , StarshipEngines
    
    -- Spacecraft
    , SmallCraft
    , Shuttles
    , Freighters
    , MiningShips
    , ScienceVessels
    , MilitaryShips
    , CapitalShips
    , SpaceStations
    
    -- Special
    , Artifacts
    , Relics
    , AncientTechnology
    , AlienArtifacts
    , BlackMarketGoods
    , Slaves
    , WMDs
    
    -- Services
    , Information
    , HackingTools
    , SecuritySystems
    , MedicalServices
    , Entertainment
    , Prostitution
    , Smuggling
    , BountyHunting
    , MercenaryServices
    , Piracy
    
    -- Raw Materials
    , OrganicMaterials
    , BiohazardousMaterials
    , ToxicWaste
    , ScrapMetal
    , Recyclables
    , Fuel
    , Oxygen
    , Hydrogen
    , Helium3
    , Antimatter
    , DarkMatter
    , ExoticMatter
    , QuantumFoam
    , Neutronium
    , Unobtanium
    ]
