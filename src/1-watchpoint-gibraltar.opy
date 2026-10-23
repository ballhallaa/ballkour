#!include "VERSION"

settings {
    "main": {
        "description": f"Watchpoint: Gibraltar \n\nv{VERSION} \n\nLatest Code: 59W28",
        "modeName": "Ball Parkour ● ballkour.com"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "paused",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12,
        "team1Slots": 12,
        "team2Slots": 0,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                {
                    "watchpointGibraltar": [
                        "972777519512068292"
                    ]
                }
            ]
        },
        "general": {
            "heroLimit": "off"
        }
    },
    "heroes": {
        "allTeams": {
            "wreckingBall": {
                "ability2Cooldown%": 0,
                "secondaryFireCooldown%": 0,
                "ability3Cooldown%": 0
            },
            "jetpackCat": {
                "enablePassiveUnlimitedFuel": true,
                "enableAbility1": false,
                "enableAbility2": false
            },
            "enabledHeroes": [
                "wreckingBall"
            ],
            "general": {
                "enableInfiniteAmmo": true,
                "passiveUltGen%": 0
            }
        }
    }
}

#!include "declarations.opy"

#!optimizeStrict


rule "0: Contact & Course Info":
    logToInspector("Hello! Welcome to Ballkour's Watchpoint: Gibraltar course!")
    logToInspector("Original course (W1RWY) by Spiz. Redeveloped by ballmybeloved. Math help from Kalaziel64. workshop.codes logo by Madje.")
    logToInspector("This route was slightly adjusted for quality purposes and also because this map was updated in Feb, 2026. Checkpoints are slightly bigger too.")
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Found a bug or have a suggestion? Please let us know in our Discord or open an issue at ballkour.com/github!")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord or open an issue at ballkour.com/github!")
    logToInspector("Course playthrough: ballkour.com/gibraltar")


rule "1: Settings":
    settings_ = []
    settings_[0] = createWorkshopSettingBool("Settings", "Debug", false, 1)
    settings_[1] = createWorkshopSettingBool("Settings", "Lobby Stats", false, 0)


rule "2: Leaderboard (LB)":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    lb[1] = "BALLMYBLOVED, 3:54.23, 5, '           '"
    lb[2] = "COLDSKIN, 4:05.81, 2, '                     '"
    lb[3] = "JAKOBONEDGE, 4:21.96, 12, '         '"
    lb[4] = "BACKLINEREIN, 4:34.15, 15, '           '"
    lb[5] = "DVD, 5:02.50, 15, '                             '"
    lb[6] = "GAMINGCHAIR, 5:08.37, 16, '         '"
    lb[7] = "BLOWSKI, 5:40.50, 24, '                    '"
    lb[8] = "安宁, 5:50.20, 40, '                           '"
    lb[9] = "KINGO, 6:26.18, 37, '                       '"
    lb[10] = "VANESSA, 6:59.56, 58, '                 '"


