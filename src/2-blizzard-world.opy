#!include "VERSION"

settings {
    "main": {
        "description": f"Blizzard World (Winter) \n\nv{VERSION} \n\nLatest Code: GMWRF",
        "modeName": "Ball Parkour ● ballkour.com"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "paused",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12,
        "team1Slots": 0,
        "team2Slots": 12,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "blizzWorldWinter"
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
    logToInspector("Hello! Welcome to Ballkour's Blizzard World (Winter) course!")
    logToInspector("Original course (6B9Z09) created by Spiz. Recreated by ballhallaa.")
    logToInspector("Changes: this route's checkpoints are slightly bigger")
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")
    logToInspector("Course playthrough: ballkour.com/blizz-world")


rule "1: Settings":
    settings_ = []
    settings_[0] = createWorkshopSettingBool("Settings", "Debug", false, 1)
    settings_[1] = createWorkshopSettingBool("Settings", "Lobby Stats", false, 0)


rule "2: Leaderboard (LB)":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    lb[1] = "BALLMYBLOVED, 7:14.76, 16, '        '"


rule "3.1: Checkpoints (CPs)":
    # cpDefaults[i]: [0]cpSize [1]bounceSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 2.5
    cpDefaults[2] = 2.5
    # cps[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize
    cps = []
    cps[0] = [vect(3.011, -1.85, -6.987), cpDefaults[0], false, false, true, null, null, vect(3.112, -4.1, -15.46), cpDefaults[2]]
    cps[1] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-12.488, -4.1, -28.956), cpDefaults[2]]
    cps[2] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-15.061, -4.1, -6.952), cpDefaults[2]]
    cps[3] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-2.567, -0.1, 10.363), cpDefaults[2]]
    cps[4] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(22.806, -4.1, -6.891), cpDefaults[2]]
    cps[5] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(14.15, -5.1, 16.387), cpDefaults[2]]
    cps[6] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(-0.759, -5.1, 16.522), cpDefaults[2]]
    cps[7] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-8.024, -5.1, 16.514), cpDefaults[2]]
    cps[8] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-25.24, -2, 8.244), cpDefaults[2]]
    cps[9] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(2.963, -0.1, 21.386), cpDefaults[2]]
    cps[10] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-8.597, 6, 48.236), cpDefaults[2]]
    cps[11] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-10.812, -4.1, -1.167), cpDefaults[2]]
    cps[12] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-2.16, 2.5, 14.995), cpDefaults[2]]
    cps[13] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-12.01, 1.013, 34.086), cpDefaults[2]]
    cps[14] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-9.78, 1.894, 65.491), cpDefaults[2]]
    cps[15] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(18.006, 2, 78.984), cpDefaults[2]]
    cps[16] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(37.491, 2.001, 78.629), cpDefaults[2]]
    cps[17] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(28.438, 5.938, 69.758), cpDefaults[2]]
    cps[18] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-2.009, -0.971, 100.167), cpDefaults[2]]
    cps[19] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-19.706, 0.286, 115.325), cpDefaults[2]]
    cps[20] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-39.196, -0.135, 122.632), cpDefaults[2]]
    cps[21] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-17.044, 2.099, 81.878), cpDefaults[2]]
    cps[22] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(3.142, 8.105, 80.104), cpDefaults[2]]
    cps[23] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-40.516, -0.205, 111.274), cpDefaults[2]]
    cps[24] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-32.354, 5.805, 100.072), cpDefaults[2]]
    cps[25] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-9.743, -0.971, 110.646), cpDefaults[2]]
    cps[26] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(11.236, 6, 92.128), cpDefaults[2]]
    cps[27] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(22.295, 6, 57.364), cpDefaults[2]]
    cps[28] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(2.488, 3.6, 43.773), cpDefaults[2]]
    cps[29] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(11.297, 6, 83.438), cpDefaults[2]]
    cps[30] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-12.436, 1.927, 88.845), cpDefaults[2]]
    cps[31] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-29.986, 11.896, 88.363), cpDefaults[2]]
    cps[32] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-66.556, 6.329, 102.812), cpDefaults[2]]
    cps[33] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-56.331, 4.718, 92.693), cpDefaults[2]]
    cps[34] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-62.475, 6.241, 84.122), cpDefaults[2]]
    cps[35] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-63.286, 5.689, 99.603), cpDefaults[2]]
    cps[36] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-75.88, 0.795, 118.482), cpDefaults[2]]
    cps[37] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-121.605, -0.053, 110.725), cpDefaults[2]]
    cps[38] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-109.674, -4.25, 111.782), cpDefaults[2]]
    cps[39] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-103.549, -2.25, 100.17), cpDefaults[2]]
    cps[40] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-128.399, 1.75, 91.229), cpDefaults[2]]
    cps[41] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-110.239, -4.25, 113.923), cpDefaults[2]]
    cps[42] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-114.552, 4.75, 129.523), cpDefaults[2]]
    cps[43] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-105.666, 4.747, 141.857), cpDefaults[2]]
    cps[44] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-95.923, -1.253, 109.751), cpDefaults[2]]
    cps[45] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-109.511, -4.25, 121.231), cpDefaults[2]]
    cps[46] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-97.917, -1.253, 116.947), cpDefaults[2]]
    cps[47] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-138.975, 0.747, 130.492), cpDefaults[2]]
    cps[48] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-104.378, 4.75, 131.192), cpDefaults[2]]
    cps[49] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-60.888, 0.747, 124.561), cpDefaults[2]]
    cps[50] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-78.806, 6.575, 99.486), cpDefaults[2]]
    cps[51] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-42.825, -0.241, 116.719), cpDefaults[2]]
    cps[52] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-35.323, 5.805, 93.245), cpDefaults[2]]
    cps[53] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-21.563, 1.917, 80.519), cpDefaults[2]]
    cps[54] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-4.203, 6, 53.199), cpDefaults[2]]
    cps[55] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-2.225, 2, 67.376), cpDefaults[2]]
    cps[56] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(20.274, 2, 66.958), cpDefaults[2]]
    cps[57] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(18.322, 4.541, 68.009), cpDefaults[2]]
    cps[58] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(21.55, 6, 57.536), cpDefaults[2]]
    cps[59] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(6.128, -0.09, 38.622), cpDefaults[2]]
    cps[60] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(4.425, 3.6, 40.507), cpDefaults[2]]
    cps[61] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(2.62, 3.6, 43.804), cpDefaults[2]]
    cps[62] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-8.523, 6, 48.221), cpDefaults[2]]
    cps[63] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-41.591, -0.394, 75.849), cpDefaults[2]]
    cps[64] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-61.357, 6.359, 81.3), cpDefaults[2]]
    cps[65] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-41.03, 9.425, 102.345), cpDefaults[2]]
    cps[66] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-6.045, 1.881, 66.85), cpDefaults[2]]
    cps[67] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(7.874, -0.09, 43.955), cpDefaults[2]]
    cps[68] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(12.82, -5, 21.437), cpDefaults[2]]
    cps[69] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(9.84, 0, 21.521), cpDefaults[2]]
    cps[70] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(1.022, -4.1, -0.224), cpDefaults[2]]
    cps[71] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(0.301, 1.78, 4.124), cpDefaults[2]]
    cps[72] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(18.269, -0.847, -7), cpDefaults[2]]
    cps[73] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(18.598, -5.096, 7.558), cpDefaults[2]]
    cps[74] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(10.005, 0, 11.922), cpDefaults[2]]
    cps[75] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-4.956, 0, 26.835), cpDefaults[2]]
    cps[76] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(-4.917, 0.008, 44.877), cpDefaults[2]]
    cps[77] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-6.091, 6.097, 48.213), cpDefaults[2]]
    cps[78] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(23.501, 6, 61.909), cpDefaults[2]]
    cps[79] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(4.102, -0.971, 107.906), cpDefaults[2]]
    cps[80] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(16.166, -0.971, 96.608), cpDefaults[2]]
    cps[81] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(11.662, 6, 92.034), cpDefaults[2]]
    cps[82] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(11.113, 2, 81.002), cpDefaults[2]]
    cps[83] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(6.542, 6, 81.517), cpDefaults[2]]
    cps[84] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(3.238, 7.917, 79.977), cpDefaults[2]]
    cps[85] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-46.083, -0.205, 64.609), cpDefaults[2]]
    cps[86] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-56.83, 5.418, 82.844), cpDefaults[2]]
    cps[87] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-40.117, -0.205, 82.926), cpDefaults[2]]
    cps[88] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-42.545, 4.723, 89.936), cpDefaults[2]]
    cps[89] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-37.447, -0.359, 122.8), cpDefaults[2]]
    cps[90] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-41.957, -0.205, 133.756), cpDefaults[2]]
    cps[91] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-61.432, 0.747, 126.449), cpDefaults[2]]
    cps[92] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-57.78, -0.21, 128.12), cpDefaults[2]]
    cps[93] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-78.123, 0.597, 127.947), cpDefaults[2]]
    cps[94] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-108.472, 4.846, 138.498), cpDefaults[2]]
    cps[95] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-97.142, -1.252, 101.891), cpDefaults[2]]
    cps[96] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-97.889, 4.747, 143.351), cpDefaults[2]]
    cps[97] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-76.435, 0.747, 139.58), cpDefaults[2]]
    cps[98] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-81.98, 6.772, 104.388), cpDefaults[2]]
    cps[99] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-71.238, 0.793, 114.628), cpDefaults[2]]
    cps[100] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(-61.63, 0.79, 118.97), cpDefaults[1], vect(-42.78, 3.797, 129.447), cpDefaults[2]]
    cps[101] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-10.367, 1.9, 86.273), cpDefaults[2]]
    cps[102] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(-0.622, 6.034, 81.12), cpDefaults[2]]
    cps[103] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(8.636, 1.9, 74.911), cpDefaults[2]]
    cps[104] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(-5.36, 1.9, 74.68), cpDefaults[1], vect(-0.685, 6.504, 81.114), cpDefaults[2]]
    cps[105] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, null, null, vect(-1.234, 1.173, 60.973), cpDefaults[2]]
    cps[106] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(3.214, -0.097, 30.035), cpDefaults[2]]
    cps[107] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, true, true, null, null, vect(-7.198, -4, -16.403), cpDefaults[2]]
    cps[108] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], true, false, true, vect(0.56, -4, -9.23), cpDefaults[1], vect(2.854, 0, 7.195), cpDefaults[2]]
    cps[109] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8], false, false, true, null, null, vect(2.966, -1.85, -6.891), cpDefaults[2]]
    cps[110] = [(cps[len(cps) - 2])[7], (cps[len(cps) - 2])[8]]


