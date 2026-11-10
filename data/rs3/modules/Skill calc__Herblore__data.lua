-- <nowiki>
local p = {}

p.mix_potion_rate_base = 30 -- 15 potions/10 bombs
p.mix_potion_rate_base_seconds = 0.6 * p.mix_potion_rate_base

p.production_ticks = {
    ["herb"] = 1,
    ["unfinished"] = 2,
    ["standard"] = 2,
    ["combinations"] = 2,
    ["primal"] = 2,
    ["primal_pulp"] = 2,
    ["adrenaline"] = 2,
    ["juju_herb"] = 1,
    ["juju_unfinished"] = 2,
    ["juju"] = 2,
    ["barbarian"] = 2,
    ["bomb"] = 3,
    ["powerburst"] = 3,
    ["tar"] = 3,
    ["burner"] = 7,
    ["daemonheim"] = 6,
    ["daemonheim_herb"] = 1,
    ["grinding"] = 1,
    ["telekinetic_grind"] = 3,
    ["manual_filling"] = 1,
    ["humidify"] = 3,
}

-- UI options
p.categories = {
    ["Clean herbs"] = "herb",
    ["Unfinished potions"] = "unfinished",
    ["Standard potions"] = "standard",
    ["Combination potions"] = "combinations",
    ["Overload variants"] = "overload_variants",
    ["Primal extract"] = "primal",
    ["Primal fruit pulp"] = "primal_pulp",
    ["Adrenaline crystal"] = "adrenaline",
    ["Clean juju herbs"] = "juju_herb",
    ["Unfinished juju potions"] = "juju_unfinished",
    ["Juju potions"] = "juju",
    ["Barbarian mix"] = "barbarian",
    ["Bomb"] = "bomb",
    ["Powerbursts"] = "powerburst",
    ["Tar"] = "tar",
    ["Deployable herb burner"] = "burner",
    ["Daemonheim - clean herbs"] = "daemonheim_herb",
    ["Daemonheim - potions"] = "daemonheim",
}

p.common_potions = {
    "standard", "combinations", "bomb", "powerburst"
}

p.all_categories_outside_daemonheim = {
    "standard", "juju", "bomb", "powerburst", "adrenaline",
    "herb", "juju_herb",
    "unfinished", "juju_unfinished",
    "combinations", "barbarian", "primal", "primal_pulp", "tar",
}

p.all_categories_in_daemonheim = {
    "daemonheim", "daemonheim_herb",
}

p.herb_potion_replacement_category_table = {
    ["Tradable potions"] = {
        standard = { "standard", "combinations" },
        combinations = { "standard", "combinations" },
        powerburst = { "standard" },
    },
    ["Unfinished potions"] = {
        standard = { "standard", "combinations" },
        combinations = { "standard", "combinations" },
        bomb = { "standard" },
        powerburst = { "standard" },
        barbarian = { "standard" },
        juju = { "juju" },
    },
    ["Clean herbs"] = {
        standard = { "unfinished", "standard", "combinations" },
        combinations = { "unfinished", "standard", "combinations" },
        bomb = { "unfinished", "standard" },
        powerburst = { "unfinished", "standard" },
        barbarian = { "unfinished", "standard" },
        juju = { "juju_unfinished", "juju" },
    },
    ["Grimy herbs"] = {
        standard = { "herb", "unfinished", "standard", "combinations" },
        combinations = { "herb", "unfinished", "standard", "combinations" },
        bomb = { "herb", "unfinished", "standard" },
        powerburst = { "herb", "unfinished", "standard" },
        barbarian = { "herb", "unfinished", "standard" },
        juju = { "juju_herb", "juju_unfinished", "juju" },
        tar = { "herb" },
        burner = { "juju_herb", "herb" },
        unfinished = { "herb" },
        juju_unfinished = { "juju_herb" },
        daemonheim = { "daemonheim_herb" },
    },
}

-- Multiplicative xp bonus
p.dxp = {
    affects = "all",
    b = 1,
}
p.raf = {
    affects = "all",
    b = 0.1,
}
p.pulse_core = {
    affects = "all",
    b = {
        ["None"] = 0,
        ["Buff only"] = 0.1,
        ["Equipped"] = 0.5,
        ["Buff and equipped"] = (1.1 * 1.5) - 1,
    },
}

-- Additive xp bonus
p.wisdom = {
    affects = p.all_categories_outside_daemonheim,
    b = 0.025
}
p.premier_artefact = {
    affects = "all",
    b = 0.1
}
p.desert_pantheon = {
    affects = "all",
    b = 0.1,
    -- dxp_disabled = true,
}
p.avatar = {
    affects = p.all_categories_outside_daemonheim,
    b = { ["None"] = 0, ["3"] = 0.03, ["4"] = 0.04, ["5"] = 0.05, ["6"] = 0.06 },
}
p.wise = {
    affects = p.all_categories_outside_daemonheim,
    b = { ["None"] = 0, ["Wise 1"] = 0.01, ["Wise 2"] = 0.02, ["Wise 3"] = 0.03, ["Wise 4"] = 0.04 },
}
p.inspire = {
    affects = "all",
    b = 0.02,
}
p.outfit = {
    affects = p.all_categories_outside_daemonheim,
    b = { 0.01, 0.02, 0.03, 0.04, 0.06 },
}
p.incense_torstol = {
    affects = p.all_categories_outside_daemonheim,
    b = { 0.005, 0.01, 0.015, 0.02 },
    consumable = {
        name = "Torstol incense sticks",
        price = "gemw",
        alias = "Torstol incense sticks",
        -- effect_duration = 10 * 60, -- 10 minutes
        rate = p.mix_potion_rate_base_seconds / (10 * 60),
    }
}
p.portable_xp = {
    affects = {
        "standard", "juju", "bomb", "powerburst", "adrenaline",
        "unfinished", "juju_unfinished",
        "combinations", "primal", "barbarian"
    },
    b = 0.1,
}
p.perfect_juju_herblore = {
    affects = { "combinations" },
    b = 0.05,
    consumable = {
        ["Perfect juju herblore potion"] = {
            name = "Perfect juju herblore potion (3)",
            price = "gemw",
            alias = "Perfect juju herblore potion",
            dose = 3,
            -- effect_duration = 60 * 60, -- 60 minutes
            rate = (p.mix_potion_rate_base_seconds / (60 * 60)) / 3,
        },
        ["Perfect plus potion"] = {
            name = "Perfect plus potion (6)",
            price = "calcvalue",
            alias = "Perfect plus potion",
            dose = 6,
            -- effect_duration = 60 * 60 * 4, -- 4 hours
            rate = (p.mix_potion_rate_base_seconds / (60 * 60 * 4)) / 6,
        },
    }
}
p.meilyr_hour = {
    affects = { "combinations" },
    b = 0.2,
}
p.bik_scripture = {
    affects = p.all_categories_outside_daemonheim,
    b = {
        ["None"] = 0,
        ["Flicking and switching every minute"] = 0.05 / 6,
        ["Always activated"] = 0.05 / 6
    },
    -- active_duration = 45 * 60, -- 45 minutes
    -- effect_duration = 60 * 60, -- 60 minutes
    -- effect_possibility = 10 / 60, -- ~10 procs per hour
    consumable = {
        name = "Manuscript of Bik",
        price = "gemw",
        alias = "Manuscript of Bik",
        rate = {
            ["None"] = 0,
            ["Flicking and switching every minute"] = (p.mix_potion_rate_base_seconds) / (45 * 60) /
                (60 / p.mix_potion_rate_base_seconds),
            ["Always activated"] = p.mix_potion_rate_base_seconds / (45 * 60)
        },
    }
}
p.knowledge_bomb = {
    affects = "all",
    b = { ["None"] = 0, ["Small/Medium/Large/Huge/Prime Gaming"] = 0.5, ["Superior"] = 1 },
    -- dxp_disabled = true,
}

-- Bonus XP
p.bxp = {
    affects = "all",
    b = 1,
}
p.cinder_core = {
    affects = "all",
    b = {
        ["None"] = 0,
        ["Buff only"] = 0.1,
        ["Equipped"] = 1.5,
        ["Buff and equipped"] = (1 + 0.1) * (1 + 1.5) - 1,
    },
}

-- Duplicate product
p.portable_extra = {
    affects = {
        "standard", "juju", "bomb", "powerburst", "adrenaline",
        "unfinished", "juju_unfinished", "barbarian"
    },
    p = 0.05,
}
p.brooch = {
    -- needs portable
    affects = p.portable_extra.affects,
    p = p.portable_extra.p,
}
p.modified_mask = {
    affects = {
        "standard", "juju", "bomb", "powerburst", "adrenaline",
        "unfinished", "juju_unfinished", "combinations", "barbarian"
    },
    p = 0.05,
}

-- 3 doses to 4 doses
p.factory_3 = {
    affects = { "standard", "juju" },
    p = 0.125,
}
p.botanist_amulet = {
    affects = { "standard", "juju" },
    p = 0.05,
    consumable = {
        name = "Botanist's amulet (new)",
        price = "gemw",
        alias = "Botanist's amulet",
        rate = 0.05 / 5,
    }
}
p.morytania_4 = {
    affects = "specific",
    affected_category = { "standard" },
    potions = { "Prayer renewal (3)" },
    p = 0.2,
}
p.desert_4 = {
    affects = "specific",
    affected_category = { "standard" },
    potions = { "Super antifire (3)" },
    p = 0.2,
}
p.envenomed = {
    affects = "specific",
    affected_category = { "standard" },
    potions = {
        "Antipoison (3)", "Antipoison+ (4)", "Antipoison++ (4)", "Super antipoison (3)",
        "Weapon poison (3)", "Weapon poison+ (3)", "Weapon poison++ (3)", "Weapon poison+++ (3)"
    },
    p = 0.1,
}

-- Save ingredient
p.soc = {
    affects = {
        "standard", "juju", "bomb", "powerburst", "adrenaline",
        "unfinished", "juju_unfinished",
        "combinations", "barbarian",
    },
    p = 0.1,
}

-- Cleaning herb XP bonus
p.factory_5 = {
    affects = { "unfinished", "juju_unfinished" },
    b = {
        ["Weapon poison+ (unfinished)"] = 7,
        ["Weapon poison++ (unfinished)"] = 7.75,
        ["Guam potion (unfinished)"] = 2.5,
        ["Tarromin potion (unfinished)"] = 3.8,
        ["Marrentill potion (unfinished)"] = 5,
        ["Harralander potion (unfinished)"] = 6.3,
        ["Ranarr potion (unfinished)"] = 7.5,
        ["Toadflax potion (unfinished)"] = 8,
        ["Spirit weed potion (unfinished)"] = 7.8,
        ["Irit potion (unfinished)"] = 8.8,
        ["Wergali potion (unfinished)"] = 9.5,
        ["Avantoe potion (unfinished)"] = 10,
        ["Kwuarm potion (unfinished)"] = 11.3,
        ["Bloodweed potion (unfinished)"] = 11.5,
        ["Snapdragon potion (unfinished)"] = 11.8,
        ["Cadantine potion (unfinished)"] = 12.5,
        ["Lantadyme potion (unfinished)"] = 13.1,
        ["Dwarf weed potion (unfinished)"] = 13.8,
        ["Torstol potion (unfinished)"] = 15,
        ["Arbuck potion (unfinished)"] = 13.5,
        ["Fellstalk potion (unfinished)"] = 16.8,
        ["Antipoison+ (unfinished)"] = 8,
        ["Antipoison++ (unfinished)"] = 8.8,
        ["Erzille potion (unfinished)"] = 10,
        ["Ugune potion (unfinished)"] = 11.5,
        ["Argway potion (unfinished)"] = 11.6,
        ["Shengo potion (unfinished)"] = 11.7,
        ["Samaden potion (unfinished)"] = 11.7,
    }
}

-- Instant cleaning herbs
p.cape99 = {
    affects = { "herb", "juju_herb" },
}