rule "3: Checkpoints (CPs)":
    # cpDefaults[i]: [0]cpSize [1]bounceSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 2.5
    cpDefaults[2] = 2.5
    # cps[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize
    cps = []
    cps[0] = [vect(30.354, 5, -151.022), cpDefaults[0], false, false, true, null, null, vect(36.24, 5.00, -145.78), cpDefaults[2]]
    cps[1] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(42.536, 3.218, -140.939), (cps[len(cps) - 2])[8]]
    cps[2] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(36.938, 4.01, -124.67), cpDefaults[2]]
    cps[3] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(19.895, 6, -130.757), cpDefaults[2]]
    cps[4] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(46.563, 4.01, -129.999), cpDefaults[2]]
    cps[5] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(32.38, 6.56, -108.87), cpDefaults[2]]
    cps[6] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(27.37, 4, -88.81), cpDefaults[2]]
    cps[7] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(16.181, 3.046, -67.936), cpDefaults[2]]
    cps[8] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(27.89, 3.05, -70.12), cpDefaults[2]]
    cps[9] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(28.072, 3.998, -105.3), cpDefaults[2]]
    cps[10] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(60.854, 1, -113.372), cpDefaults[2]]
    cps[11] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(44.855, 4.01, -131.473), cpDefaults[2]]
    cps[12] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(39.7, 1, -144.094), cpDefaults[2]]
    cps[13] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(44.91, 1, -138.61), cpDefaults[2]]
    cps[14] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(44.35, 4.01, -130.82), cpDefaults[2]]
    cps[15] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(33.83, 4, -90), cpDefaults[2]]
    cps[16] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(30.991, 3, -72.417), cpDefaults[2]]
    cps[17] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(39.055, -4.947, -75.702), cpDefaults[2]]
    cps[18] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(45.022, -5, -69.766), cpDefaults[2]]
    cps[19] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(47.22, 6, -67.5), cpDefaults[2]]
    cps[20] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(45.4, 5.31, -51.18), cpDefaults[2]]
    cps[21] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(36.368, -2.134, -56.973), cpDefaults[2]]
    cps[22] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(45.662, 3, -36.151), cpDefaults[2]]
    cps[23] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(67.50, 9.01, -42.18), cpDefaults[2]]
    cps[24] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(41.77, 3, -73.61), cpDefaults[2]]
    cps[25] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(36.668, -2.134, -57.072), cpDefaults[2]]
    cps[26] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(53.683, 8.908, -36.387), cpDefaults[2]]
    cps[27] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(81.77, 3, -33.09), cpDefaults[2]]
    cps[28] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(86.119, 3.01, -29.821), cpDefaults[2]]
    cps[29] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(77.563, 6, 6.752), cpDefaults[2]]
    cps[30] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(101.21, -0.94, 40.44), cpDefaults[2]]
    cps[31] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(91.745, 6, 9.719), cpDefaults[2]]
    cps[32] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(83.1, 1, 56.16), cpDefaults[2]]
    cps[33] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(81.151, 2.845, 28.89), cpDefaults[2]]
    cps[34] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(71.21, 1, 18.59), cpDefaults[2]]
    cps[35] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(77.622, 6.01, 6.08), cpDefaults[2]]
    cps[36] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(75.526, 10, 7.506), cpDefaults[2]]
    cps[37] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(69.811, 9.01, 12.958), cpDefaults[2]]
    cps[38] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(66.62, 8.32, 26.39), cpDefaults[2]]
    cps[39] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(98.874, 2.745, -16.184), cpDefaults[2]]
    cps[40] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(68.47, -3.14, -13.22), cpDefaults[2]]
    cps[41] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(64.54, -3, -17.9), cpDefaults[2]]
    cps[42] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(65.06, 9.53, -31.73), cpDefaults[2]]
    cps[43] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(53.419, 8.734, -38.662), cpDefaults[2]]
    cps[44] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(36.26, -0.26, -47.19), cpDefaults[2]]
    cps[45] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(45.993, 3, -36.446), cpDefaults[2]]
    cps[46] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(57.496, 3, -54.121), cpDefaults[2]]
    cps[47] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(47.01, 6.00, -67.42), cpDefaults[2]]
    cps[48] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(32.38, -5.15, -57.33), cpDefaults[2]]
    cps[49] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(34.29, 1.19, -53.24), cpDefaults[2]]
    cps[50] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(40.6, -5.01, -51.2), cpDefaults[2]]
    cps[51] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(43.11, -0.51, -49.171), cpDefaults[2]]
    cps[52] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(65.46, -3.14, -26.55), cpDefaults[2]]
    cps[53] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(62.097, 2.028, -22.853), cpDefaults[2]]
    cps[54] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(73.6, -3.14, -38.12), cpDefaults[2]]
    cps[55] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(74.748, 2.107, -34.64), cpDefaults[2]]
    cps[56] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(50.72, 8.72, -47.45), cpDefaults[2]]
    cps[57] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(45.49, 3, -36.66), cpDefaults[2]]
    cps[58] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(47.22, 6, -67.5), cpDefaults[2]]
    cps[59] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(39.46, -5.02, -75.88), cpDefaults[2]]
    cps[60] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(14.081, 3.045, -70.069), cpDefaults[2]]
    cps[61] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(27.17, 0, -104.23), cpDefaults[2]]
    cps[62] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(29.24, 4, -106.27), cpDefaults[2]]
    cps[63] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(42.742, -6.137, -119.077), cpDefaults[2]]
    cps[64] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(36.423, 0, -112.203), cpDefaults[2]]
    cps[65] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(33.015, 6.561, -109.607), cpDefaults[2]]
    cps[66] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(38.88, 0, -99.49), cpDefaults[2]]
    cps[67] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(32.37, 4.00, -93.09), cpDefaults[2]]
    cps[68] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(39.957, 3.998, -102.764), cpDefaults[2]]
    cps[69] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(33.417, 4.01, -86.09), cpDefaults[2]]
    cps[70] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(43.86, 4.33, -130.51), cpDefaults[2]]
    cps[71] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(35.776, 5, -144.535), cpDefaults[2]]
    cps[72] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(16.589, -2, -133.052), cpDefaults[2]]
    cps[73] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(21.742, -1.91, -129.95), cpDefaults[1], vect(37.649, 4.01, -124.211), cpDefaults[2]]
    cps[74] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(61.452, -7.192, -141.705), cpDefaults[2]]
    cps[75] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(64.37, -6.31, -131.28), cpDefaults[1], vect(60.992, 1, -115.213), cpDefaults[2]]
    cps[76] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(36.918, 0.092, -95.332), cpDefaults[1], vect(27.284, 3.013, -84.642), cpDefaults[2]]
    cps[77] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(16.503, -5, -70.262), cpDefaults[2]]
    cps[78] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(23.858, -5.068, -82.402), cpDefaults[1], vect(29.458, 6.938, -90.962), cpDefaults[2]]
    cps[79] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(38.373, -5.02, -77.208), cpDefaults[2]]
    cps[80] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(44.188, -5.058, -60.366), cpDefaults[1], vect(56.069, 3, -52.942), cpDefaults[2]]
    cps[81] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(47.966, -5, -68.898), cpDefaults[2]]
    cps[82] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(41.762, -5.059, -62.347), cpDefaults[1], vect(36.26, -0.26, -47.19), cpDefaults[2]]
    cps[83] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(62.694, -3.003, -16.511), cpDefaults[2]]
    cps[84] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(74.99, -2.09, -9.26), cpDefaults[1], vect(83.645, 6, 1.309), cpDefaults[2]]
    cps[85] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(97.81, 1, 12.53), cpDefaults[2]]
    cps[86] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(82.13, 10.36, 14.07), cpDefaults[2]]
    cps[87] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(75.569, 9, 22.556), cpDefaults[2]]
    cps[88] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(59.696, 8.354, 20.334), cpDefaults[2]]
    cps[89] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(51.531, 9, 9.279), cpDefaults[2]]
    cps[90] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(41.032, 3, 7.798), cpDefaults[2]]
    cps[91] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(46.18, 9, 10.57), cpDefaults[2]]
    cps[92] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(45.06, 3, 3.14), cpDefaults[2]]
    cps[93] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(48.646, 9, 7.999), cpDefaults[2]]
    cps[94] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(81.852, 1, 23.622), cpDefaults[2]]
    cps[95] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(79.799, 9, 21.207), cpDefaults[2]]
    cps[96] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(86.008, -3.141, -1.915), cpDefaults[2]]
    cps[97] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(83.375, 6, 0.473), cpDefaults[2]]
    cps[98] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(90.713, -3.045, -5.413), cpDefaults[2]]
    cps[99] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(85.5, -3.15, -1.5), cpDefaults[1], vect(83.375, 6, 0.473), cpDefaults[2]]
    cps[100] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8]]