rule "3.2: Disrupter Destructors":
    # ddbots[0]: team; ddbots[i > 0]: [0]spawnLocation [1]facingDirection
    ddBots = []
    ddBots[0] = Team.2
    # Checkpoint 39
    ddBots[1] = [vect(-109.674, -4.25, 111.782), vect(-98.37, -2.17, 114.92)]
    ddBots[2] = [vect(-109.674, -4.25, 111.782), vect(-94.55, -2.83, 103.54)]
    ddBots[3] = [vect(-108.22, -4.13, 107.72), vect(-104.33, -2.83, 101.1)]
    ddBots[4] = [vect(-103.549, -2.25, 100.17), vect(-108.92, -5.08, 120.59)]
    # Checkpoint 45
    ddBots[5] = [vect(-96.88, -1.25, 111.06), vect(-112.62, -3.65, 107.32)]
    ddBots[6] = [vect(-97.41, -1.25, 114.94), vect(-111.9, 0.21, 111.15)]
    ddBots[7] = [vect(-94.85, -1.25, 108.65), vect(-112.79, -0.62, 105.81)]
    # Checkpoint 46
    ddBots[8] = [vect(-109.511, -4.25, 121.231), vect(-97.74, -2.56, 114.55)]
    ddBots[9] = [vect(-97.917, -1.253, 116.947), vect(-112.85, 0.12, 112.92)]


