require('NPCs/MainCreationMethods');

local function initToadTraits()
    local olympian = TraitFactory.addTrait("olympian", getText("UI_trait_olympian"), 5, getText("UI_trait_olympiandesc"), false, false);
    olympian:addXPBoost(Perks.Sprinting, 1);
    olympian:addXPBoost(Perks.Fitness, 1);
    local flexible = TraitFactory.addTrait("flexible", getText("UI_trait_flexible"), 3, getText("UI_trait_flexibledesc"), false, false);
    flexible:addXPBoost(Perks.Nimble, 1);
    local quiet = TraitFactory.addTrait("quiet", getText("UI_trait_quiet"), 2, getText("UI_trait_quietdesc"), false, false);
    quiet:addXPBoost(Perks.Sneak, 1);
    local tinkerer = TraitFactory.addTrait("tinkerer", getText("UI_trait_tinkerer"), 6, getText("UI_trait_tinkererdesc"), false, false);
    tinkerer:addXPBoost(Perks.Electricity, 1);
    tinkerer:addXPBoost(Perks.Mechanics, 1);
    tinkerer:addXPBoost(Perks.Tailoring, 1);
    local wildsman = TraitFactory.addTrait("wildsman", getText("UI_trait_wildsman"), 8, getText("UI_trait_wildsmandesc"), false, false);
    wildsman:addXPBoost(Perks.Fishing, 1);
    wildsman:addXPBoost(Perks.Trapping, 1);
    wildsman:addXPBoost(Perks.PlantScavenging, 1);
    wildsman:addXPBoost(Perks.Spear, 1);
    wildsman:getFreeRecipes():add("Make Stick Trap");
    wildsman:getFreeRecipes():add("Make Snare Trap");
    wildsman:getFreeRecipes():add("Make Fishing Rod");
    wildsman:getFreeRecipes():add("Fix Fishing Rod");
    local packmule = TraitFactory.addTrait("packmule", getText("UI_trait_packmule"), 8, getText("UI_trait_packmuledesc"), false, false);
    local bladetwirl = TraitFactory.addTrait("bladetwirl", getText("UI_trait_bladetwirl"), 5, getText("UI_trait_bladetwirldesc"), false, false);
    bladetwirl:addXPBoost(Perks.LongBlade, 1);
    bladetwirl:addXPBoost(Perks.SmallBlade, 1);
    local blunttwirl = TraitFactory.addTrait("blunttwirl", getText("UI_trait_blunttwirl"), 5, getText("UI_trait_blunttwirldesc"), false, false);
    blunttwirl:addXPBoost(Perks.SmallBlunt, 1);
    blunttwirl:addXPBoost(Perks.Blunt, 1);
    local spearperk = TraitFactory.addTrait("prospear", getText("UI_trait_prospear"), 7, getText("UI_trait_prospeardesc"), false, false);
    spearperk:addXPBoost(Perks.Spear, 2);
    local quickworker = TraitFactory.addTrait("quickworker", getText("UI_trait_quickworker"), 8, getText("UI_trait_quickworkerdesc"), false, false);
    --===========--
    --Bad Traits--
    --===========--
    local packmouse = TraitFactory.addTrait("packmouse", getText("UI_trait_packmouse"), -7, getText("UI_trait_packmousedesc"), false, false);
    local injured = TraitFactory.addTrait("injured", getText("UI_trait_injured"), -4, getText("UI_trait_injureddesc"), false, false);
    local broke = TraitFactory.addTrait("broke", getText("UI_trait_broke"), -8, getText("UI_trait_brokedesc"), false, false);
    local slowworker = TraitFactory.addTrait("slowworker", getText("UI_trait_slowworker"), -9, getText("UI_trait_slowworkerdesc"), false, false);
    local burned = TraitFactory.addTrait("burned", getText("UI_trait_burned"), -18, getText("UI_trait_burneddesc"), false, false);
    --Exclusives
    TraitFactory.setMutualExclusive("packmule", "packmouse");
    TraitFactory.setMutualExclusive("quickworker", "slowworker");
    TraitFactory.setMutualExclusive("burned", "broke");
    TraitFactory.setMutualExclusive("burned", "injured");
    TraitFactory.sortList();
end

Events.OnGameBoot.Add(initToadTraits);
