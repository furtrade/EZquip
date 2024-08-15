local _, addon = ...

local data = {
    [1467] = {  -- devastation
        [202116] = {  -- Alacritous Alchemist Stone
            active = false,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 402374,
                [483] = 402549,
                [489] = 403936,
                [496] = 405075,
                [502] = 406174,
                [509] = 407153,
                [515] = 407951,
                [522] = 409571,
            },
        },
        [207167] = {  -- Ashes of the Embersoul
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 405882,
                [483] = 406603,
                [489] = 407506,
                [496] = 409589,
                [502] = 410883,
                [509] = 412931,
                [515] = 414474,
                [522] = 416801,
                [528] = 418507,
            },
        },
        [208614] = {  -- Augury of the Primal Flame
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 399906,
                [486] = 400901,
                [496] = 402693,
                [502] = 403496,
                [509] = 404542,
                [515] = 405891,
                [522] = 406897,
                [528] = 408100,
                [535] = 409940,
            },
        },
        [198407] = {  -- Azure Arcanic Amplifier
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 402483,
                [483] = 403052,
                [486] = 403187,
                [489] = 404153,
                [493] = 404613,
                [496] = 405338,
                [499] = 406190,
                [502] = 406812,
            },
        },
        [203963] = {  -- Beacon to the Beyond
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [489] = 395403,
                [493] = 396283,
                [499] = 397147,
                [506] = 398131,
                [512] = 399341,
                [519] = 400432,
                [528] = 402518,
            },
        },
        [207172] = {  -- Belor'relos, the Suncaller
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 400444,
                [483] = 401135,
                [493] = 404583,
                [499] = 406585,
                [506] = 408887,
                [512] = 411032,
                [519] = 414763,
                [528] = 418828,
            },
        },
        [194307] = {  -- Broodkeeper's Promise
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [486] = 394592,
                [489] = 394622,
                [496] = 395835,
                [502] = 396438,
                [509] = 397904,
                [515] = 398822,
                [522] = 400430,
                [528] = 401589,
            },
        },
        [204387] = {  -- Buzzing Orb Core
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 392449,
                [483] = 393406,
                [486] = 394362,
                [489] = 394680,
                [493] = 395312,
                [496] = 395559,
                [499] = 395902,
                [502] = 396409,
            },
        },
        [194300] = {  -- Conjured Chillglobe
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 400444,
                [483] = 401120,
                [489] = 402554,
                [496] = 404312,
                [502] = 406294,
                [509] = 407935,
                [515] = 410054,
                [522] = 412646,
                [528] = 414782,
            },
        },
        [198478] = {  -- Darkmoon Deck Box: Dance [Sagescale]
            active = true,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 398612,
                [483] = 399716,
                [489] = 401055,
                [496] = 402467,
                [502] = 403988,
                [509] = 406404,
                [515] = 407447,
                [522] = 410386,
            },
        },
        [194872] = {  -- Darkmoon Deck Box: Inferno [Sagescale]
            active = true,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 396950,
                [483] = 397529,
                [489] = 398126,
                [496] = 400027,
                [502] = 401000,
                [509] = 402466,
                [515] = 404078,
                [522] = 405581,
            },
        },
        [198477] = {  -- Darkmoon Deck Box: Rime [Sagescale]
            active = true,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 395177,
                [483] = 395619,
                [489] = 396556,
                [496] = 397605,
                [502] = 399022,
                [509] = 400213,
                [515] = 401865,
                [522] = 403695,
            },
        },
        [198481] = {  -- Darkmoon Deck Box: Watcher
            active = true,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 397465,
                [483] = 396962,
                [489] = 398483,
                [496] = 399409,
                [502] = 400598,
                [509] = 401615,
                [515] = 402730,
                [522] = 404338,
            },
        },
        [194310] = {  -- Desperate Invoker's Codex
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [486] = 402410,
                [489] = 402991,
                [496] = 404922,
                [502] = 406907,
                [509] = 408616,
                [515] = 411401,
                [522] = 413516,
                [528] = 416365,
            },
        },
        [204388] = {  -- Draconic Cauterizing Magma
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393089,
                [483] = 393793,
                [486] = 394008,
                [489] = 394493,
                [493] = 395387,
                [496] = 395446,
                [499] = 396340,
                [502] = 396612,
            },
        },
        [216279] = {  -- Draconic Gladiator's Badge of Ferocity
            active = true,
            source = 'High PvP',
            dps_by_ilvl = {
                [515] = 407510,
            },
        },
        [216281] = {  -- Draconic Gladiator's Emblem
            active = true,
            source = 'High PvP',
            dps_by_ilvl = {
                [515] = 398329,
            },
        },
        [216280] = {  -- Draconic Gladiator's Insignia of Alacrity
            active = false,
            source = 'High PvP',
            dps_by_ilvl = {
                [515] = 411147,
            },
        },
        [216282] = {  -- Draconic Gladiator's Medallion
            active = true,
            source = 'High PvP',
            dps_by_ilvl = {
                [515] = 398824,
            },
        },
        [216283] = {  -- Draconic Gladiator's Sigil of Adaptation
            active = false,
            source = 'High PvP',
            dps_by_ilvl = {
                [515] = 399465,
            },
        },
        [205195] = {  -- Drakeforged Magma Charm
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 389506,
                [483] = 389552,
                [486] = 389659,
                [489] = 389816,
                [493] = 389805,
                [496] = 390296,
                [499] = 390121,
                [502] = 390413,
            },
        },
        [198489] = {  -- Dreamscape Prism
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393400,
                [483] = 394333,
                [486] = 394426,
                [489] = 394829,
                [493] = 394945,
                [496] = 395796,
                [499] = 396209,
                [502] = 397248,
            },
        },
        [204810] = {  -- Drogbar Rocks
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 389446,
                [483] = 389745,
                [486] = 389434,
                [489] = 390034,
                [493] = 389885,
                [496] = 390035,
                [499] = 390185,
                [502] = 390472,
            },
        },
        [193718] = {  -- Emerald Coach's Whistle
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 396819,
                [483] = 397393,
                [489] = 398579,
                [496] = 399599,
                [502] = 400942,
                [509] = 402110,
                [515] = 403439,
                [522] = 404733,
                [528] = 405772,
            },
        },
        [193769] = {  -- Erupting Spear Fragment
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 399653,
                [483] = 400019,
                [489] = 401427,
                [496] = 403365,
                [502] = 405069,
                [509] = 406741,
                [515] = 408502,
                [522] = 410438,
                [528] = 412597,
            },
        },
        [204901] = {  -- Firecaller's Focus
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 398741,
                [483] = 399113,
                [486] = 399242,
                [489] = 399689,
                [493] = 400658,
                [496] = 400831,
                [499] = 401270,
                [502] = 401680,
            },
        },
        [204728] = {  -- Friendship Censer
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393576,
                [483] = 393913,
                [486] = 394129,
                [489] = 394252,
                [493] = 395378,
                [496] = 395921,
                [499] = 396176,
                [502] = 396614,
            },
        },
        [193677] = {  -- Furious Ragefeather
            active = false,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 398890,
                [483] = 399543,
                [489] = 401235,
                [496] = 402462,
                [502] = 404801,
                [509] = 406024,
                [515] = 407822,
                [522] = 410567,
                [528] = 412486,
            },
        },
        [207174] = {  -- Fyrakk's Tainted Rageheart
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 396694,
                [486] = 397447,
                [496] = 398819,
                [502] = 399944,
                [509] = 400883,
                [515] = 401841,
                [522] = 403345,
                [528] = 403909,
                [535] = 405358,
            },
        },
        [204736] = {  -- Heatbound Medallion
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 397433,
                [483] = 397954,
                [486] = 398433,
                [489] = 398923,
                [493] = 398911,
                [496] = 399803,
                [499] = 400239,
                [502] = 400949,
            },
        },
        [194304] = {  -- Iceblood Deathsnare
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 397154,
                [483] = 398045,
                [489] = 399295,
                [496] = 400694,
                [502] = 401973,
                [509] = 403871,
                [515] = 405653,
                [522] = 407333,
                [528] = 409137,
            },
        },
        [193660] = {  -- Idol of Pure Decay
            active = false,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 399100,
                [483] = 400111,
                [489] = 401621,
                [496] = 402845,
                [502] = 404163,
                [509] = 406879,
                [515] = 408464,
                [522] = 410545,
                [528] = 412929,
            },
        },
        [193005] = {  -- Idol of the Dreamer
            active = false,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 393096,
                [483] = 394029,
                [489] = 394500,
                [496] = 395747,
                [502] = 396606,
                [509] = 397759,
                [515] = 399064,
                [522] = 400101,
            },
        },
        [193006] = {  -- Idol of the Earth-Warder
            active = false,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 393147,
                [483] = 393360,
                [489] = 395219,
                [496] = 395762,
                [502] = 396224,
                [509] = 398126,
                [515] = 398942,
                [522] = 400608,
            },
        },
        [193003] = {  -- Idol of the Life-Binder
            active = false,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 393337,
                [483] = 394036,
                [489] = 394828,
                [496] = 395589,
                [502] = 396657,
                [509] = 397788,
                [515] = 398914,
                [522] = 400372,
            },
        },
        [193004] = {  -- Idol of the Spell-Weaver
            active = false,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 402078,
                [483] = 402927,
                [489] = 403570,
                [496] = 404763,
                [502] = 406429,
                [509] = 407803,
                [515] = 409124,
                [522] = 410718,
            },
        },
        [203996] = {  -- Igneous Flowstone [Low Tide]
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [486] = 403825,
                [489] = 404161,
                [496] = 406250,
                [502] = 407336,
                [509] = 409210,
                [515] = 411182,
                [522] = 413221,
                [528] = 415137,
            },
        },
        [193743] = {  -- Irideus Fragment
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 404015,
                [483] = 404678,
                [489] = 405607,
                [496] = 407559,
                [502] = 408246,
                [509] = 410030,
                [515] = 411219,
                [522] = 412664,
                [528] = 414367,
            },
        },
        [205229] = {  -- Magma Serpent Lure
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393258,
                [483] = 393283,
                [486] = 394137,
                [489] = 394786,
                [493] = 395166,
                [496] = 395622,
                [499] = 396170,
                [502] = 396444,
            },
        },
        [205262] = {  -- Magmaclaw Lure
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393040,
                [483] = 393906,
                [486] = 393938,
                [489] = 394625,
                [493] = 394928,
                [496] = 395629,
                [499] = 396106,
                [502] = 396577,
            },
        },
        [193678] = {  -- Miniature Singing Stone
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 393529,
                [483] = 393467,
                [489] = 394991,
                [496] = 395899,
                [502] = 396421,
                [509] = 398126,
                [515] = 398728,
                [522] = 400555,
                [528] = 401548,
            },
        },
        [207581] = {  -- Mirror of Fractured Tomorrows
            active = true,
            source = 'Mega Dungeon',
            dps_by_ilvl = {
                [493] = 408217,
                [496] = 409034,
                [502] = 410728,
                [509] = 412391,
                [515] = 414189,
                [522] = 415927,
                [528] = 417721,
            },
        },
        [204201] = {  -- Neltharion's Call to Chaos
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [496] = 408155,
                [502] = 409824,
                [509] = 411252,
                [515] = 412166,
                [522] = 414297,
                [528] = 415906,
                [535] = 417970,
            },
        },
        [208615] = {  -- Nymue's Unraveling Spindle
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 405508,
                [483] = 406699,
                [489] = 407965,
                [496] = 410365,
                [502] = 412651,
                [509] = 415174,
                [515] = 417967,
                [522] = 420605,
                [528] = 423042,
            },
        },
        [203729] = {  -- Ominous Chromatic Essence [Ruby]
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [483] = 403505,
                [489] = 404577,
                [496] = 405720,
                [502] = 407184,
                [509] = 408930,
                [515] = 410121,
                [522] = 411688,
                [528] = 413574,
            },
        },
        [206972] = {  -- Paracausal Fragment of Azzinoth
            active = false,
            source = 'Calling',
            dps_by_ilvl = {
                [480] = 401744,
                [483] = 402435,
                [486] = 402947,
                [489] = 404197,
            },
        },
        [206983] = {  -- Paracausal Fragment of Frostmourne
            active = true,
            source = 'Calling',
            dps_by_ilvl = {
                [480] = 399723,
                [483] = 400557,
                [486] = 401411,
                [489] = 402329,
            },
        },
        [207005] = {  -- Paracausal Fragment of Thunderfin, Humid Blade of the Tideseeker
            active = false,
            source = 'Calling',
            dps_by_ilvl = {
                [480] = 399612,
                [483] = 400204,
                [486] = 401008,
                [489] = 401652,
            },
        },
        [207168] = {  -- Pip's Emerald Friendship Badge
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 404987,
                [483] = 404934,
                [489] = 406415,
                [496] = 407980,
                [502] = 409373,
                [509] = 410926,
                [515] = 411873,
                [522] = 413734,
                [528] = 415206,
            },
        },
        [204386] = {  -- Pocket Darkened Elemental Core
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393384,
                [483] = 393908,
                [486] = 394069,
                [489] = 394755,
                [493] = 395546,
                [496] = 395358,
                [499] = 396188,
                [502] = 396534,
            },
        },
        [193757] = {  -- Ruby Whelp Shell [St]
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 399955,
                [483] = 400918,
                [489] = 402080,
                [496] = 403619,
                [502] = 405336,
                [509] = 407193,
                [515] = 409131,
                [522] = 410973,
                [528] = 413536,
            },
        },
        [204714] = {  -- Satchel of Healing Spores
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393591,
                [483] = 393886,
                [486] = 394350,
                [489] = 394700,
                [493] = 394984,
                [496] = 395719,
                [499] = 396352,
                [502] = 396642,
            },
        },
        [202612] = {  -- Screaming Black Dragonscale
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [486] = 404244,
                [489] = 404529,
                [496] = 405363,
                [502] = 407130,
                [509] = 408671,
                [515] = 409833,
                [522] = 411767,
                [528] = 413323,
            },
        },
        [205201] = {  -- Smoldering Howler Horn
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 405029,
                [483] = 404888,
                [486] = 406204,
                [489] = 406619,
                [493] = 407161,
                [496] = 407795,
                [499] = 408083,
                [502] = 409060,
            },
        },
        [194309] = {  -- Spiteful Storm
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [486] = 400132,
                [489] = 401387,
                [496] = 402724,
                [502] = 404222,
                [509] = 406000,
                [515] = 408515,
                [522] = 410710,
                [528] = 412958,
            },
        },
        [193773] = {  -- Spoils of Neltharus
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 408994,
                [483] = 410061,
                [489] = 411250,
                [496] = 412599,
                [502] = 413525,
                [509] = 415670,
                [515] = 416979,
                [522] = 418676,
                [528] = 420152,
            },
        },
        [205200] = {  -- Stirring Twilight Ember
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 403311,
                [483] = 403955,
                [486] = 404795,
                [489] = 405163,
                [493] = 405700,
                [496] = 406098,
                [499] = 406898,
                [502] = 407394,
            },
        },
        [205193] = {  -- Sturdy Deepflayer Scute
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 404728,
                [483] = 404796,
                [486] = 405473,
                [489] = 406000,
                [493] = 407169,
                [496] = 407215,
                [499] = 408339,
                [502] = 408890,
            },
        },
        [191491] = {  -- Sustaining Alchemist Stone
            active = false,
            source = 'Profession',
            dps_by_ilvl = {
                [480] = 402519,
                [483] = 402712,
                [489] = 403992,
                [496] = 404755,
                [502] = 406533,
                [509] = 407222,
                [515] = 408366,
                [522] = 410235,
            },
        },
        [193791] = {  -- Time-Breaching Talon
            active = true,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 398728,
                [483] = 399034,
                [489] = 399360,
                [496] = 399879,
                [502] = 400530,
                [509] = 400962,
                [515] = 400833,
                [522] = 401801,
                [528] = 402266,
            },
        },
        [207579] = {  -- Time-Thief's Gambit
            active = true,
            source = 'Mega Dungeon',
            dps_by_ilvl = {
                [493] = 398202,
                [496] = 398633,
                [502] = 400314,
                [509] = 401592,
                [515] = 402806,
                [522] = 404371,
                [528] = 405942,
            },
        },
        [212685] = {  -- Tome of Unstable Power
            active = false,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 399633,
                [483] = 400502,
                [489] = 401627,
                [496] = 403266,
                [502] = 405025,
                [509] = 407528,
                [515] = 409285,
                [522] = 411569,
                [528] = 413166,
            },
        },
        [212684] = {  -- Umbrelskul's Fractured Heart
            active = false,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 400811,
                [483] = 402244,
                [489] = 403344,
                [496] = 405562,
                [502] = 407226,
                [509] = 409554,
                [515] = 411769,
                [522] = 414087,
                [528] = 416640,
            },
        },
        [205191] = {  -- Underlight Globe
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 404041,
                [483] = 404406,
                [486] = 404868,
                [489] = 405067,
                [493] = 406096,
                [496] = 406258,
                [499] = 407277,
                [502] = 407880,
            },
        },
        [202615] = {  -- Vessel of Searing Shadow
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [480] = 402356,
                [483] = 403066,
                [489] = 404482,
                [496] = 405768,
                [502] = 407261,
                [509] = 409659,
                [515] = 411234,
                [522] = 412432,
                [528] = 414998,
            },
        },
        [205192] = {  -- Volatile Crystal Shard
            active = false,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393199,
                [483] = 393771,
                [486] = 394199,
                [489] = 394676,
                [493] = 395228,
                [496] = 395553,
                [499] = 396102,
                [502] = 396727,
            },
        },
        [203714] = {  -- Ward of Faceless Ire
            active = true,
            source = 'Raid',
            dps_by_ilvl = {
                [489] = 396113,
                [493] = 396830,
                [499] = 397638,
                [506] = 398653,
                [512] = 400340,
                [519] = 401464,
                [528] = 404060,
            },
        },
        [212682] = {  -- Water's Beating Heart
            active = false,
            source = 'Dungeon',
            dps_by_ilvl = {
                [480] = 393340,
                [483] = 393681,
                [489] = 394904,
                [496] = 395713,
                [502] = 396873,
                [509] = 397548,
                [515] = 399057,
                [522] = 400700,
                [528] = 401617,
            },
        },
        [194301] = {  -- Whispering Incarnate Icon [Dps]
            active = false,
            source = 'Raid',
            dps_by_ilvl = {
                [483] = 405427,
                [489] = 406424,
                [496] = 407788,
                [502] = 409062,
                [509] = 410752,
                [515] = 412176,
                [522] = 413737,
                [528] = 415603,
            },
        },
        [205196] = {  -- Zaqali Hand Cauldron
            active = true,
            source = 'World Quest',
            dps_by_ilvl = {
                [480] = 393308,
                [483] = 393511,
                [486] = 394002,
                [489] = 394615,
                [493] = 395215,
                [496] = 395734,
                [499] = 396139,
                [502] = 396742,
            },
        },
        ['baseline'] = {  -- baseline
            active = false,
            source = 'Unknown',
            dps_by_ilvl = {
                [480] = 378280,
                [483] = 378280,
                [486] = 378280,
                [489] = 378280,
                [493] = 378280,
                [496] = 378280,
                [499] = 378280,
                [502] = 378280,
                [506] = 378280,
                [509] = 378280,
                [512] = 378280,
                [515] = 378280,
                [519] = 378280,
                [522] = 378280,
                [528] = 378280,
                [535] = 378280,
            },
        },
    },
}

-- Load data for evoker
function addon:LoadTrinketsForClass_13(specId)
    if not self.BisTrinkets then
        self.BisTrinkets = {}
    end

    self.BisTrinkets = data[specId]
end