rule "4: Lobby":
    # lobbyData[i]: [0]spawnpoint [1]facing [2]welcomeSignTop [3]welcomeSignBottom [4]welcomeSignSize [5]newRunRing [6]newRunIcon [7]newRunSign [8]resumeRunRing [9]resumeRunIcon [10]resumeRunSign [11]lbSign [12]lbSignTextSize [13]lbPosTextSize [14]statsSign [15]elapsedTime [16]newPlayers [17]rejoins [18]legitRuns [19]totalRunTime [20]totalMistakes [21]avgRunTime [22]avgMistakes
    lobbyData = []
    lobbyData[0] = vect(2.9, -4.95, -42.38)
    lobbyData[5] = vect(3, -3.99, -22.07)
    lobbyData[6] = lobbyData[5] + vect(0, -1, 0)
    lobbyData[7] = lobbyData[5] + vect(0, 1.5, 0)
    lobbyData[1] = lobbyData[5] + vect(0, 2.3, 0)
    lobbyData[2] = lobbyData[5] + vect(0, 4.2, 0)
    lobbyData[3] = lobbyData[2] + vect(0, -1.05, 0)
    lobbyData[4] = 1.35
    lobbyData[8] = vect(-0.31, -3.99, -25.54)
    lobbyData[9] = lobbyData[8] + vect(0, -1, 0)
    lobbyData[10] = lobbyData[8] + vect(0, 1.5, 0)
    lobbyData[11] = vect(12.055, 1.25, -23.265)
    lobbyData[12] = 1.2
    lobbyData[13] = 0.7
    lbPos = []
    lbPos[1] = lobbyData[11] + vect(0, -0.65, 0)
    lbPos[2] = lbPos[1] + vect(0, -0.4, 0) * 1
    lbPos[3] = lbPos[1] + vect(0, -0.4, 0) * 2
    lbPos[4] = lbPos[1] + vect(0, -0.4, 0) * 3
    lbPos[5] = lbPos[1] + vect(0, -0.4, 0) * 4
    lbPos[6] = lbPos[1] + vect(0, -0.4, 0) * 5
    lbPos[7] = lbPos[1] + vect(0, -0.4, 0) * 6
    lbPos[8] = lbPos[1] + vect(0, -0.4, 0) * 7
    lbPos[9] = lbPos[1] + vect(0, -0.4, 0) * 8
    lbPos[10] = lbPos[1] + vect(0, -0.4, 0) * 9
    lobbyData[14] = vect(12.03, 1.25, -32.93)
    lobbyData[15] = 1.2
    lobbyData[16] = 0.7
    lobbyData[17] = lobbyData[14] + vect(0, -0.65, 0)
    lobbyData[18] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 1
    )
    lobbyData[19] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 2
    )
    lobbyData[20] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 3
    )
    lobbyData[21] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 4
    )
    lobbyData[22] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 5
    )
    lobbyData[23] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 6
    )
    lobbyData[24] = lobbyData[17] + (
        ((vect(0, lbPos[10].y - lobbyData[17].y, 0)) / 7) * 7
    )


rule "5: Lobby Boundary":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[0]) > 20

    if eventPlayer.isFiringSecondaryFire():
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0.5)
    eventPlayer.applyImpulse(
        directionTowards(eventPlayer.getPosition(), lobbyData[0]),
        10,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )


#!include "ballkour.opy"