-- Recipes
p.herb = {
    ["Clean guam"] = {
        name = "Clean guam",
        level = 1,
        xp = 2.5,
        mats = {
            {
                name = "Grimy guam",
                qty = 1,
            }
        },
    },
    ["Clean snake weed"] = {
        name = "Clean snake weed",
        level = 3,
        xp = 2.5,
        price = "no",
        mats = {
            {
                name = "Grimy snake weed",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean ardrigal"] = {
        name = "Clean ardrigal",
        level = 3,
        xp = 2.5,
        price = "no",
        mats = {
            {
                name = "Grimy ardrigal",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean rogue's purse"] = {
        name = "Clean rogue's purse",
        level = 3,
        xp = 2.5,
        price = "no",
        mats = {
            {
                name = "Grimy rogue's purse",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean sito foil"] = {
        name = "Clean sito foil",
        level = 3,
        xp = 2.5,
        price = "no",
        mats = {
            {
                name = "Grimy sito foil",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean volencia moss"] = {
        name = "Clean volencia moss",
        level = 3,
        xp = 2.5,
        price = "no",
        mats = {
            {
                name = "Grimy volencia moss",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean tarromin"] = {
        name = "Clean tarromin",
        level = 5,
        xp = 3.8,
        mats = {
            {
                name = "Grimy tarromin",
                qty = 1,
            }
        },
    },
    ["Clean marrentill"] = {
        name = "Clean marrentill",
        level = 9,
        xp = 5,
        mats = {
            {
                name = "Grimy marrentill",
                qty = 1,
            }
        },
    },
    ["Clean harralander"] = {
        name = "Clean harralander",
        level = 20,
        xp = 6.3,
        mats = {
            {
                name = "Grimy harralander",
                qty = 1,
            }
        },
    },
    ["Clean ranarr"] = {
        name = "Clean ranarr",
        level = 25,
        xp = 7.5,
        mats = {
            {
                name = "Grimy ranarr",
                qty = 1,
            }
        },
    },
    ["Clean toadflax"] = {
        name = "Clean toadflax",
        level = 30,
        xp = 8,
        mats = {
            {
                name = "Grimy toadflax",
                qty = 1,
            }
        },
    },
    ["Clean spirit weed"] = {
        name = "Clean spirit weed",
        level = 35,
        xp = 7.8,
        mats = {
            {
                name = "Grimy spirit weed",
                qty = 1,
            }
        },
    },
    ["Clean irit"] = {
        name = "Clean irit",
        level = 40,
        xp = 8.8,
        mats = {
            {
                name = "Grimy irit",
                qty = 1,
            }
        },
    },
    ["Clean wergali"] = {
        name = "Clean wergali",
        level = 41,
        xp = 9.5,
        mats = {
            {
                name = "Grimy wergali",
                qty = 1,
            }
        },
    },
    ["Clean avantoe"] = {
        name = "Clean avantoe",
        level = 48,
        xp = 10,
        mats = {
            {
                name = "Grimy avantoe",
                qty = 1,
            }
        },
    },
    ["Clean kwuarm"] = {
        name = "Clean kwuarm",
        level = 54,
        xp = 11.3,
        mats = {
            {
                name = "Grimy kwuarm",
                qty = 1,
            }
        },
    },
    ["Clean bloodweed"] = {
        name = "Clean bloodweed",
        level = 57,
        xp = 11.5,
        mats = {
            {
                name = "Grimy bloodweed",
                qty = 1,
            }
        },
    },
    ["Clean snapdragon"] = {
        name = "Clean snapdragon",
        level = 59,
        xp = 11.8,
        mats = {
            {
                name = "Grimy snapdragon",
                qty = 1,
            }
        },
    },
    ["Clean cadantine"] = {
        name = "Clean cadantine",
        level = 65,
        xp = 12.5,
        mats = {
            {
                name = "Grimy cadantine",
                qty = 1,
            }
        },
    },
    ["Clean lantadyme"] = {
        name = "Clean lantadyme",
        level = 67,
        xp = 13.1,
        mats = {
            {
                name = "Grimy lantadyme",
                qty = 1,
            }
        },
    },
    ["Clean dwarf weed"] = {
        name = "Clean dwarf weed",
        level = 70,
        xp = 13.8,
        mats = {
            {
                name = "Grimy dwarf weed",
                qty = 1,
            }
        },
    },
    ["Clean torstol"] = {
        name = "Clean torstol",
        level = 75,
        xp = 15,
        mats = {
            {
                name = "Grimy torstol",
                qty = 1,
            }
        },
    },
    ["Clean arbuck"] = {
        name = "Clean arbuck",
        level = 77,
        xp = 13.5,
        mats = {
            {
                name = "Grimy arbuck",
                qty = 1,
            }
        },
    },
    ["Clean fellstalk"] = {
        name = "Clean fellstalk",
        level = 91,
        xp = 16.8,
        mats = {
            {
                name = "Grimy fellstalk",
                qty = 1,
            }
        },
    },
}

p.juju_herb = {
    ["Clean erzille"] = {
        name = "Clean erzille",
        level = 54,
        xp = 10,
        price = "no",
        mats = {
            {
                name = "Grimy erzille",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean ugune"] = {
        name = "Clean ugune",
        level = 55,
        xp = 11.5,
        price = "no",
        mats = {
            {
                name = "Grimy ugune",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean argway"] = {
        name = "Clean argway",
        level = 56,
        xp = 11.6,
        price = "no",
        mats = {
            {
                name = "Grimy argway",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean shengo"] = {
        name = "Clean shengo",
        level = 57,
        xp = 11.7,
        price = "no",
        mats = {
            {
                name = "Grimy shengo",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean samaden"] = {
        name = "Clean samaden",
        level = 58,
        xp = 11.7,
        price = "no",
        mats = {
            {
                name = "Grimy samaden",
                qty = 1,
                price = "no",
            }
        },
    },
}

p.unfinished = {
    ["Guam potion (unfinished)"] = {
        name = "Guam potion (unfinished)",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean guam",
                qty = 1,
            },
        },
    },
    ["Snakeweed mixture"] = {
        name = "Snakeweed mixture",
        level = 3,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean snake weed",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Ardrigal mixture"] = {
        name = "Ardrigal mixture",
        level = 3,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean ardrigal",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Rogue's purse potion (unfinished)"] = {
        name = "Rogue's purse potion (unfinished)",
        level = 5,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean rogue's purse",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Tarromin potion (unfinished)"] = {
        name = "Tarromin potion (unfinished)",
        level = 5,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean tarromin",
                qty = 1,
            },
        },
    },
    ["Marrentill potion (unfinished)"] = {
        name = "Marrentill potion (unfinished)",
        level = 9,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean marrentill",
                qty = 1,
            },
        },
    },
    ["Harralander potion (unfinished)"] = {
        name = "Harralander potion (unfinished)",
        level = 20,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean harralander",
                qty = 1,
            },
        },
    },
    ["Guthix balance (unfinished)"] = {
        name = "Guthix balance (unfinished)",
        level = 22,
        xp = 25,
        price_name = "Guthix balance (unfinished) (3)",
        mats = {
            {
                name = "Restore potion (3)",
                qty = 1,
            },
            {
                name = "Garlic",
                qty = 1,
            },
        },
    },
    ["Ranarr potion (unfinished)"] = {
        name = "Ranarr potion (unfinished)",
        level = 25,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean ranarr",
                qty = 1,
            },
        },
    },
    ["Toadflax potion (unfinished)"] = {
        name = "Toadflax potion (unfinished)",
        level = 30,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean toadflax",
                qty = 1,
            },
        },
    },
    ["Spirit weed potion (unfinished)"] = {
        name = "Spirit weed potion (unfinished)",
        level = 35,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean spirit weed",
                qty = 1,
            },
        },
    },
    ["Irit potion (unfinished)"] = {
        name = "Irit potion (unfinished)",
        level = 40,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean irit",
                qty = 1,
            },
        },
    },
    ["Wergali potion (unfinished)"] = {
        name = "Wergali potion (unfinished)",
        level = 41,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean wergali",
                qty = 1,
            },
        },
    },
    ["Avantoe potion (unfinished)"] = {
        name = "Avantoe potion (unfinished)",
        level = 48,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean avantoe",
                qty = 1,
            },
        },
    },
    ["Kwuarm potion (unfinished)"] = {
        name = "Kwuarm potion (unfinished)",
        level = 54,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean kwuarm",
                qty = 1,
            },
        },
    },
    ["Magic essence (unfinished)"] = {
        name = "Magic essence (unfinished)",
        level = 57,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Star flower",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Bloodweed potion (unfinished)"] = {
        name = "Bloodweed potion (unfinished)",
        level = 57,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean bloodweed",
                qty = 1,
            },
        },
    },
    ["Snapdragon potion (unfinished)"] = {
        name = "Snapdragon potion (unfinished)",
        level = 59,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean snapdragon",
                qty = 1,
            },
        },
    },
    ["Cadantine potion (unfinished)"] = {
        name = "Cadantine potion (unfinished)",
        level = 65,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean cadantine",
                qty = 1,
            },
        },
    },
    ["Lantadyme potion (unfinished)"] = {
        name = "Lantadyme potion (unfinished)",
        level = 67,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean lantadyme",
                qty = 1,
            },
        },
    },
    ["Dwarf weed potion (unfinished)"] = {
        name = "Dwarf weed potion (unfinished)",
        level = 70,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean dwarf weed",
                qty = 1,
            },
        },
    },
    ["Torstol potion (unfinished)"] = {
        name = "Torstol potion (unfinished)",
        level = 75,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean torstol",
                qty = 1,
            },
        },
    },
    ["Arbuck potion (unfinished)"] = {
        name = "Arbuck potion (unfinished)",
        level = 77,
        xp = 1.2,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean arbuck",
                qty = 1,
            },
        },
    },
    ["Fellstalk potion (unfinished)"] = {
        name = "Fellstalk potion (unfinished)",
        level = 91,
        xp = 1,
        mats = {
            {
                name = "Vial of water",
                qty = 1,
            },
            {
                name = "Clean fellstalk",
                qty = 1,
            },
        },
    },
    ["Antipoison+ (unfinished)"] = {
        name = "Antipoison+ (unfinished)",
        level = 68,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Coconut milk",
                qty = 1,
            },
            {
                name = "Clean toadflax",
                qty = 1,
            },
        },
    },
    ["Weapon poison+ (unfinished)"] = {
        name = "Weapon poison+ (unfinished)",
        level = 73,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Coconut milk",
                qty = 1,
            },
            {
                name = "Cactus spine",
                qty = 1,
            },
        },
    },
    ["Antipoison++ (unfinished)"] = {
        name = "Antipoison++ (unfinished)",
        level = 79,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Coconut milk",
                qty = 1,
            },
            {
                name = "Clean irit",
                qty = 1,
            },
        },
    },
    ["Weapon poison++ (unfinished)"] = {
        name = "Weapon poison++ (unfinished)",
        level = 82,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Coconut milk",
                qty = 1,
            },
            {
                name = "Cave nightshade",
                qty = 1,
                price = "calcvalue",
            },
        },
    },
    ["Mixture - step 1"] = {
        name = "Mixture - step 1 (3)",
        level = 65,
        xp = 47.5,
        mats = {
            {
                name = "Super restore (3)",
                qty = 1,
            },
            {
                name = "Unicorn horn dust",
                qty = 1,
            },
        },
    },
    ["Mixture - step 2"] = {
        name = "Mixture - step 2 (3)",
        level = 65,
        xp = 52.5,
        mats = {
            {
                name = "Mixture - step 1 (3)",
                qty = 1,
            },
            {
                name = "Clean snake weed",
                qty = 1,
                price = "no",
            },
        },
    },
}