rule "4: Lobby":
    # lobbyData[i]: [0]spawnpoint [1]facing [2]welcomeSignTop [3]welcomeSignBottom [4]welcomeSignSize [5]newRunRing [6]newRunIcon [7]newRunSign [8]resumeRunRing [9]resumeRunIcon [10]resumeRunSign [11]lbSign [12]lbSignTextSize [13]lbPosTextSize [14]statsSign [15]elapsedTime [16]newPlayers [17]rejoins [18]legitRuns [19]totalRunTime [20]totalMistakes [21]avgRunTime [22]avgMistakes
    lobbyData = []
    lobbyData[0] = vect(112.24, -2, 65.57)
    lobbyData[5] = vect(103.805, -1.99, 75.48)
    lobbyData[6] = lobbyData[5] + vect(0, -1, 0)
    lobbyData[7] = lobbyData[5] + vect(0, 1.5, 0)
    lobbyData[1] = lobbyData[5] + vect(0, 2.75, 0)
    lobbyData[2] = lobbyData[5] + vect(0, 4, 0)
    lobbyData[3] = lobbyData[2] + vect(0, -0.6, 0)
    lobbyData[4] = 1.5
    lobbyData[8] = vect(101.36, -1.99, 73.035)
    lobbyData[9] = lobbyData[8] + vect(0, -1, 0)
    lobbyData[10] = lobbyData[8] + vect(0, 1.5, 0)
    lobbyData[11] = vect(99.18, 4.2, 68.07)
    lobbyData[12] = 1.2
    lobbyData[13] = 0.85
    lbPos = []
    lbPos[1] = lobbyData[11] + vect(0, -0.65, 0)
    lbPos[2] = lbPos[1] + vect(0, -0.5, 0) * 1
    lbPos[3] = lbPos[1] + vect(0, -0.5, 0) * 2
    lbPos[4] = lbPos[1] + vect(0, -0.5, 0) * 3
    lbPos[5] = lbPos[1] + vect(0, -0.5, 0) * 4
    lbPos[6] = lbPos[1] + vect(0, -0.5, 0) * 5
    lbPos[7] = lbPos[1] + vect(0, -0.5, 0) * 6
    lbPos[8] = lbPos[1] + vect(0, -0.5, 0) * 7
    lbPos[9] = lbPos[1] + vect(0, -0.5, 0) * 8
    lbPos[10] = lbPos[1] + vect(0, -0.5, 0) * 9
    lobbyData[14] = vect(101.52, lobbyData[11].y, 62.81)
    lobbyData[15] = 1.2
    lobbyData[16] = 0.85
    lobbyData[17] = lobbyData[14] + vect(0, -0.65, 0)
    lobbyData[18] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 1)
    lobbyData[19] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 2)
    lobbyData[20] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 3)
    lobbyData[21] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 4)
    lobbyData[22] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 5)
    lobbyData[23] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 6)
    lobbyData[24] = lobbyData[17] + (((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 7)


rule "5: Lobby Boundary":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[0]) > 18
    
    if eventPlayer.isFiringSecondaryFire():
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0.5)
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), lobbyData[0]), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)


#!include "ballkour.opy"