p.juju_unfinished = {
    ["Erzille potion (unfinished)"] = {
        name = "Erzille potion (unfinished)",
        level = 54,
        xp = 1,
        mats = {
            {
                name = "Juju vial of water",
                qty = 1,
            },
            {
                name = "Clean erzille",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Ugune potion (unfinished)"] = {
        name = "Ugune potion (unfinished)",
        level = 55,
        xp = 1,
        mats = {
            {
                name = "Juju vial of water",
                qty = 1,
            },
            {
                name = "Clean ugune",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Argway potion (unfinished)"] = {
        name = "Argway potion (unfinished)",
        level = 56,
        xp = 1,
        mats = {
            {
                name = "Juju vial of water",
                qty = 1,
            },
            {
                name = "Clean argway",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Shengo potion (unfinished)"] = {
        name = "Shengo potion (unfinished)",
        level = 57,
        xp = 1,
        mats = {
            {
                name = "Juju vial of water",
                qty = 1,
            },
            {
                name = "Clean shengo",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Samaden potion (unfinished)"] = {
        name = "Samaden potion (unfinished)",
        level = 58,
        xp = 1,
        mats = {
            {
                name = "Juju vial of water",
                qty = 1,
            },
            {
                name = "Clean samaden",
                qty = 1,
                price = "no",
            },
        },
    },
}

p.standard = {
    ["Attack potion"] = {
        name = "Attack potion (3)",
        level = 1,
        xp = 25,
        dose = 3,
        mats = {
            {
                name = "Guam potion (unfinished)",
                qty = 1,
            },
            {
                name = "Eye of newt",
                qty = 1,
            },
        },
    },
    ["Ranging potion"] = {
        name = "Ranging potion (3)",
        level = 3,
        xp = 30,
        dose = 3,
        mats = {
            {
                name = "Guam potion (unfinished)",
                qty = 1,
            },
            {
                name = "Redberries",
                qty = 1,
            },
        },
    },
    ["Magic potion"] = {
        name = "Magic potion (3)",
        level = 5,
        xp = 35,
        dose = 3,
        recipes = {
            {
                method = "Using black bead",
                mats = {
                    {
                        name = "Tarromin potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Black bead",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using red bead",
                mats = {
                    {
                        name = "Tarromin potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Red bead",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using yellow bead",
                mats = {
                    {
                        name = "Tarromin potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Yellow bead",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using white bead",
                mats = {
                    {
                        name = "Tarromin potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "White bead",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Strength potion"] = {
        name = "Strength potion (3)",
        level = 7,
        xp = 40,
        dose = 3,
        mats = {
            {
                name = "Tarromin potion (unfinished)",
                qty = 1,
            },
            {
                name = "Limpwurt root",
                qty = 1,
            },
        },
    },
    ["Relicym's balm"] = {
        name = "Relicym's balm (3)",
        level = 8,
        xp = 40,
        dose = 3,
        mats = {
            {
                name = "Rogue's purse potion (unfinished)",
                qty = 1,
            },
            {
                name = "Clean snake weed",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Defence potion"] = {
        name = "Defence potion (3)",
        level = 9,
        xp = 45,
        dose = 3,
        mats = {
            {
                name = "Marrentill potion (unfinished)",
                qty = 1,
            },
            {
                name = "Bear fur",
                qty = 1,
            },
        },
    },
    ["Necromancy potion"] = {
        name = "Necromancy potion (3)",
        level = 11,
        xp = 50,
        dose = 3,
        mats = {
            {
                name = "Marrentill potion (unfinished)",
                qty = 1,
            },
            {
                name = "Cadava berries",
                qty = 1,
            },
        },
    },
    ["Antipoison"] = {
        name = "Antipoison (3)",
        level = 13,
        xp = 50,
        dose = 3,
        mats = {
            {
                name = "Marrentill potion (unfinished)",
                qty = 1,
            },
            {
                name = "Unicorn horn dust",
                qty = 1,
            },
        },
    },
    ["Serum 207"] = {
        name = "Serum 207 (3)",
        level = 15,
        xp = 50,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Tarromin potion (unfinished)",
                qty = 1,
            },
            {
                name = "Ashes",
                qty = 1,
            },
        },
    },
    ["Antisanguine"] = {
        name = "Antisanguine (3)",
        level = 15,
        xp = 55,
        dose = 3,
        mats = {
            {
                name = "Marrentill potion (unfinished)",
                qty = 1,
            },
            {
                name = "Sanguine matter",
                qty = 1,
            },
        },
    },
    ["Guthix rest"] = {
        name = "Guthix rest (3)",
        level = 18,
        xp = 59.5,
        dose = 3,
        mats = {
            {
                name = "Harralander potion (unfinished)",
                qty = 1,
            },
            {
                name = "Clean marrentill",
                qty = 1,
            },
        },
    },
    ["Guthix balance"] = {
        name = "Guthix balance (3)",
        level = 22,
        xp = 25,
        dose = 3,
        mats = {
            {
                name = "Guthix balance (unfinished)",
                qty = 1,
                price_name = "Guthix balance (unfinished) (3)",
            },
            {
                name = "Silver dust",
                qty = 1,
            },
        },
    },
    ["Restore potion"] = {
        name = "Restore potion (3)",
        level = 22,
        xp = 62.5,
        dose = 3,
        mats = {
            {
                name = "Harralander potion (unfinished)",
                qty = 1,
            },
            {
                name = "Red spiders' eggs",
                qty = 1,
            },
        },
    },
    ["Blamish oil"] = {
        name = "Blamish oil",
        level = 25,
        xp = 80,
        dose = 1,
        price = "no",
        mats = {
            {
                name = "Harralander potion (unfinished)",
                qty = 1,
            },
            {
                name = "Blamish snail slime",
                qty = 1,
                price = "calcvalue",
            },
        },
    },
    ["Energy potion"] = {
        name = "Energy potion (3)",
        level = 26,
        xp = 67.5,
        dose = 3,
        mats = {
            {
                name = "Harralander potion (unfinished)",
                qty = 1,
            },
            {
                name = "Chocolate dust",
                qty = 1,
            },
        },
    },
    ["Super fishing explosive"] = {
        name = "Super fishing explosive",
        level = 31,
        xp = 55,
        dose = 1,
        price = "no",
        mats = {
            {
                name = "Guam potion (unfinished)",
                qty = 1,
            },
            {
                name = "Rubium",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Agility potion"] = {
        name = "Agility potion (3)",
        level = 34,
        xp = 80,
        dose = 3,
        mats = {
            {
                name = "Toadflax potion (unfinished)",
                qty = 1,
            },
            {
                name = "Toad's legs",
                qty = 1,
            },
        },
    },
    ["Combat potion"] = {
        name = "Combat potion (3)",
        level = 36,
        xp = 84,
        dose = 3,
        mats = {
            {
                name = "Harralander potion (unfinished)",
                qty = 1,
            },
            {
                name = "Goat horn dust",
                qty = 1,
            },
        },
    },
    ["Goblin potion"] = {
        name = "Goblin potion (3)",
        level = 37,
        xp = 85,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Toadflax potion (unfinished)",
                qty = 1,
            },
            {
                name = "Pharmakos berries",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Prayer potion"] = {
        name = "Prayer potion (3)",
        level = 38,
        xp = 87.5,
        dose = 3,
        mats = {
            {
                name = "Ranarr potion (unfinished)",
                qty = 1,
            },
            {
                name = "Snape grass",
                qty = 1,
            },
        },
    },
    ["Summoning potion"] = {
        name = "Summoning potion (3)",
        level = 40,
        xp = 92,
        dose = 3,
        recipes = {
            {
                method = "Using cockatrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Cockatrice egg",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using guthatrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Guthatrice egg",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using saratrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Saratrice egg",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using zamatrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Zamatrice egg",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using pengatrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Pengatrice egg",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using coraxatrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Coraxatrice egg",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using vulatrice egg",
                mats = {
                    {
                        name = "Spirit weed potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Vulatrice egg",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Crafting potion"] = {
        name = "Crafting potion (3)",
        level = 42,
        xp = 95,
        dose = 3,
        mats = {
            {
                name = "Wergali potion (unfinished)",
                qty = 1,
            },
            {
                name = "Frog spawn",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Runecrafting potion"] = {
        name = "Runecrafting potion (3)",
        level = 54,
        xp = 122.5,
        dose = 3,
        recipes = {
            {
                method = "Using fallfaced wool",
                mats = {
                    {
                        name = "Wergali potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Fallfaced wool",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using springsheared wool",
                mats = {
                    {
                        name = "Wergali potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Springsheared wool",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using summerdown wool",
                mats = {
                    {
                        name = "Wergali potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Summerdown wool",
                        qty = 1,
                    },
                },
            },
            {
                method = "Using winterwold wool",
                mats = {
                    {
                        name = "Wergali potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Winterwold wool",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Divination potion"] = {
        name = "Divination potion (3)",
        level = 43,
        xp = 97.5,
        dose = 3,
        mats = {
            {
                name = "Spirit weed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Rabbit foot",
                qty = 1,
            },
        },
    },
    ["Super attack"] = {
        name = "Super attack (3)",
        level = 45,
        xp = 100,
        dose = 3,
        mats = {
            {
                name = "Irit potion (unfinished)",
                qty = 1,
            },
            {
                name = "Eye of newt",
                qty = 1,
            },
        },
    },
    ["Super antipoison"] = {
        name = "Super antipoison (3)",
        level = 48,
        xp = 106.3,
        dose = 3,
        mats = {
            {
                name = "Irit potion (unfinished)",
                qty = 1,
            },
            {
                name = "Unicorn horn dust",
                qty = 1,
            },
        },
    },
    ["Woodcutting potion"] = {
        name = "Woodcutting potion (3)",
        level = 49,
        xp = 107.5,
        dose = 3,
        mats = {
            {
                name = "Avantoe potion (unfinished)",
                qty = 1,
            },
            {
                name = "Timber fungus",
                qty = 1,
            },
        },
    },
    ["Fishing potion"] = {
        name = "Fishing potion (3)",
        level = 50,
        xp = 112.5,
        dose = 3,
        mats = {
            {
                name = "Avantoe potion (unfinished)",
                qty = 1,
            },
            {
                name = "Snape grass",
                qty = 1,
            },
        },
    },
    ["Mining potion"] = {
        name = "Mining potion (3)",
        level = 51,
        xp = 115,
        dose = 3,
        mats = {
            {
                name = "Avantoe potion (unfinished)",
                qty = 1,
            },
            {
                name = "Calcified fungus",
                qty = 1,
            },
        },
    },
    ["Super energy"] = {
        name = "Super energy (3)",
        level = 52,
        xp = 117.5,
        dose = 3,
        mats = {
            {
                name = "Avantoe potion (unfinished)",
                qty = 1,
            },
            {
                name = "Mort myre fungus",
                qty = 1,
            },
        },
    },
    ["Hunter potion"] = {
        name = "Hunter potion (3)",
        level = 53,
        xp = 120,
        dose = 3,
        mats = {
            {
                name = "Avantoe potion (unfinished)",
                qty = 1,
            },
            {
                name = "Kebbit teeth dust",
                qty = 1,
            },
        },
    },
    ["Cooking potion"] = {
        name = "Cooking potion (3)",
        level = 55,
        xp = 125,
        dose = 3,
        mats = {
            {
                name = "Harralander potion (unfinished)",
                qty = 1,
            },
            {
                name = "Swordfish",
                qty = 1,
            },
        },
    },
    ["Super antisanguine"] = {
        name = "Super antisanguine (3)",
        level = 55,
        xp = 125,
        dose = 3,
        mats = {
            {
                name = "Kwuarm potion (unfinished)",
                qty = 1,
            },
            {
                name = "Exalted essence",
                qty = 1,
            },
        },
    },
    ["Super strength"] = {
        name = "Super strength (3)",
        level = 55,
        xp = 125,
        dose = 3,
        mats = {
            {
                name = "Kwuarm potion (unfinished)",
                qty = 1,
            },
            {
                name = "Limpwurt root",
                qty = 1,
            },
        },
    },
    ["Magic essence"] = {
        name = "Magic essence (3)",
        level = 57,
        xp = 130,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Magic essence (unfinished)",
                qty = 1,
                price = "no",
            },
            {
                name = "Gorak claw powder",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Luck potion"] = {
        name = "Luck potion",
        level = 57,
        xp = 123.5,
        dose = 1,
        mats = {
            {
                name = "Bloodweed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Crushed dragonstone",
                qty = 1,
            },
        },
    },
    ["Enhanced luck potion"] = {
        name = "Enhanced luck potion",
        level = 77,
        xp = 178,
        dose = 1,
        mats = {
            {
                name = "Luck potion",
                qty = 1,
            },
            {
                name = "Onyx bolt tips",
                qty = 6,
            },
        },
    },
    ["Fletching potion"] = {
        name = "Fletching potion (3)",
        level = 58,
        xp = 132,
        dose = 3,
        mats = {
            {
                name = "Wergali potion (unfinished)",
                qty = 1,
            },
            {
                name = "Wimpy feather",
                qty = 1,
            },
        },
    },
    ["Weapon poison"] = {
        name = "Weapon poison (3)",
        level = 60,
        xp = 137.5,
        dose = 3,
        mats = {
            {
                name = "Kwuarm potion (unfinished)",
                qty = 1,
            },
            {
                name = "Dragon scale dust",
                qty = 1,
            },
        },
    },
    ["Super restore"] = {
        name = "Super restore (3)",
        level = 63,
        xp = 142.5,
        dose = 3,
        mats = {
            {
                name = "Snapdragon potion (unfinished)",
                qty = 1,
            },
            {
                name = "Red spiders' eggs",
                qty = 1,
            },
        },
    },
    ["Super hunter"] = {
        name = "Super hunter (3)",
        level = 64,
        xp = 145,
        dose = 3,
        mats = {
            {
                name = "Hunter potion (3)",
                qty = 1,
            },
            {
                name = "Rabbit teeth",
                qty = 1,
            },
        },
    },
    ["Sanfew serum"] = {
        name = "Sanfew serum (3)",
        level = 65,
        xp = 60,
        dose = 3,
        mats = {
            {
                name = "Mixture - step 2 (3)",
                qty = 1,
            },
            {
                name = "Nail beast nails",
                qty = 1,
            },
        },
    },
    ["Camouflage potion"] = {
        name = "Camouflage potion (3)",
        level = 65,
        xp = 150,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Bloodweed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Black salamander",
                qty = 1,
            },
        },
    },
    ["Super defence"] = {
        name = "Super defence (3)",
        level = 66,
        xp = 150,
        dose = 3,
        mats = {
            {
                name = "Cadantine potion (unfinished)",
                qty = 1,
            },
            {
                name = "White berries",
                qty = 1,
            },
        },
    },
    ["Antipoison+"] = {
        name = "Antipoison+ (4)",
        level = 68,
        xp = 155,
        dose = 4,
        mats = {
            {
                name = "Antipoison+ (unfinished)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Yew roots",
                qty = 1,
            },
        },
    },
    ["Antifire"] = {
        name = "Antifire (3)",
        level = 69,
        xp = 157.5,
        dose = 3,
        mats = {
            {
                name = "Lantadyme potion (unfinished)",
                qty = 1,
            },
            {
                name = "Dragon scale dust",
                qty = 1,
            },
        },
    },
    ["Super divination"] = {
        name = "Super divination (3)",
        level = 70,
        xp = 160,
        dose = 3,
        mats = {
            {
                name = "Divination potion (3)",
                qty = 1,
            },
            {
                name = "Zygomite fruit",
                qty = 1,
            },
        },
    },
    ["Super woodcutting potion"] = {
        name = "Super woodcutting potion (3)",
        level = 71,
        xp = 161,
        dose = 3,
        mats = {
            {
                name = "Woodcutting potion (3)",
                qty = 1,
            },
            {
                name = "Enriched timber fungus",
                qty = 1,
            },
        },
    },
    ["Super ranging potion"] = {
        name = "Super ranging potion (3)",
        level = 72,
        xp = 162.5,
        dose = 3,
        mats = {
            {
                name = "Dwarf weed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Wine of Zamorak",
                qty = 1,
            },
        },
    },
    ["Weapon poison+"] = {
        name = "Weapon poison+ (3)",
        level = 73,
        xp = 165,
        dose = 3,
        mats = {
            {
                name = "Weapon poison+ (unfinished)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Red spiders' eggs",
                qty = 1,
            },
        },
    },
    ["Super mining potion"] = {
        name = "Super mining potion (3)",
        level = 74,
        xp = 167.5,
        dose = 3,
        mats = {
            {
                name = "Mining potion (3)",
                qty = 1,
            },
            {
                name = "Enriched calcified fungus",
                qty = 1,
            },
        },
    },
    ["Super fishing potion"] = {
        name = "Super fishing potion (3)",
        level = 75,
        xp = 170,
        dose = 3,
        mats = {
            {
                name = "Fishing potion (3)",
                qty = 1,
            },
            {
                name = "Enriched fungal algae",
                qty = 1,
            },
        },
    },
    ["Super runecrafting"] = {
        name = "Super runecrafting (3)",
        level = 75,
        xp = 170,
        dose = 3,
        mats = {
            {
                name = "Runecrafting potion (3)",
                qty = 1,
            },
            {
                name = "Yak milk",
                qty = 1,
            },
        },
    },
    ["Super magic potion"] = {
        name = "Super magic potion (3)",
        level = 76,
        xp = 172.5,
        dose = 3,
        mats = {
            {
                name = "Lantadyme potion (unfinished)",
                qty = 1,
            },
            {
                name = "Potato cactus",
                qty = 1,
            },
        },
    },
    ["Stamina potion"] = {
        name = "Stamina potion (3)",
        level = 77,
        xp = 175,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super energy (3)",
                qty = 1,
            },
            {
                name = "Arbuck potion (unfinished)",
                qty = 1,
            },
        },
    },
    ["Invention potion"] = {
        name = "Invention potion (3)",
        level = 77,
        xp = 175,
        dose = 3,
        mats = {
            {
                name = "Snapdragon potion (unfinished)",
                qty = 1,
            },
            {
                name = "Chinchompa residue",
                qty = 1,
            },
        },
    },
    ["Archaeology potion"] = {
        name = "Archaeology potion (3)",
        level = 78,
        xp = 175,
        dose = 3,
        recipes = {
            {
                method = "Using ancient gravel",
                mats = {
                    {
                        name = "Avantoe potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Ancient gravel",
                        qty = 5,
                    },
                },
            },
            {
                method = "Using fiery brimstone",
                mats = {
                    {
                        name = "Avantoe potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Fiery brimstone",
                        qty = 5,
                    },
                },
            },
            {
                method = "Using saltwater mud",
                mats = {
                    {
                        name = "Avantoe potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Saltwater mud",
                        qty = 5,
                    },
                },
            },
            {
                method = "Using aerated sediment",
                mats = {
                    {
                        name = "Avantoe potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Aerated sediment",
                        qty = 5,
                    },
                },
            },
            {
                method = "Using earthen clay",
                mats = {
                    {
                        name = "Avantoe potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Earthen clay",
                        qty = 5,
                    },
                },
            },
            {
                method = "Using volcanic ash",
                mats = {
                    {
                        name = "Avantoe potion (unfinished)",
                        qty = 1,
                    },
                    {
                        name = "Volcanic ash",
                        qty = 5,
                    },
                },
            },
        }
    },
    ["Zamorak brew"] = {
        name = "Zamorak brew (3)",
        level = 78,
        xp = 175,
        dose = 3,
        mats = {
            {
                name = "Torstol potion (unfinished)",
                qty = 1,
            },
            {
                name = "Jangerberries",
                qty = 1,
            },
        },
    },
    ["Super cooking potion"] = {
        name = "Super cooking potion (3)",
        level = 79,
        xp = 177.5,
        dose = 3,
        mats = {
            {
                name = "Cooking potion (3)",
                qty = 1,
            },
            {
                name = "Zygomite fruit",
                qty = 1,
            },
        },
    },
    ["Antipoison++"] = {
        name = "Antipoison++ (4)",
        level = 79,
        xp = 177.5,
        dose = 4,
        mats = {
            {
                name = "Antipoison++ (unfinished)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Magic roots",
                qty = 1,
            },
        },
    },
    ["Super necromancy"] = {
        name = "Super necromancy (3)",
        level = 79,
        xp = 177.5,
        dose = 3,
        mats = {
            {
                name = "Spirit weed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Congealed blood",
                qty = 5,
            },
        },
    },
    ["Saradomin brew"] = {
        name = "Saradomin brew (3)",
        level = 81,
        xp = 180,
        dose = 3,
        mats = {
            {
                name = "Toadflax potion (unfinished)",
                qty = 1,
            },
            {
                name = "Crushed nest",
                qty = 1,
            },
        },
    },
    ["Aggression potion"] = {
        name = "Aggression potion (3)",
        level = 82,
        xp = 185,
        dose = 3,
        mats = {
            {
                name = "Bloodweed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Searing ashes",
                qty = 1,
            },
        },
    },
    ["Weapon poison++"] = {
        name = "Weapon poison++ (3)",
        level = 82,
        xp = 190,
        dose = 3,
        mats = {
            {
                name = "Weapon poison++ (unfinished)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Poison ivy berries",
                qty = 1,
            },
        },
    },
    ["Super invention"] = {
        name = "Super invention (3)",
        level = 87,
        xp = 220,
        dose = 3,
        mats = {
            {
                name = "Invention potion (3)",
                qty = 1,
            },
            {
                name = "Spider fangs",
                qty = 1,
            },
        },
    },
    ["Summoning renewal"] = {
        name = "Summoning renewal (3)",
        level = 88,
        xp = 220,
        dose = 3,
        mats = {
            {
                name = "Spirit weed potion (unfinished)",
                qty = 1,
            },
            {
                name = "Tombshroom",
                qty = 1,
            },
        },
    },
    ["Prayer renewal"] = {
        name = "Prayer renewal (3)",
        level = 94,
        xp = 190,
        dose = 3,
        mats = {
            {
                name = "Fellstalk potion (unfinished)",
                qty = 1,
            },
            {
                name = "Morchella mushroom",
                qty = 1,
            },
        },
    },
    ["Harvest potion"] = {
        name = "Harvest potion (3)",
        level = 95,
        xp = 300,
        dose = 3,
        mats = {
            {
                name = "Primal extract",
                qty = 1,
            },
            {
                name = "Clean arbuck",
                qty = 1,
            },
            {
                name = "Watermelon",
                qty = 1,
            },
        },
    },
    ["Weapon poison+++"] = {
        name = "Weapon poison+++ (3)",
        level = 100,
        xp = 700,
        dose = 3,
        remaining_vial = { qty = 1, category = "standard" },
        mats = {
            {
                name = "Weapon poison++ (3)",
                qty = 1,
            },
            {
                name = "Poison slime",
                qty = 1,
            },
            {
                name = "Primal extract",
                qty = 1,
            },
        },
    },
    ["Charming potion"] = {
        name = "Charming potion (3)",
        level = 102,
        xp = 1000,
        dose = 3,
        mats = {
            {
                name = "Primal extract",
                qty = 1,
            },
            {
                name = "Gold charm",
                qty = 4,
                price = "no",
            },
            {
                name = "Green charm",
                qty = 4,
                price = "no",
            },
            {
                name = "Crimson charm",
                qty = 4,
                price = "no",
            },
            {
                name = "Blue charm",
                qty = 4,
                price = "no",
            },
            {
                name = "Spark chitin",
                qty = 1,
            },
        },
    },
    ["Extreme hunter"] = {
        name = "Extreme hunter (3)",
        level = 80,
        xp = 180,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super hunter (3)",
                qty = 1,
            },
            {
                name = "Bull horns",
                qty = 1,
            },
        },
    },
    ["Adrenaline potion"] = {
        name = "Adrenaline potion (3)",
        level = 84,
        xp = 200,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super energy (3)",
                qty = 1,
            },
            {
                name = "Papaya fruit",
                qty = 1,
            },
        },
    },
    ["Super antifire"] = {
        name = "Super antifire (3)",
        level = 85,
        xp = 210,
        dose = 3,
        mats = {
            {
                name = "Antifire (3)",
                qty = 1,
            },
            {
                name = "Phoenix feather",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Extreme antisanguine"] = {
        name = "Extreme antisanguine (3)",
        level = 85,
        xp = 210,
        dose = 3,
        mats = {
            {
                name = "Cadantine potion (unfinished)",
                qty = 1,
            },
            {
                name = "Mourning lily",
                qty = 1,
            },
        },
    },
    ["Super adrenaline potion"] = {
        name = "Super adrenaline potion (3)",
        level = 87,
        xp = 200,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Adrenaline potion (3)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Adrenaline crystal",
                qty = 1,
            },
        },
    },
    ["Extreme attack"] = {
        name = "Extreme attack (3)",
        level = 88,
        xp = 220,
        dose = 3,
        mats = {
            {
                name = "Super attack (3)",
                qty = 1,
            },
            {
                name = "Clean avantoe",
                qty = 1,
            },
        },
    },
    ["Extreme divination"] = {
        name = "Extreme divination (3)",
        level = 89,
        xp = 230,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super divination (3)",
                qty = 1,
            },
            {
                name = "Yak tuft",
                qty = 1,
            },
        },
    },
    ["Extreme strength"] = {
        name = "Extreme strength (3)",
        level = 89,
        xp = 230,
        dose = 3,
        mats = {
            {
                name = "Super strength (3)",
                qty = 1,
            },
            {
                name = "Clean dwarf weed",
                qty = 1,
            },
        },
    },
    ["Extreme defence"] = {
        name = "Extreme defence (3)",
        level = 90,
        xp = 240,
        dose = 3,
        mats = {
            {
                name = "Super defence (3)",
                qty = 1,
            },
            {
                name = "Clean lantadyme",
                qty = 1,
            },
        },
    },
    ["Extended super antifire"] = {
        name = "Extended super antifire (3)",
        level = 90,
        xp = 210,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super antifire (3)",
                qty = 1,
            },
            {
                name = "Clean arbuck",
                qty = 1,
            },
        },
    },
    ["Extreme magic"] = {
        name = "Extreme magic (3)",
        level = 91,
        xp = 250,
        dose = 3,
        mats = {
            {
                name = "Super magic potion (3)",
                qty = 1,
            },
            {
                name = "Ground mud runes",
                qty = 1,
            },
        },
    },
    ["Extreme runecrafting"] = {
        name = "Extreme runecrafting (3)",
        level = 91,
        xp = 250,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super runecrafting (3)",
                qty = 1,
            },
            {
                name = "Spider venom",
                qty = 1,
            },
        },
    },
    ["Extreme ranging"] = {
        name = "Extreme ranging (3)",
        level = 92,
        xp = 260,
        dose = 3,
        mats = {
            {
                name = "Super ranging potion (3)",
                qty = 1,
            },
            {
                name = "Grenwall spikes",
                qty = 5,
            },
        },
    },
    ["Extreme necromancy"] = {
        name = "Extreme necromancy (3)",
        level = 93,
        xp = 265,
        dose = 3,
        mats = {
            {
                name = "Super necromancy (3)",
                qty = 1,
            },
            {
                name = "Ground miasma rune",
                qty = 1,
            },
        },
    },
    ["Super Saradomin brew"] = {
        name = "Super Saradomin brew (3)",
        level = 93,
        xp = 180,
        dose = 3,
        mats = {
            {
                name = "Saradomin brew (3)",
                qty = 1,
            },
            {
                name = "Wine of Saradomin",
                qty = 1,
            },
        },
    },
    ["Super Zamorak brew"] = {
        name = "Super Zamorak brew (3)",
        level = 93,
        xp = 180,
        dose = 3,
        mats = {
            {
                name = "Zamorak brew (3)",
                qty = 1,
            },
            {
                name = "Wine of Zamorak",
                qty = 1,
            },
        },
    },
    ["Super Guthix rest"] = {
        name = "Super Guthix rest (3)",
        level = 93,
        xp = 59.5,
        dose = 3,
        mats = {
            {
                name = "Guthix rest (3)",
                qty = 1,
            },
            {
                name = "Wine of Guthix",
                qty = 1,
            },
        },
    },
    ["Super prayer"] = {
        name = "Super prayer (3)",
        level = 94,
        xp = 270,
        dose = 3,
        recipes = {
            {
                method = "Using ground wyvern bones",
                mats = {
                    {
                        name = "Prayer potion (3)",
                        qty = 1,
                    },
                    {
                        name = "Ground wyvern bones",
                        qty = 1,
                        price = "calcvalue"
                    },
                },
            },
            {
                method = "Using wyvern bonemeal",
                mats = {
                    {
                        name = "Prayer potion (3)",
                        qty = 1,
                    },
                    {
                        name = "Wyvern bonemeal",
                        qty = 1,
                        price = "calcvalue"
                    },
                },
            },
        },
    },
    ["Extreme invention"] = {
        name = "Extreme invention (3)",
        level = 95,
        xp = 300,
        dose = 3,
        price = "no",
        mats = {
            {
                name = "Super invention (3)",
                qty = 1,
            },
            {
                name = "Mycelial webbing",
                qty = 1,
            },
        },
    },
    ["Overload"] = {
        name = "Overload (3)",
        dose = 3,
        price = "no",
        recipes = {
            {
                level = 96,
                xp = 1000,
                ingredient_set = false,
                remaining_vial = { qty = 5, category = "standard" },
                mats = {
                    {
                        name = "Extreme attack (3)",
                        qty = 1,
                    },
                    {
                        name = "Extreme strength (3)",
                        qty = 1,
                    },
                    {
                        name = "Extreme defence (3)",
                        qty = 1,
                    },
                    {
                        name = "Extreme magic (3)",
                        qty = 1,
                    },
                    {
                        name = "Extreme ranging (3)",
                        qty = 1,
                    },
                    {
                        name = "Extreme necromancy (3)",
                        qty = 1,
                    },
                    {
                        name = "Clean torstol",
                        qty = 1,
                    },
                },
            },
            {
                level = 96,
                xp = 1000,
                ingredient_set = true,
                method = "Using ingredient set",
                remaining_vial = { qty = 4, category = "standard" },
                mats = {
                    {
                        name = "Overload ingredient set",
                        qty = 1,
                    },
                },
            },
            {
                level = 96,
                xp = 4000,
                multiplier = 5,
                tick = 8,
                soc_quicker = false,
                cape120_required = true,
                ingredient_set = false,
                method = "Batch of overload (3)",
                remaining_vial = { qty = 19, category = "standard" },
                mats = {
                    {
                        name = "Extreme attack (3)",
                        qty = 4,
                    },
                    {
                        name = "Extreme strength (3)",
                        qty = 4,
                    },
                    {
                        name = "Extreme defence (3)",
                        qty = 4,
                    },
                    {
                        name = "Extreme magic (3)",
                        qty = 4,
                    },
                    {
                        name = "Extreme ranging (3)",
                        qty = 4,
                    },
                    {
                        name = "Extreme necromancy (3)",
                        qty = 4,
                    },
                    {
                        name = "Clean torstol",
                        qty = 4,
                    },
                },
            },
            {
                level = 96,
                xp = 4000,
                multiplier = 5,
                tick = 8,
                soc_quicker = false,
                cape120_required = true,
                ingredient_set = true,
                method = "Batch of overload (3) with ingredient sets",
                remaining_vial = { qty = 15, category = "standard" },
                mats = {
                    {
                        name = "Overload ingredient set",
                        qty = 4,
                    },
                },
            },
        }
    },
    ["Extreme cooking potion"] = {
        name = "Extreme cooking potion (3)",
        level = 104,
        xp = 800,
        dose = 3,
        price = "no",
        remaining_vial = { qty = 1, category = "standard" },
        mats = {
            {
                name = "Super cooking potion (3)",
                qty = 1,
            },
            {
                name = "Primal extract",
                qty = 1,
            },
            {
                name = "Beak snot",
                qty = 1,
            },
        },
    },
    ["Extreme prayer potion"] = {
        name = "Extreme prayer potion (3)",
        level = 117,
        xp = 1200,
        dose = 3,
        price = "no",
        four_dose = "Extreme prayer (4)",
        remaining_vial = { qty = 1, category = "standard" },
        mats = {
            {
                name = "Primal extract",
                qty = 1,
            },
            {
                name = "Super prayer (3)",
                qty = 1,
            },
            {
                name = "Spark chitin",
                qty = 1,
            },
        },
    },
    ["Adrenaline renewal potion"] = {
        name = "Adrenaline renewal potion (4)",
        price = "no",
        dose = 4,
        recipes = {
            {
                level = 115,
                xp = 1700,
                method = "Using super adrenaline potion",
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Super adrenaline potion (4)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 2,
                    },
                    {
                        name = "Clean arbuck",
                        qty = 1,
                    },
                },
            },
            {
                level = 115,
                xp = 1243,
                method = "Using enhanced replenishment potion",
                mats = {
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Enhanced replenishment potion (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 2,
                    },
                    {
                        name = "Clean arbuck",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 119,
                xp = 1700,
                method = "Using super adrenaline potion",
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Super adrenaline potion (4)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 1,
                    },
                    {
                        name = "Clean arbuck",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 119,
                xp = 1243,
                method = "Using enhanced replenishment potion",
                mats = {
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Enhanced replenishment potion (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 1,
                    },
                    {
                        name = "Clean arbuck",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Spirit attraction potion"] = {
        name = "Spirit attraction potion (3)",
        level = 116,
        xp = 1100,
        dose = 3,
        remaining_vial = { qty = 1, category = "standard" },
        mats = {
            {
                name = "Primal extract",
                qty = 1,
            },
            {
                name = "Enhanced luck potion",
                qty = 1,
            },
            {
                name = "Timeworn tincture",
                qty = 1,
            },
        },
    },
}

p.combinations = {
    ["Grand strength potion"] = {
        name = "Grand strength potion (6)",
        level = 75,
        xp = 123.8,
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super strength (4)",
                qty = 1,
            },
            {
                name = "Strength potion (4)",
                qty = 1,
            },
        },
    },
    ["Grand ranging potion"] = {
        name = "Grand ranging potion (6)",
        level = 76,
        xp = 144.4,
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super ranging potion (4)",
                qty = 1,
            },
            {
                name = "Ranging potion (4)",
                qty = 1,
            },
        },
    },
    ["Grand magic potion"] = {
        name = "Grand magic potion (6)",
        level = 77,
        xp = 155.7,
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super magic potion (4)",
                qty = 1,
            },
            {
                name = "Magic potion (4)",
                qty = 1,
            },
        },
    },
    ["Grand attack potion"] = {
        name = "Grand attack potion (6)",
        level = 78,
        xp = 93.8,
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super attack (4)",
                qty = 1,
            },
            {
                name = "Attack potion (4)",
                qty = 1,
            },
        },
    },
    ["Grand defence potion"] = {
        name = "Grand defence potion (6)",
        level = 79,
        xp = 146.3,
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super defence (4)",
                qty = 1,
            },
            {
                name = "Defence potion (4)",
                qty = 1,
            },
        },
    },
    ["Super melee potion"] = {
        name = "Super melee potion (6)",
        level = 81,
        xp = 281.3,
        remaining_vial = { qty = 3, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super attack (4)",
                qty = 1,
            },
            {
                name = "Super strength (4)",
                qty = 1,
            },
            {
                name = "Super defence (4)",
                qty = 1,
            },
        },
    },
    ["Super warmaster's potion"] = {
        name = "Super warmaster's potion (6)",
        level = 85,
        xp = 500,
        remaining_vial = { qty = 5, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super attack (4)",
                qty = 1,
            },
            {
                name = "Super strength (4)",
                qty = 1,
            },
            {
                name = "Super defence (4)",
                qty = 1,
            },
            {
                name = "Super ranging potion (4)",
                qty = 1,
            },
            {
                name = "Super magic potion (4)",
                qty = 1,
            },
        },
    },
    ["Replenishment potion"] = {
        name = "Replenishment potion (6)",
        level = 87,
        xp = 256.9,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Adrenaline potion (4)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Super restore (4)",
                qty = 1,
            },
        },
    },
    ["Wyrmfire potion"] = {
        name = "Wyrmfire potion (6)",
        level = 89,
        xp = 275.7,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Super antifire (4)",
                qty = 1,
            },
            {
                name = "Antifire (4)",
                qty = 1,
            },
        },
    },
    ["Enhanced replenishment potion"] = {
        name = "Enhanced replenishment potion (6)",
        level = 90,
        xp = 256.9,
        price = "no",
        mats = {
            {
                name = "Replenishment potion (6)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Adrenaline crystal",
                qty = 1,
            },
        },
    },
    ["Extreme brawler's potion"] = {
        name = "Extreme brawler's potion (6)",
        level = 91,
        xp = 367.5,
        price = "no",
        remaining_vial = { qty = 3, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme attack (4)",
                qty = 1,
            },
            {
                name = "Extreme strength (4)",
                qty = 1,
            },
            {
                name = "Extreme defence (4)",
                qty = 1,
            },
        },
    },
    ["Extreme battlemage's potion"] = {
        name = "Extreme battlemage's potion (6)",
        level = 91,
        xp = 367.5,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme magic (4)",
                qty = 1,
            },
            {
                name = "Extreme defence (4)",
                qty = 1,
            },
        },
    },
    ["Extreme sharpshooter's potion"] = {
        name = "Extreme sharpshooter's potion (6)",
        level = 91,
        xp = 367.5,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme ranging (4)",
                qty = 1,
            },
            {
                name = "Extreme defence (4)",
                qty = 1,
            },
        },
    },
    ["Extreme warmaster's potion"] = {
        name = "Extreme warmaster's potion (6)",
        level = 93,
        xp = 500,
        price = "no",
        remaining_vial = { qty = 5, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme attack (4)",
                qty = 1,
            },
            {
                name = "Extreme strength (4)",
                qty = 1,
            },
            {
                name = "Extreme defence (4)",
                qty = 1,
            },
            {
                name = "Extreme ranging (4)",
                qty = 1,
            },
            {
                name = "Extreme magic (4)",
                qty = 1,
            },
        },
    },
    ["Supreme attack potion"] = {
        name = "Supreme attack potion (6)",
        level = 93,
        xp = 240,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme attack (4)",
                qty = 1,
            },
            {
                name = "Super attack (4)",
                qty = 1,
            },
        },
    },
    ["Supreme strength potion"] = {
        name = "Supreme strength potion (6)",
        level = 93,
        xp = 266.3,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme strength (4)",
                qty = 1,
            },
            {
                name = "Super strength (4)",
                qty = 1,
            },
        },
    },
    ["Supreme defence potion"] = {
        name = "Supreme defence potion (6)",
        level = 93,
        xp = 292.5,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme defence (4)",
                qty = 1,
            },
            {
                name = "Super defence (4)",
                qty = 1,
            },
        },
    },
    ["Supreme magic potion"] = {
        name = "Supreme magic potion (6)",
        level = 93,
        xp = 316.9,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme magic (4)",
                qty = 1,
            },
            {
                name = "Super magic potion (4)",
                qty = 1,
            },
        },
    },
    ["Supreme ranging potion"] = {
        name = "Supreme ranging potion (6)",
        level = 93,
        xp = 217.5,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Extreme ranging (4)",
                qty = 1,
            },
            {
                name = "Super ranging potion (4)",
                qty = 1,
            },
        },
    },
    ["Brightfire potion"] = {
        name = "Brightfire potion (6)",
        level = 94,
        xp = 300,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Prayer renewal (4)",
                qty = 1,
            },
            {
                name = "Super antifire (4)",
                qty = 1,
            },
        },
    },
    ["Aggroverload"] = {
        name = "Aggroverload (6)",
        level = 96,
        xp = 325,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Overload (4)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Clean arbuck",
                qty = 1,
            },
            {
                name = "Aggression potion (4)",
                qty = 1,
            },
        },
    },
    ["Super prayer renewal potion"] = {
        name = "Super prayer renewal potion (6)",
        level = 96,
        xp = 208.2,
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Prayer renewal (4)",
                qty = 1,
            },
            {
                name = "Prayer potion (4)",
                qty = 1,
            },
        },
    },
    ["Holy overload potion"] = {
        name = "Holy overload potion (6)",
        level = 97,
        xp = 350,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Overload (4)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Prayer renewal (4)",
                qty = 1,
            },
        },
    },
    ["Searing overload potion"] = {
        name = "Searing overload potion (6)",
        level = 97,
        xp = 350,
        price = "no",
        remaining_vial = { qty = 2, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Overload (4)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Super antifire (4)",
                qty = 1,
            },
        },
    },
    ["Overload salve"] = {
        name = "Overload salve (6)",
        level = 97,
        xp = 500,
        price = "no",
        remaining_vial = { qty = 6, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Overload (4)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Super antifire (4)",
                qty = 1,
            },
            {
                name = "Antifire (4)",
                qty = 1,
            },
            {
                name = "Prayer renewal (4)",
                qty = 1,
            },
            {
                name = "Prayer potion (4)",
                qty = 1,
            },
            {
                name = "Super antipoison (4)",
                qty = 1,
            },
        },
    },
    ["Holy aggroverload"] = {
        name = "Holy aggroverload (6)",
        price = "no",
        recipes = {
            {
                level = 98,
                xp = 600,
                method = "Using overload",
                remaining_vial = { qty = 3, category = "standard" },
                mats = {
                    {
                        name = "Crystal flask",
                        qty = 1,
                    },
                    {
                        name = "Overload (4)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Aggression potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Prayer renewal (4)",
                        qty = 1,
                    },
                    {
                        name = "Spider venom",
                        qty = 1,
                    },
                },
            },
            {
                level = 98,
                xp = 275,
                method = "Using aggroverload",
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Aggroverload (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Prayer renewal (4)",
                        qty = 1,
                    },
                    {
                        name = "Spider venom",
                        qty = 1,
                    },
                },
            },
            {
                level = 98,
                xp = 250,
                method = "Using holy overload potion",
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Holy overload potion (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Aggression potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Spider venom",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Supreme overload potion"] = {
        name = "Supreme overload potion (6)",
        price = "no",
        recipes = {
            {
                level = 98,
                xp = 600,
                remaining_vial = { qty = 6, category = "standard" },
                mats = {
                    {
                        name = "Crystal flask",
                        qty = 1,
                    },
                    {
                        name = "Overload (4)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Super attack (4)",
                        qty = 1,
                    },
                    {
                        name = "Super strength (4)",
                        qty = 1,
                    },
                    {
                        name = "Super defence (4)",
                        qty = 1,
                    },
                    {
                        name = "Super ranging potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Super magic potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Super necromancy (4)",
                        qty = 1,
                    },
                },
            },
            {
                level = 98,
                xp = 1800,
                multiplier = 4,
                tick = 8,
                soc_quicker = false,
                cape120_required = true,
                method = "Batch of supreme overload potion (6)",
                remaining_vial = { qty = 21, category = "standard" },
                mats = {
                    {
                        name = "Crystal flask",
                        qty = 3,
                    },
                    {
                        name = "Overload (4)",
                        qty = 3,
                        price = "calcvalue",
                    },
                    {
                        name = "Super attack (4)",
                        qty = 3,
                    },
                    {
                        name = "Super strength (4)",
                        qty = 3,
                    },
                    {
                        name = "Super defence (4)",
                        qty = 3,
                    },
                    {
                        name = "Super ranging potion (4)",
                        qty = 3,
                    },
                    {
                        name = "Super magic potion (4)",
                        qty = 3,
                    },
                    {
                        name = "Super necromancy (4)",
                        qty = 3,
                    },
                },
            },
        }
    },
    ["Supreme overload salve"] = {
        name = "Supreme overload salve (6)",
        level = 99,
        xp = 700,
        price = "no",
        remaining_vial = { qty = 5, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Supreme overload potion (6)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Super antifire (4)",
                qty = 1,
            },
            {
                name = "Antifire (4)",
                qty = 1,
            },
            {
                name = "Prayer renewal (4)",
                qty = 1,
            },
            {
                name = "Prayer potion (4)",
                qty = 1,
            },
            {
                name = "Super antipoison (4)",
                qty = 1,
            },
        },
    },
    ["Perfect plus potion"] = {
        name = "Perfect plus potion (6)",
        level = 99,
        xp = 1000,
        price = "no",
        remaining_vial = { qty = 1, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Overload (4)",
                qty = 1,
                price = "calcvalue",
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
            {
                name = "Crystal tree blossom",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Elder overload potion"] = {
        name = "Elder overload potion (6)",
        price = "no",
        recipes = {
            {
                level = 106,
                xp = 850,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Supreme overload potion (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Clean fellstalk",
                        qty = 1,
                    },
                },
            },
            {
                level = 106,
                xp = 3400,
                multiplier = 5,
                tick = 8,
                soc_quicker = false,
                cape120_required = true,
                method = "Batch of elder overload potion (6)",
                remaining_vial = { qty = 4, category = "standard" },
                mats = {
                    {
                        name = "Supreme overload potion (6)",
                        qty = 4,
                        price = "calcvalue",
                    },
                    {
                        name = "Primal extract",
                        qty = 4,
                    },
                    {
                        name = "Clean fellstalk",
                        qty = 4,
                    },
                },
            },
        }
    },
    ["Elder overload salve"] = {
        name = "Elder overload salve (6)",
        price = "no",
        recipes = {
            {
                level = 107,
                xp = 750,
                method = "Using elder overload potion",
                remaining_vial = { qty = 5, category = "standard" },
                mats = {
                    {
                        name = "Elder overload potion (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Super antifire (4)",
                        qty = 1,
                    },
                    {
                        name = "Antifire (4)",
                        qty = 1,
                    },
                    {
                        name = "Prayer renewal (4)",
                        qty = 1,
                    },
                    {
                        name = "Prayer potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Super antipoison (4)",
                        qty = 1,
                    },
                },
            },
            {
                level = 107,
                xp = 900,
                method = "Using supreme overload salve",
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Supreme overload salve (6)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Clean fellstalk",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Spiritual prayer potion"] = {
        name = "Spiritual prayer potion (6)",
        level = 110,
        xp = 850,
        remaining_vial = { qty = 3, category = "standard" },
        mats = {
            {
                name = "Crystal flask",
                qty = 1,
            },
            {
                name = "Primal extract",
                qty = 1,
            },
            {
                name = "Prayer potion (4)",
                qty = 1,
            },
            {
                name = "Summoning potion (4)",
                qty = 1,
            },
        },
    },
}

p.powerburst = {
    ["Powerburst of opportunity"] = {
        name = "Powerburst of opportunity (4)",
        recipes = {
            {
                level = 103,
                xp = 1050,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Dinosaur claws",
                        qty = 2,
                    },
                    {
                        name = "Phasmatite",
                        qty = 1,
                    },
                    {
                        name = "Third Age iron",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 107,
                xp = 1050,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Dinosaur claws",
                        qty = 1,
                    },
                    {
                        name = "Phasmatite",
                        qty = 1,
                    },
                    {
                        name = "Third Age iron",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Powerburst of vitality"] = {
        name = "Powerburst of vitality (4)",
        recipes = {
            {
                level = 105,
                xp = 1150,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Poison slime",
                        qty = 2,
                    },
                    {
                        name = "Saradomin brew (4)",
                        qty = 1,
                    },
                    {
                        name = "Rocktail",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 109,
                xp = 1150,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Poison slime",
                        qty = 1,
                    },
                    {
                        name = "Saradomin brew (3)",
                        qty = 1,
                    },
                    {
                        name = "Rocktail",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Powerburst of masterstroke"] = {
        name = "Powerburst of masterstroke (4)",
        recipes = {
            {
                level = 108,
                xp = 1350,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Runite stone spirit",
                        qty = 3,
                    },
                    {
                        name = "Necrite stone spirit",
                        qty = 3,
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 2,
                    },
                },
            },
            {
                improved = 2,
                level = 112,
                xp = 1350,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Runite stone spirit",
                        qty = 2,
                    },
                    {
                        name = "Necrite stone spirit",
                        qty = 2,
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Powerburst of sorcery"] = {
        name = "Powerburst of sorcery (4)",
        recipes = {
            {
                level = 109,
                xp = 1400,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Super runecrafting (4)",
                        qty = 1,
                    },
                    {
                        name = "Blood rune",
                        qty = 5,
                        soc = 'no',
                    },
                    {
                        name = "Beak snot",
                        qty = 2,
                    },
                },
            },
            {
                improved = 2,
                level = 113,
                xp = 1400,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Super runecrafting (3)",
                        qty = 1,
                    },
                    {
                        name = "Blood rune",
                        qty = 3,
                        soc = 'no',
                    },
                    {
                        name = "Beak snot",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Powerburst of acceleration"] = {
        name = "Powerburst of acceleration (4)",
        recipes = {
            {
                level = 111,
                xp = 1500,
                remaining_vial = { qty = 2, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Stamina potion (4)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Energy potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Spark chitin",
                        qty = 2,
                    },
                },
            },
            {
                improved = 2,
                level = 115,
                xp = 1500,
                tick = 2,
                remaining_vial = { qty = 2, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Stamina potion (3)",
                        qty = 1,
                        price = "calcvalue",
                    },
                    {
                        name = "Energy potion (3)",
                        qty = 1,
                    },
                    {
                        name = "Spark chitin",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Powerburst of feats"] = {
        name = "Powerburst of feats (4)",
        recipes = {
            {
                level = 114,
                xp = 1600,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Clean snapdragon",
                        qty = 1,
                    },
                    {
                        name = "Summoning potion (4)",
                        qty = 1,
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 2,
                    },
                },
            },
            {
                improved = 2,
                level = 118,
                xp = 1600,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Powerburst vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Clean snapdragon",
                        qty = 1,
                    },
                    {
                        name = "Summoning potion (3)",
                        qty = 1,
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 1,
                    },
                },
            },
        },
    },
}

p.bomb = {
    ["Poison bomb"] = {
        name = "Poison bomb",
        recipes = {
            {
                level = 99,
                xp = 950,
                remaining_vial = { qty = 2, category = "standard" },
                mats = {
                    {
                        name = "Bomb vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Clean irit",
                        qty = 1,
                    },
                    {
                        name = "Poison slime",
                        qty = 2,
                    },
                    {
                        name = "Weapon poison++ (4)",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 103,
                xp = 950,
                tick = 2,
                remaining_vial = { qty = 2, category = "standard" },
                mats = {
                    {
                        name = "Bomb vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Clean irit",
                        qty = 1,
                    },
                    {
                        name = "Poison slime",
                        qty = 1,
                    },
                    {
                        name = "Weapon poison++ (3)",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Sticky bomb"] = {
        name = "Sticky bomb",
        recipes = {
            {
                level = 101,
                xp = 1000,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Bomb vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Beak snot",
                        qty = 2,
                    },
                    {
                        name = "Dinosaur claws",
                        qty = 2,
                    },
                    {
                        name = "Clean cadantine",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 105,
                xp = 1000,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Bomb vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Beak snot",
                        qty = 1,
                    },
                    {
                        name = "Dinosaur claws",
                        qty = 1,
                    },
                    {
                        name = "Clean cadantine",
                        qty = 1,
                    },
                },
            },
        },
    },
    ["Vulnerability bomb"] = {
        name = "Vulnerability bomb",
        recipes = {
            {
                level = 103,
                xp = 1100,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Bomb vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Soul rune",
                        qty = 5,
                        soc = 'no',
                    },
                    {
                        name = "Chaos rune",
                        qty = 5,
                        soc = 'no',
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 2,
                    },
                    {
                        name = "Clean dwarf weed",
                        qty = 1,
                    },
                },
            },
            {
                improved = 2,
                level = 107,
                xp = 1100,
                tick = 2,
                remaining_vial = { qty = 1, category = "standard" },
                mats = {
                    {
                        name = "Bomb vial",
                        qty = 1,
                    },
                    {
                        name = "Primal extract",
                        qty = 1,
                    },
                    {
                        name = "Soul rune",
                        qty = 3,
                        soc = 'no',
                    },
                    {
                        name = "Chaos rune",
                        qty = 3,
                        soc = 'no',
                    },
                    {
                        name = "Bottled dinosaur roar",
                        qty = 1,
                    },
                    {
                        name = "Clean dwarf weed",
                        qty = 1,
                    },
                },
            },
        },
    },
}

p.primal_pulp = {
    ["Avocado"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 5,
        mats = {
            {
                name = "Avocado",
                qty = 1,
            }
        },
    },
    ["Carambola"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 6,
        mats = {
            {
                name = "Carambola",
                qty = 1,
            }
        },
    },
    ["Ciku"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 4,
        mats = {
            {
                name = "Ciku",
                qty = 1,
            }
        },
    },
    ["Dragonfruit"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 7,
        mats = {
            {
                name = "Dragonfruit",
                qty = 1,
            }
        },
    },
    ["Golden dragonfruit"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 8,
        mats = {
            {
                name = "Golden dragonfruit",
                qty = 1,
            }
        },
    },
    ["Guarana"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 5,
        mats = {
            {
                name = "Guarana",
                qty = 1,
            }
        },
    },
    ["Lychee"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 7,
        mats = {
            {
                name = "Lychee",
                qty = 1,
            }
        },
    },
    ["Mango"] = {
        name = "Primal fruit pulp",
        level = 90,
        xp = 10,
        multiplier = 6,
        mats = {
            {
                name = "Mango",
                qty = 1,
            }
        },
    },
}

p.primal = {
    ["Regular portion"] = {
        name = "Primal extract",
        level = 90,
        xp = 145,
        mats = {
            {
                name = "Vial",
                qty = 1,
            },
            {
                name = "Primal fruit pulp",
                qty = 1,
            },
        },
    },
    ["Improved yield +1"] = {
        name = "Primal extract",
        improved = 1,
        multiplier = 2,
        level = 102,
        xp = 145,
        mats = {
            {
                name = "Vial",
                qty = 2,
            },
            {
                name = "Primal fruit pulp",
                qty = 1,
            },
        },
    },
    ["Improved yield +2"] = {
        name = "Primal extract",
        improved = 2,
        multiplier = 3,
        level = 112,
        xp = 145,
        mats = {
            {
                name = "Vial",
                qty = 3,
            },
            {
                name = "Primal fruit pulp",
                qty = 1,
            },
        },
    },
}

p.adrenaline = {
    ["Adrenaline crystal"] = {
        name = "Adrenaline crystal",
        level = 93,
        xp = 10,
        remaining_vial = { qty = 1, category = "standard" },
        mats = {
            {
                name = "Inert adrenaline crystal",
                qty = 1,
            },
            {
                name = "Spark chitin",
                qty = 1,
            },
            {
                name = "Primal extract",
                qty = 1,
            },
        },
    },
}

p.juju = {
    ["Juju hunter potion"] = {
        name = "Juju hunter potion (3)",
        level = 54,
        xp = 123,
        dose = 3,
        mats = {
            {
                name = "Erzille potion (unfinished)",
                qty = 1,
            },
            {
                name = "Corrupt vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Scentless potion"] = {
        name = "Scentless potion (3)",
        level = 59,
        xp = 135,
        dose = 3,
        mats = {
            {
                name = "Argway potion (unfinished)",
                qty = 1,
            },
            {
                name = "Shadow vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Juju farming potion"] = {
        name = "Juju farming potion (3)",
        level = 64,
        xp = 146,
        dose = 3,
        mats = {
            {
                name = "Ugune potion (unfinished)",
                qty = 1,
            },
            {
                name = "Marble vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Juju cooking potion"] = {
        name = "Juju cooking potion (3)",
        level = 67,
        xp = 152,
        dose = 3,
        mats = {
            {
                name = "Shengo potion (unfinished)",
                qty = 1,
            },
            {
                name = "Plant teeth",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Juju fishing potion"] = {
        name = "Juju fishing potion (3)",
        level = 70,
        xp = 158,
        dose = 3,
        mats = {
            {
                name = "Shengo potion (unfinished)",
                qty = 1,
            },
            {
                name = "Aquatic vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Juju woodcutting potion"] = {
        name = "Juju woodcutting potion (3)",
        level = 71,
        xp = 160,
        dose = 3,
        mats = {
            {
                name = "Samaden potion (unfinished)",
                qty = 1,
            },
            {
                name = "Oily vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Juju mining potion"] = {
        name = "Juju mining potion (3)",
        level = 74,
        xp = 168,
        dose = 3,
        mats = {
            {
                name = "Samaden potion (unfinished)",
                qty = 1,
            },
            {
                name = "Draconic vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Saradomin's blessing"] = {
        name = "Saradomin's blessing (3)",
        level = 75,
        xp = 179,
        dose = 3,
        mats = {
            {
                name = "Samaden potion (unfinished)",
                qty = 1,
            },
            {
                name = "Saradomin vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Guthix's gift"] = {
        name = "Guthix's gift (3)",
        level = 75,
        xp = 179,
        dose = 3,
        mats = {
            {
                name = "Samaden potion (unfinished)",
                qty = 1,
            },
            {
                name = "Guthix vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Zamorak's favour"] = {
        name = "Zamorak's favour (3)",
        level = 75,
        xp = 179,
        dose = 3,
        mats = {
            {
                name = "Samaden potion (unfinished)",
                qty = 1,
            },
            {
                name = "Zamorak vine",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Perfect juju woodcutting potion"] = {
        name = "Perfect juju woodcutting potion (3)",
        level = 75,
        xp = 120,
        dose = 3,
        mats = {
            {
                name = "Juju woodcutting potion (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju farming potion"] = {
        name = "Perfect juju farming potion (3)",
        level = 77,
        xp = 109.5,
        dose = 3,
        mats = {
            {
                name = "Juju farming potion (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju mining potion"] = {
        name = "Perfect juju mining potion (3)",
        level = 80,
        xp = 126,
        dose = 3,
        mats = {
            {
                name = "Juju mining potion (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju smithing potion"] = {
        name = "Perfect juju smithing potion (3)",
        level = 82,
        xp = 92.3,
        dose = 3,
        mats = {
            {
                name = "Juju hunter potion (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju agility potion"] = {
        name = "Perfect juju agility potion (3)",
        level = 85,
        xp = 101.3,
        dose = 3,
        mats = {
            {
                name = "Scentless potion (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju prayer potion"] = {
        name = "Perfect juju prayer potion (3)",
        level = 87,
        xp = 127.5,
        dose = 3,
        mats = {
            {
                name = "Saradomin's blessing (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju herblore potion"] = {
        name = "Perfect juju herblore potion (3)",
        level = 90,
        xp = 127.5,
        dose = 3,
        mats = {
            {
                name = "Guthix's gift (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju dungeoneering potion"] = {
        name = "Perfect juju dungeoneering potion (3)",
        level = 91,
        xp = 127.5,
        dose = 3,
        mats = {
            {
                name = "Zamorak's favour (3)",
                qty = 1,
            },
            {
                name = "Harmony moss",
                qty = 1,
            },
        },
    },
    ["Perfect juju fishing potion"] = {
        name = "Perfect juju fishing potion (3)",
        level = 92,
        xp = 127.5,
        dose = 3,
        mats = {
            {
                name = "Juju fishing potion (3)",
                qty = 1,
            },
            {
                name = "Harmony dust",
                qty = 1,
                price = "no",
            },
        },
    },
}

p.barbarian = {
    ["Agility mix"] = {
        name = "Agility mix (2)",
        level = 37,
        xp = 27,
        mats = {
            {
                name = "Agility potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Antifire mix"] = {
        name = "Antifire mix (2)",
        level = 75,
        xp = 53,
        mats = {
            {
                name = "Antifire (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Antipoison mix"] = {
        name = "Antipoison mix (2)",
        level = 15,
        xp = 1.2,
        recipes = {
            {
                mats = {
                    {
                        name = "Antipoison (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Antipoison (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Antipoison+ mix"] = {
        name = "Antipoison+ mix (2)",
        level = 74,
        xp = 52,
        mats = {
            {
                name = "Antipoison+ (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Attack mix"] = {
        name = "Attack mix (2)",
        level = 4,
        xp = 8,
        recipes = {
            {
                mats = {
                    {
                        name = "Attack potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Attack potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Combat mix"] = {
        name = "Combat mix (2)",
        level = 40,
        xp = 28,
        mats = {
            {
                name = "Combat potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Defence mix"] = {
        name = "Defence mix (2)",
        level = 11,
        xp = 25,
        mats = {
            {
                name = "Defence potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Energy mix"] = {
        name = "Energy mix (2)",
        level = 29,
        xp = 23,
        mats = {
            {
                name = "Energy potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Fishing mix"] = {
        name = "Fishing mix (2)",
        level = 53,
        xp = 38,
        mats = {
            {
                name = "Fishing potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Hunting mix"] = {
        name = "Hunting mix (2)",
        level = 58,
        xp = 40,
        mats = {
            {
                name = "Hunter potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Magic mix"] = {
        name = "Magic mix (2)",
        level = 7,
        xp = 8,
        recipes = {
            {
                mats = {
                    {
                        name = "Magic potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Magic potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Magic essence mix"] = {
        name = "Magic essence mix (2)",
        level = 61,
        xp = 43,
        mats = {
            {
                name = "Magic essence (2)",
                qty = 1,
                price = "no",
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Ranging mix"] = {
        name = "Ranging mix (2)",
        level = 5,
        xp = 8,
        recipes = {
            {
                mats = {
                    {
                        name = "Ranging potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Ranging potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Relicym's mix"] = {
        name = "Relicym's mix (2)",
        level = 9,
        xp = 14,
        recipes = {
            {
                mats = {
                    {
                        name = "Relicym's balm (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Relicym's balm (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Restore mix"] = {
        name = "Restore mix (2)",
        level = 24,
        xp = 21,
        recipes = {
            {
                mats = {
                    {
                        name = "Restore potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Restore potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Strength mix"] = {
        name = "Strength mix (2)",
        level = 9,
        xp = 17,
        recipes = {
            {
                mats = {
                    {
                        name = "Strength potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Roe",
                        qty = 1,
                    },
                },
            },
            {
                mats = {
                    {
                        name = "Strength potion (2)",
                        qty = 1,
                    },
                    {
                        name = "Caviar",
                        qty = 1,
                    },
                },
            },
        }
    },
    ["Prayer mix"] = {
        name = "Prayer mix (2)",
        level = 42,
        xp = 29,
        mats = {
            {
                name = "Prayer potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super antipoison mix"] = {
        name = "Super antipoison mix (2)",
        level = 51,
        xp = 35,
        mats = {
            {
                name = "Prayer potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super attack mix"] = {
        name = "Super attack mix (2)",
        level = 47,
        xp = 33,
        mats = {
            {
                name = "Super attack (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super defence mix"] = {
        name = "Super defence mix (2)",
        level = 71,
        xp = 50,
        mats = {
            {
                name = "Super defence (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super energy mix"] = {
        name = "Super energy mix (2)",
        level = 56,
        xp = 39,
        mats = {
            {
                name = "Super energy (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super magic mix"] = {
        name = "Super magic mix (2)",
        level = 83,
        xp = 57,
        mats = {
            {
                name = "Super magic potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super ranging mix"] = {
        name = "Super ranging mix (2)",
        level = 80,
        xp = 54,
        mats = {
            {
                name = "Super ranging potion (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super restore mix"] = {
        name = "Super restore mix (2)",
        level = 67,
        xp = 48,
        mats = {
            {
                name = "Super restore (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Super strength mix"] = {
        name = "Super strength mix (2)",
        level = 59,
        xp = 42,
        mats = {
            {
                name = "Super strength (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
    ["Zamorak mix"] = {
        name = "Zamorak mix (2)",
        level = 85,
        xp = 58,
        mats = {
            {
                name = "Zamorak brew (2)",
                qty = 1,
            },
            {
                name = "Caviar",
                qty = 1,
            },
        },
    },
}

p.daemonheim_herb = {
    ["Clean sagewort"] = {
        name = "Clean sagewort",
        level = 3,
        xp = 2.1,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy sagewort",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean valerian"] = {
        name = "Clean valerian",
        level = 4,
        xp = 3.2,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy valerian",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean aloe"] = {
        name = "Clean aloe",
        level = 8,
        xp = 4,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy aloe",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean wormwood leaf"] = {
        name = "Clean wormwood leaf",
        level = 34,
        xp = 7.2,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy wormwood leaf",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean magebane"] = {
        name = "Clean magebane",
        level = 37,
        xp = 7.7,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy magebane",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean featherfoil"] = {
        name = "Clean featherfoil",
        level = 41,
        xp = 8.6,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy featherfoil",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean winter's grip"] = {
        name = "Clean winter's grip",
        level = 67,
        xp = 12.7,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy winter's grip",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean lycopus"] = {
        name = "Clean lycopus",
        level = 71,
        xp = 13.1,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy lycopus",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean buckthorn"] = {
        name = "Clean buckthorn",
        level = 74,
        xp = 13.8,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Grimy buckthorn",
                qty = 1,
                price = "no",
            }
        },
    },
}

p.daemonheim_unfinished = {
    ["Sagewort potion (unfinished)"] = {
        name = "Sagewort potion (unfinished)",
        level = 3,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean sagewort",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Valerian potion (unfinished)"] = {
        name = "Valerian potion (unfinished)",
        level = 4,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean valerian",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Aloe potion (unfinished)"] = {
        name = "Aloe potion (unfinished)",
        level = 8,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean aloe",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Wormwood potion (unfinished)"] = {
        name = "Wormwood potion (unfinished)",
        level = 34,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean wormwood",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Magebane potion (unfinished)"] = {
        name = "Magebane potion (unfinished)",
        level = 37,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean magebane",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Featherfoil potion (unfinished)"] = {
        name = "Featherfoil potion (unfinished)",
        level = 41,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean featherfoil",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Winter's grip potion (unfinished)"] = {
        name = "Winter's grip potion (unfinished)",
        level = 67,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean winter's grip",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Lycopus potion (unfinished)"] = {
        name = "Lycopus potion (unfinished)",
        level = 70,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean lycopus",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Buckthorn potion (unfinished)"] = {
        name = "Buckthorn potion (unfinished)",
        level = 74,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean buckthorn",
                qty = 1,
                price = "no",
            },
        },
    },
}

p.daemonheim = {
    ["Weak magic potion"] = {
        name = "Weak magic potion",
        level = 3,
        xp = 21,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean sagewort",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak ranged potion"] = {
        name = "Weak ranged potion",
        level = 5,
        xp = 34,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean valerian",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak melee potion"] = {
        name = "Weak melee potion",
        level = 7,
        xp = 37.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean valerian",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak defence potion"] = {
        name = "Weak defence potion",
        level = 9,
        xp = 41,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean aloe",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak stat restore potion"] = {
        name = "Weak stat restore potion",
        level = 12,
        xp = 47,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean aloe",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak cure potion"] = {
        name = "Weak cure potion",
        level = 15,
        xp = 53.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean aloe",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak rejuvenation potion"] = {
        name = "Weak rejuvenation potion",
        level = 18,
        xp = 57,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean aloe",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak weapon poison"] = {
        name = "Weak weapon poison",
        level = 21,
        xp = 61,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean sagewort",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak gatherer's potion"] = {
        name = "Weak gatherer's potion",
        level = 24,
        xp = 65,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean sagewort",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak artisan's potion"] = {
        name = "Weak artisan's potion",
        level = 27,
        xp = 68.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean valerian",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak naturalist's potion"] = {
        name = "Weak naturalist's potion",
        level = 30,
        xp = 72,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean sagewort",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weak survivalist's potion"] = {
        name = "Weak survivalist's potion",
        level = 33,
        xp = 75,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean valerian",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Magic potion (Dungeoneering)"] = {
        name = "Magic potion (Dungeoneering)",
        level = 36,
        xp = 79.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean wormwood leaf",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Ranged potion (Dungeoneering)"] = {
        name = "Ranged potion (Dungeoneering)",
        level = 38,
        xp = 83,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean magebane",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Melee potion"] = {
        name = "Melee potion",
        level = 40,
        xp = 86.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean magebane",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Defence potion (Dungeoneering)"] = {
        name = "Defence potion (Dungeoneering)",
        level = 42,
        xp = 89,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean featherfoil",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Stat restore potion (Dungeoneering)"] = {
        name = "Stat restore potion (Dungeoneering)",
        level = 45,
        xp = 93,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean featherfoil",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Cure potion"] = {
        name = "Cure potion",
        level = 48,
        xp = 98.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean featherfoil",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Rejuvenation potion"] = {
        name = "Rejuvenation potion",
        level = 51,
        xp = 101.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean featherfoil",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Weapon poison (Dungeoneering)"] = {
        name = "Weapon poison (Dungeoneering)",
        level = 54,
        xp = 114,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean wormwood leaf",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Gatherer's potion"] = {
        name = "Gatherer's potion",
        level = 57,
        xp = 123.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean wormwood leaf",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Artisan's potion"] = {
        name = "Artisan's potion",
        level = 60,
        xp = 131,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean magebane",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Naturalist's potion"] = {
        name = "Naturalist's potion",
        level = 63,
        xp = 139.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean wormwood leaf",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Survivalist's potion"] = {
        name = "Survivalist's potion",
        level = 66,
        xp = 147,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean magebane",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong magic potion"] = {
        name = "Strong magic potion",
        level = 69,
        xp = 155.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean winter's grip",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong ranged potion"] = {
        name = "Strong ranged potion",
        level = 71,
        xp = 160,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean lycopus",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong melee potion"] = {
        name = "Strong melee potion",
        level = 73,
        xp = 163,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean lycopus",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong defence potion"] = {
        name = "Strong defence potion",
        level = 75,
        xp = 164,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean buckthorn",
                qty = 1,
                price = "no",
            },
            {
                name = "Void dust",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong stat restore potion"] = {
        name = "Strong stat restore potion",
        level = 78,
        xp = 173.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean buckthorn",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong cure potion"] = {
        name = "Strong cure potion",
        level = 81,
        xp = 170.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean buckthorn",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong rejuvenation potion"] = {
        name = "Strong rejuvenation potion",
        level = 84,
        xp = 189.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean buckthorn",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong weapon poison"] = {
        name = "Strong weapon poison",
        level = 87,
        xp = 205.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean winter's grip",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong gatherer's potion"] = {
        name = "Strong gatherer's potion",
        level = 90,
        xp = 234,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean winter's grip",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong artisan's potion"] = {
        name = "Strong artisan's potion",
        level = 93,
        xp = 253,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean lycopus",
                qty = 1,
                price = "no",
            },
            {
                name = "Red moss",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong naturalist's potion"] = {
        name = "Strong naturalist's potion",
        level = 96,
        xp = 279,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean winter's grip",
                qty = 1,
                price = "no",
            },
            {
                name = "Misshapen claw",
                qty = 1,
                price = "dung",
            },
        },
    },
    ["Strong survivalist's potion"] = {
        name = "Strong survivalist's potion",
        level = 99,
        xp = 315.5,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial of water (Dungeoneering)",
                qty = 1,
                price = "10",
            },
            {
                name = "Clean lycopus",
                qty = 1,
                price = "no",
            },
            {
                name = "Firebreath whiskey",
                qty = 1,
                price = "dung",
            },
        },
    },
}

p.burner = {
    ["Clean guam"] = {
        name = "Deployable herb burner",
        level = 1,
        xp = 25,
        price = "no",
        mats = {
            {
                name = "Clean guam",
                qty = 1,
            }
        },
    },
    ["Clean tarromin"] = {
        name = "Deployable herb burner",
        level = 5,
        xp = 38,
        price = "no",
        mats = {
            {
                name = "Clean tarromin",
                qty = 1,
            }
        },
    },
    ["Clean marrentill"] = {
        name = "Deployable herb burner",
        level = 9,
        xp = 50,
        price = "no",
        mats = {
            {
                name = "Clean marrentill",
                qty = 1,
            }
        },
    },
    ["Clean harralander"] = {
        name = "Deployable herb burner",
        level = 20,
        xp = 63,
        price = "no",
        mats = {
            {
                name = "Clean harralander",
                qty = 1,
            }
        },
    },
    ["Clean ranarr"] = {
        name = "Deployable herb burner",
        level = 25,
        xp = 75,
        price = "no",
        mats = {
            {
                name = "Clean ranarr",
                qty = 1,
            }
        },
    },
    ["Clean toadflax"] = {
        name = "Deployable herb burner",
        level = 30,
        xp = 80,
        price = "no",
        mats = {
            {
                name = "Clean toadflax",
                qty = 1,
            }
        },
    },
    ["Clean spirit weed"] = {
        name = "Deployable herb burner",
        level = 35,
        xp = 78,
        price = "no",
        mats = {
            {
                name = "Clean spirit weed",
                qty = 1,
            }
        },
    },
    ["Clean irit"] = {
        name = "Deployable herb burner",
        level = 40,
        xp = 88,
        price = "no",
        mats = {
            {
                name = "Clean irit",
                qty = 1,
            }
        },
    },
    ["Clean wergali"] = {
        name = "Deployable herb burner",
        level = 41,
        xp = 95,
        price = "no",
        mats = {
            {
                name = "Clean wergali",
                qty = 1,
            }
        },
    },
    ["Clean avantoe"] = {
        name = "Deployable herb burner",
        level = 48,
        xp = 100,
        price = "no",
        mats = {
            {
                name = "Clean avantoe",
                qty = 1,
            }
        },
    },
    ["Clean kwuarm"] = {
        name = "Deployable herb burner",
        level = 54,
        xp = 113,
        price = "no",
        mats = {
            {
                name = "Clean kwuarm",
                qty = 1,
            }
        },
    },
    -- Clean bloodweed is not burnable
    ["Clean bloodweed"] = {
        name = "Deployable herb burner",
        level = 57,
        xp = nil,
        price = "no",
        mats = {
            {
                name = "Clean bloodweed",
                qty = 1,
            }
        },
    },
    ["Clean snapdragon"] = {
        name = "Deployable herb burner",
        level = 59,
        xp = 118,
        price = "no",
        mats = {
            {
                name = "Clean snapdragon",
                qty = 1,
            }
        },
    },
    ["Clean cadantine"] = {
        name = "Deployable herb burner",
        level = 65,
        xp = 125,
        price = "no",
        mats = {
            {
                name = "Clean cadantine",
                qty = 1,
            }
        },
    },
    ["Clean lantadyme"] = {
        name = "Deployable herb burner",
        level = 67,
        xp = 131,
        price = "no",
        mats = {
            {
                name = "Clean lantadyme",
                qty = 1,
            }
        },
    },
    ["Clean dwarf weed"] = {
        name = "Deployable herb burner",
        level = 70,
        xp = 138,
        price = "no",
        mats = {
            {
                name = "Clean dwarf weed",
                qty = 1,
            }
        },
    },
    ["Clean torstol"] = {
        name = "Deployable herb burner",
        level = 75,
        xp = 150,
        price = "no",
        mats = {
            {
                name = "Clean torstol",
                qty = 1,
            }
        },
    },
    -- Clean arbuck is not burnable
    ["Clean arbuck"] = {
        name = "Deployable herb burner",
        level = 77,
        xp = nil,
        price = "no",
        mats = {
            {
                name = "Clean arbuck",
                qty = 1,
            }
        },
    },
    ["Clean fellstalk"] = {
        name = "Deployable herb burner",
        level = 91,
        xp = 168,
        price = "no",
        mats = {
            {
                name = "Clean fellstalk",
                qty = 1,
            }
        },
    },
    ["Clean erzille"] = {
        name = "Deployable herb burner",
        level = 54,
        xp = 110,
        price = "no",
        mats = {
            {
                name = "Clean erzille",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean argway"] = {
        name = "Deployable herb burner",
        level = 55,
        xp = 128,
        price = "no",
        mats = {
            {
                name = "Clean argway",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean ugune"] = {
        name = "Deployable herb burner",
        level = 56,
        xp = 127,
        price = "no",
        mats = {
            {
                name = "Clean ugune",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean shengo"] = {
        name = "Deployable herb burner",
        level = 57,
        xp = 129,
        price = "no",
        mats = {
            {
                name = "Clean shengo",
                qty = 1,
                price = "no",
            }
        },
    },
    ["Clean samaden"] = {
        name = "Deployable herb burner",
        level = 58,
        xp = 129,
        price = "no",
        mats = {
            {
                name = "Clean samaden",
                qty = 1,
                price = "no",
            }
        },
    },
}

p.tar = {
    ["Guam tar"] = {
        name = "Guam tar",
        level = 19,
        xp = 30,
        multiplier = 15,
        mats = {
            {
                name = "Clean guam",
                qty = 1,
            },
            {
                name = "Swamp tar",
                qty = 15,
            },
        }
    },
    ["Marrentill tar"] = {
        name = "Marrentill tar",
        level = 31,
        xp = 42.5,
        multiplier = 15,
        mats = {
            {
                name = "Clean marrentill",
                qty = 1,
            },
            {
                name = "Swamp tar",
                qty = 15,
            },
        }
    },
    ["Tarromin tar"] = {
        name = "Tarromin tar",
        level = 39,
        xp = 55,
        multiplier = 15,
        mats = {
            {
                name = "Clean tarromin",
                qty = 1,
            },
            {
                name = "Swamp tar",
                qty = 15,
            },
        }
    },
    ["Harralander tar"] = {
        name = "Harralander tar",
        level = 44,
        xp = 72.5,
        multiplier = 15,
        mats = {
            {
                name = "Clean harralander",
                qty = 1,
            },
            {
                name = "Swamp tar",
                qty = 15,
            },
        }
    },
}

p.grinding = {
    ["Unicorn horn dust"] = {
        name = "Unicorn horn dust",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Unicorn horn",
                qty = 1,
            },
        },
    },
    ["Chocolate dust"] = {
        name = "Chocolate dust",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Chocolate bar",
                qty = 1,
            },
        },
    },
    ["Kebbit teeth dust"] = {
        name = "Kebbit teeth dust",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Kebbit teeth",
                qty = 1,
            },
        },
    },
    ["Gorak claw powder"] = {
        name = "Gorak claw powder",
        level = 1,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Gorak claws",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Crushed nest"] = {
        name = "Crushed nest",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Bird's nest (empty)",
                qty = 1,
                price = "no",
            },
        },
    },
    ["Goat horn dust"] = {
        name = "Goat horn dust",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Desert goat horn",
                qty = 1,
            },
        },
    },
    ["Dragon scale dust"] = {
        name = "Dragon scale dust",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Blue dragon scale",
                qty = 1,
            },
        },
    },
    ["Ground mud runes"] = {
        name = "Ground mud runes",
        level = 1,
        xp = 1,
        mats = {
            {
                name = "Mud rune",
                qty = 1,
            },
        },
    },
    ["Ground wyvern bones"] = {
        name = "Ground wyvern bones",
        level = 1,
        xp = 1,
        price = "no",
        mats = {
            {
                name = "Wyvern bones",
                qty = 1,
            },
        },
    },
}

p.telekinetic_grind = {
    ["Unicorn horn dust"] = {
        name = "Unicorn horn dust",
        level = 1,
        xp = 1,
        multiplier = 26,
        mats = {
            {
                name = "Unicorn horn",
                qty = 26,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Chocolate dust"] = {
        name = "Chocolate dust",
        level = 1,
        xp = 1,
        multiplier = 26,
        mats = {
            {
                name = "Chocolate bar",
                qty = 26,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Kebbit teeth dust"] = {
        name = "Kebbit teeth dust",
        level = 1,
        xp = 1,
        multiplier = 26,
        mats = {
            {
                name = "Kebbit teeth",
                qty = 26,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Gorak claw powder"] = {
        name = "Gorak claw powder",
        level = 1,
        xp = 1,
        multiplier = 26,
        price = "no",
        mats = {
            {
                name = "Gorak claws",
                qty = 26,
                price = "no",
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Crushed nest"] = {
        name = "Crushed nest",
        level = 1,
        xp = 1,
        multiplier = 26,
        mats = {
            {
                name = "Bird's nest (empty)",
                qty = 26,
                price = "no",
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Goat horn dust"] = {
        name = "Goat horn dust",
        level = 1,
        xp = 1,
        multiplier = 26,
        mats = {
            {
                name = "Desert goat horn",
                qty = 26,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Dragon scale dust"] = {
        name = "Dragon scale dust",
        level = 1,
        xp = 1,
        multiplier = 26,
        mats = {
            {
                name = "Blue dragon scale",
                qty = 26,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Ground mud runes"] = {
        name = "Ground mud runes",
        level = 1,
        xp = 1,
        multiplier = 60,
        mats = {
            {
                name = "Mud rune",
                qty = 60,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
    ["Ground wyvern bones"] = {
        name = "Ground wyvern bones",
        level = 1,
        xp = 1,
        multiplier = 26,
        price = "no",
        mats = {
            {
                name = "Wyvern bones",
                qty = 26,
            },
            {
                name = "Law rune",
                qty = 1,
            },
            {
                name = "Astral rune",
                qty = 2,
            },
        },
    },
}

p.manual_filling = {
    ["Vial of water"] = {
        name = "Vial of water",
        level = 1,
        xp = 0,
        mats = {
            {
                name = "Vial",
                qty = 1,
            },
        },
    },
    ["Juju vial of water"] = {
        name = "Juju vial of water",
        level = 1,
        xp = 0,
        mats = {
            {
                name = "Juju vial",
                qty = 1,
            },
        },
    },
    ["Vial of water (Dungeoneering)"] = {
        name = "Vial of water (Dungeoneering)",
        level = 1,
        xp = 0,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial (Dungeoneering)",
                qty = 1,
                price = "dung",
            },
        },
    },
}

p.humidify = {
    ["Vial of water"] = {
        name = "Vial of water",
        level = 1,
        xp = 0,
        multiplier = 27,
        mats = {
            {
                name = "Vial",
                qty = 27,
            },
            {
                name = "Astral rune",
                qty = 1,
            },
        },
    },
    ["Juju vial of water"] = {
        name = "Juju vial of water",
        level = 1,
        xp = 0,
        multiplier = 27,
        mats = {
            {
                name = "Juju vial",
                qty = 27,
            },
            {
                name = "Astral rune",
                qty = 1,
            },
        },
    },
    ["Vial of water (Dungeoneering)"] = {
        name = "Vial of water (Dungeoneering)",
        level = 1,
        xp = 0,
        multiplier = 27,
        price = "no",
        rusty = true,
        mats = {
            {
                name = "Vial (Dungeoneering)",
                qty = 27,
            },
            {
                name = "Astral rune (Dungeoneering)",
                qty = 1,
                price = "dung",
            },
        },
    },
}

p.coconut = {
    ["Opened coconut"] = {
        name = "Coconut milk",
        level = 1,
        xp = 1,
        multiplier = 14,
        tick = 1,
        mats = {
            {
                name = "Vial",
                qty = 14,
            },
            {
                name = "Coconut (open)",
                qty = 14,
            },
        },
    },
    ["Whole coconut"] = {
        name = "Coconut milk",
        level = 1,
        xp = 1,
        multiplier = 14,
        tick = 1,
        mats = {
            {
                name = "Vial",
                qty = 14,
            },
            {
                name = "Coconut",
                qty = 14,
            },
        },
    },
}

p.overload_variants = {
    ["Overload"] = p.standard["Overload"],
    ["Aggroverload"] = p.combinations["Aggroverload"],
    ["Holy aggroverload"] = p.combinations["Holy aggroverload"],
    ["Holy overload potion"] = p.combinations["Holy overload potion"],
    ["Overload salve"] = p.combinations["Overload salve"],
    ["Perfect plus potion"] = p.combinations["Perfect plus potion"],
    ["Searing overload potion"] = p.combinations["Searing overload potion"],
    ["Supreme overload potion"] = p.combinations["Supreme overload potion"],
    ["Supreme overload salve"] = p.combinations["Supreme overload salve"],
    ["Elder overload potion"] = p.combinations["Elder overload potion"],
    ["Elder overload salve"] = p.combinations["Elder overload salve"],
}

p.containers = {
    standard = "Vial",
    juju = "Juju vial",
    combinations = "Crystal flask",
    bomb = "Bomb vial",
    powerburst = "Powerburst vial",
    daemonheim = "Vial (Dungeoneering)",
}

p.potion_decanting = {
    affects = { "standard", "juju" }
}

p.potion_to_flask = {
    affects = "specific",
    affected_category = { "standard", "juju" },
    container = { name = "Potion flask", alias = "Potion flask", price = "gemw" },
    conversion = {
        ["Adrenaline potion"] = { name = "Adrenaline flask (6)", price = "no" },
        ["Adrenaline renewal potion"] = { name = "Adrenaline renewal flask (6)", price = "no" },
        ["Aggression potion"] = { name = "Aggression flask (6)", price = "gemw" },
        ["Agility potion"] = { name = "Agility flask (6)", price = "gemw" },
        ["Antifire"] = { name = "Antifire flask (6)", price = "gemw" },
        ["Antipoison"] = { name = "Antipoison flask (6)", price = "gemw" },
        ["Antipoison+"] = { name = "Antipoison+ flask (6)", price = "gemw" },
        ["Antipoison++"] = { name = "Antipoison++ flask (6)", price = "gemw" },
        ["Archaeology potion"] = { name = "Archaeology flask (6)", price = "gemw" },
        ["Attack potion"] = { name = "Attack flask (6)", price = "gemw" },
        ["Camouflage potion"] = { name = "Camouflage flask (6)", price = "no" },
        ["Charming potion"] = { name = "Charming potion flask (6)", price = "gemw" },
        ["Combat potion"] = { name = "Combat flask (6)", price = "gemw" },
        ["Cooking potion"] = { name = "Cooking flask (6)", price = "gemw" },
        ["Crafting potion"] = { name = "Crafting flask (6)", price = "gemw" },
        ["Defence potion"] = { name = "Defence flask (6)", price = "gemw" },
        ["Divination potion"] = { name = "Divination flask (6)", price = "gemw" },
        ["Energy potion"] = { name = "Energy flask (6)", price = "gemw" },
        ["Extended super antifire"] = { name = "Extended super antifire flask (6)", price = "no" },
        ["Extreme attack"] = { name = "Extreme attack flask (6)", price = "no" },
        ["Extreme cooking potion"] = { name = "Extreme cooking flask (6)", price = "no" },
        ["Extreme defence"] = { name = "Extreme defence flask (6)", price = "no" },
        ["Extreme divination"] = { name = "Extreme divination flask (6)", price = "no" },
        ["Extreme hunter"] = { name = "Extreme hunter flask (6)", price = "no" },
        ["Extreme invention"] = { name = "Extreme invention flask (6)", price = "no" },
        ["Extreme magic"] = { name = "Extreme magic flask (6)", price = "no" },
        ["Extreme prayer potion"] = { name = "Extreme prayer flask (6)", price = "no" },
        ["Extreme ranging"] = { name = "Extreme ranging flask (6)", price = "no" },
        ["Extreme runecrafting"] = { name = "Extreme runecrafting flask (6)", price = "no" },
        ["Extreme strength"] = { name = "Extreme strength flask (6)", price = "no" },
        ["Fishing potion"] = { name = "Fishing flask (6)", price = "gemw" },
        ["Fletching potion"] = { name = "Fletching flask (6)", price = "gemw" },
        ["Guthix balance"] = { name = "Guthix balance flask (6)", price = "gemw" },
        ["Guthix rest"] = { name = "Guthix rest flask (6)", price = "gemw" },
        ["Guthix's gift"] = { name = "Guthix's gift flask (6)", price = "gemw" },
        ["Harvest potion"] = { name = "Harvest flask (6)", price = "gemw" },
        ["Hunter potion"] = { name = "Hunter flask (6)", price = "gemw" },
        ["Invention potion"] = { name = "Invention flask (6)", price = "gemw" },
        ["Juju cooking potion"] = { name = "Juju cooking flask (6)", price = "gemw" },
        ["Juju farming potion"] = { name = "Juju farming flask (6)", price = "gemw" },
        ["Juju fishing potion"] = { name = "Juju fishing flask (6)", price = "gemw" },
        ["Juju hunter potion"] = { name = "Juju hunter flask (6)", price = "gemw" },
        ["Juju mining potion"] = { name = "Juju mining flask (6)", price = "gemw" },
        ["Juju woodcutting potion"] = { name = "Juju woodcutting flask (6)", price = "gemw" },
        ["Magic essence"] = { name = "Magic essence flask (6)", price = "no" },
        ["Magic potion"] = { name = "Magic flask (6)", price = "gemw" },
        ["Mining potion"] = { name = "Mining flask (6)", price = "gemw" },
        ["Overload"] = { name = "Overload flask (6)", price = "no" },
        ["Perfect juju agility potion"] = { name = "Perfect juju agility flask (6)", price = "gemw" },
        ["Perfect juju dungeoneering potion"] = { name = "Perfect juju dungeoneering flask (6)", price = "gemw" },
        ["Perfect juju farming potion"] = { name = "Perfect juju farming flask (6)", price = "gemw" },
        ["Perfect juju fishing potion"] = { name = "Perfect juju fishing flask (6)", price = "gemw" },
        ["Perfect juju herblore potion"] = { name = "Perfect juju herblore flask (6)", price = "gemw" },
        ["Perfect juju mining potion"] = { name = "Perfect juju mining flask (6)", price = "gemw" },
        ["Perfect juju prayer potion"] = { name = "Perfect juju prayer flask (6)", price = "gemw" },
        ["Perfect juju smithing potion"] = { name = "Perfect juju smithing flask (6)", price = "gemw" },
        ["Perfect juju woodcutting potion"] = { name = "Perfect juju woodcutting flask (6)", price = "gemw" },
        ["Prayer potion"] = { name = "Prayer flask (6)", price = "gemw" },
        ["Prayer renewal"] = { name = "Prayer renewal flask (6)", price = "gemw" },
        ["Ranging potion"] = { name = "Ranging flask (6)", price = "gemw" },
        ["Relicym's balm"] = { name = "Relicym's balm flask (6)", price = "gemw" },
        ["Restore potion"] = { name = "Restore flask (6)", price = "gemw" },
        ["Runecrafting potion"] = { name = "Runecrafting flask (6)", price = "gemw" },
        ["Sanfew serum"] = { name = "Sanfew serum flask (6)", price = "gemw" },
        ["Saradomin brew"] = { name = "Saradomin brew flask (6)", price = "gemw" },
        ["Saradomin's blessing"] = { name = "Saradomin's blessing flask (6)", price = "gemw" },
        ["Scentless potion"] = { name = "Scentless flask (6)", price = "gemw" },
        ["Serum 207"] = { name = "Serum 207 flask (6)", price = "no" },
        ["Spirit attraction potion"] = { name = "Spirit attraction flask (6)", price = "gemw" },
        ["Stamina potion"] = { name = "Stamina flask (6)", price = "no" },
        ["Strength potion"] = { name = "Strength flask (6)", price = "gemw" },
        ["Summoning potion"] = { name = "Summoning flask (6)", price = "gemw" },
        ["Summoning renewal"] = { name = "Summoning renewal flask (6)", price = "gemw" },
        ["Super adrenaline potion"] = { name = "Super adrenaline flask (6)", price = "no" },
        ["Super antifire"] = { name = "Super antifire flask (6)", price = "gemw" },
        ["Super antipoison"] = { name = "Super antipoison flask (6)", price = "gemw" },
        ["Super attack"] = { name = "Super attack flask (6)", price = "gemw" },
        ["Super cooking potion"] = { name = "Super cooking flask (6)", price = "gemw" },
        ["Super defence"] = { name = "Super defence flask (6)", price = "gemw" },
        ["Super divination"] = { name = "Super divination flask (6)", price = "gemw" },
        ["Super energy"] = { name = "Super energy flask (6)", price = "gemw" },
        ["Super fishing potion"] = { name = "Super fishing flask (6)", price = "gemw" },
        ["Super Guthix rest"] = { name = "Super Guthix brew flask (6)", price = "gemw" },
        ["Super hunter"] = { name = "Super hunter flask (6)", price = "gemw" },
        ["Super invention"] = { name = "Super invention flask (6)", price = "gemw" },
        ["Super magic potion"] = { name = "Super magic flask (6)", price = "gemw" },
        ["Super mining potion"] = { name = "Super mining flask (6)", price = "gemw" },
        ["Super prayer"] = { name = "Super prayer flask (6)", price = "gemw" },
        ["Super ranging potion"] = { name = "Super ranging flask (6)", price = "gemw" },
        ["Super restore"] = { name = "Super restore flask (6)", price = "gemw" },
        ["Super runecrafting"] = { name = "Super runecrafting flask (6)", price = "gemw" },
        ["Super Saradomin brew"] = { name = "Super Saradomin brew flask (6)", price = "gemw" },
        ["Super strength"] = { name = "Super strength flask (6)", price = "gemw" },
        ["Super woodcutting potion"] = { name = "Super woodcutting flask (6)", price = "gemw" },
        ["Super Zamorak brew"] = { name = "Super Zamorak brew flask (6)", price = "gemw" },
        ["Weapon poison"] = { name = "Weapon poison flask (6)", price = "gemw" },
        ["Weapon poison+"] = { name = "Weapon poison+ flask (6)", price = "gemw" },
        ["Weapon poison++"] = { name = "Weapon poison++ flask (6)", price = "gemw" },
        ["Weapon poison+++"] = { name = "Weapon poison+++ flask (6)", price = "gemw" },
        ["Woodcutting potion"] = { name = "Woodcutting flask (6)", price = "gemw" },
        ["Zamorak brew"] = { name = "Zamorak brew flask (6)", price = "gemw" },
        ["Zamorak's favour"] = { name = "Zamorak's favour flask (6)", price = "gemw" },
    },
}

-- Module Setup
local function strip_dose_name(name)
    return string.gsub(name, ' %(%d+%)$', '')
end

local flask_conversion = p.potion_to_flask.conversion
local function is_potion_flaskable(alias)
    return flask_conversion[alias] ~= nil
end

local potion_decanting_affects = p.potion_decanting.affects
local function is_potion_decantable(dose, recipe_category)
    if dose == nil or dose <= 1 then
        return false
    end

    for _, affects in ipairs(potion_decanting_affects) do
        if affects == recipe_category then
            return true
        end
    end
    return false
end

local function is_grimy(name)
    return string.match(name, '^Grimy.*$') ~= nil
end

local function get_dose_number(name)
    local dose = string.match(name, '%((%d+)%)$')
    if dose ~= nil then
        return tonumber(dose)
    else
        return nil
    end
end

local function set_potion_metadata(item, category)
    if is_potion_flaskable(item.alias) then
        item.flaskable = true
    end

    local dose = get_dose_number(item.name)
    if dose ~= nil then
        item.dose = dose
    end

    if is_potion_decantable(dose, category) then
        item.decantable = true
    end
end

local function assign_mats_metadata(item_category_table, mats, recipe_category)
    if mats == nil then
        return
    end

    for _, mat in ipairs(mats) do
        local name = mat.name
        local alias = strip_dose_name(name)
        mat.alias = alias

        set_potion_metadata(mat, recipe_category)

        if recipe_category == "herb" and is_grimy(alias) then
            item_category_table[alias] = "grimy_herb"
        elseif recipe_category == "juju_herb" and is_grimy(alias) then
            item_category_table[alias] = "juju_grimy_herb"
        elseif recipe_category == "daemonheim_herb" and is_grimy(alias) then
            item_category_table[alias] = "daemonheim_grimy_herb"
        end
    end
end

local function setup_mats_metadata(item_category_table, item, category)
    local recipes = item.recipes
    if recipes ~= nil then
        for _, recipe in ipairs(recipes) do
            assign_mats_metadata(item_category_table, recipe.mats, category)
        end
    end
    assign_mats_metadata(item_category_table, item.mats, category)
end

local function setup_recipes_metadata(item_category_table, categories)
    -- Setting the metadata of materials
    for _, category in pairs(categories) do
        for _, item in pairs(p[category]) do
            local name = item.name
            local alias = strip_dose_name(name)
            item.alias = alias

            set_potion_metadata(item, category)

            item_category_table[alias] = category

            setup_mats_metadata(item_category_table, item, category)
        end
    end
end

local function setup_fixed_item_category(item_category_table)
    -- Setting the metadata of containers
    for _, container in pairs(p.containers) do
        item_category_table[container] = "container"
    end
    item_category_table[p.potion_to_flask.container.alias] = "container"

    -- Setting the metadata of solvent
    item_category_table["Vial of water"] = "solvent"
    item_category_table["Juju vial of water"] = "solvent"
    item_category_table["Vial of water (Dungeoneering)"] = "solvent"
    item_category_table["Coconut milk"] = "solvent"

    -- Setting the metadata of ground ingredients
    for _, ingredient in pairs(p.grinding) do
        item_category_table[ingredient.alias] = "ingredient"
    end

    -- Setting the metadata of rune
    item_category_table["Astral rune"] = "rune"
    item_category_table["Astral rune (Dungeoneering)"] = "rune"
    item_category_table["Law rune"] = "rune"
    item_category_table["Mud rune"] = "rune"

    -- Setting the metadata of consumable
    item_category_table[p.incense_torstol.consumable.alias] = "consumable"
    item_category_table[p.perfect_juju_herblore.consumable["Perfect juju herblore potion"].alias] = "consumable"
    item_category_table[p.perfect_juju_herblore.consumable["Perfect plus potion"].alias] = "consumable"
    item_category_table[p.bik_scripture.consumable.alias] = "consumable"
    item_category_table[p.botanist_amulet.consumable.alias] = "consumable"

    -- Setting the metadata of burner
    item_category_table["Deployable herb burner"] = "burner"
end

local function setup_fixed_item_metadata(item_category_table)
    -- Setting production ticks of recipes
    for category, tick in pairs(p.production_ticks) do
        for _, receipe in pairs(p[category]) do
            if receipe.tick == nil then
                receipe.tick = tick
            end
        end
    end

    -- Setting the alias of flask conversion
    for _, item in pairs(p.potion_to_flask.conversion) do
        item.alias = strip_dose_name(item.name)
    end

    -- Setting the alias of recipes of material replacement
    local raw_material_categories = { p.grinding, p.telekinetic_grind, p.manual_filling, p.humidify, p.coconut }
    for _, recipes in ipairs(raw_material_categories) do
        for _, item in pairs(recipes) do
            item.alias = item.name

            setup_mats_metadata(item_category_table, item)
        end
    end

    -- Setting the alias of burner
    for _, item in pairs(p.burner) do
        item.alias = item.name
        item.has_product = false
        item.method = "Using " .. string.gsub(item.mats[1].name, 'Clean ', '')

        setup_mats_metadata(item_category_table, item)
    end

    setup_fixed_item_category(item_category_table)
end

local function setup_container_weighting(sorting_table, weighting)
    local containers = p.containers
    sorting_table[containers.bomb] = weighting + 1
    sorting_table[containers.powerburst] = weighting + 2
    sorting_table[containers.combinations] = weighting + 3
    sorting_table["container"] = weighting + 4
end

local function setup_sorting_weighting(sorting_table, sorting_order, max_weighting_items)
    local max_sorting_weighting = 0

    for i, item in ipairs(sorting_order) do
        local weighting = i * 10
        if item == "container" then
            setup_container_weighting(sorting_table, weighting)
        else
            sorting_table[item] = weighting
        end

        max_sorting_weighting = weighting + 10
    end

    for i, item in ipairs(max_weighting_items) do
        if item == "container" then
            setup_container_weighting(sorting_table, max_sorting_weighting + i * 10)
        else
            sorting_table[item] = max_sorting_weighting + i * 10
        end
    end

    return max_sorting_weighting
end

-- Module Init
p.item_category_table = {}
setup_fixed_item_metadata(p.item_category_table)
setup_recipes_metadata(p.item_category_table, {
    "standard", "juju", "bomb", "powerburst", "adrenaline",
    "herb", "juju_herb",
    "unfinished", "juju_unfinished",
    "combinations", "barbarian", "primal", "primal_pulp", "tar",
    "daemonheim", "daemonheim_herb",
})

p.material_sorting_table = {}
p.material_max_sorting_weighting = setup_sorting_weighting(p.material_sorting_table, {
    "container", "solvent", "primal", "primal_pulp",
    "juju_unfinished", "unfinished", "juju_herb", "juju_grimy_herb", "herb", "grimy_herb",
    "combinations", "juju", "standard",
}, {
    "rune",
    p.containers.juju, p.containers.standard, p.potion_to_flask.container.alias,
    "consumable"
})

p.product_sorting_table = {}
p.product_max_sorting_weighting = setup_sorting_weighting(p.product_sorting_table, {}, { "container" })

p.step_sorting_table = {}
p.step_max_sorting_weighting = setup_sorting_weighting(p.step_sorting_table, {
    "solvent", "primal_pulp", "primal",
    "grimy_herb", "herb", "juju_grimy_herb", "juju_herb", "unfinished", "juju_unfinished",
    "standard", "juju", "combinations",
}, {})

return p
-- </nowiki>