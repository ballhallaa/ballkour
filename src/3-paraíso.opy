#!include "VERSION"

settings {
    "main": {
        "description": f"Paraíso \n\nv{VERSION} \n\nLatest Code: NT5G3K",
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
                "paraiso"
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
    logToInspector("Hello! Welcome to Ballkour's Paraíso course!")
    logToInspector(
        "Original course (3700E) created by Spiz. Recreated by ballmybeloved."
    )
    logToInspector(
        "This route was slightly adjusted for quality purposes. Shield bounce has been reworked for better implementation in routes."
    )
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")
    logToInspector("Course playthrough: ballkour.com/paraiso")


rule "1: Settings":
    settings_ = []
    settings_[0] = createWorkshopSettingBool("Settings", "Debug", false, 1)
    settings_[1] = createWorkshopSettingBool("Settings", "Lobby Stats", false, 0)


rule "2: Leaderboard (LB)":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    timeToBeatInMs = 0


rule "3: Checkpoints (CPs)":
    # cpDefaults[i]: [0]cpSize [1]bounceSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 2.5
    cpDefaults[2] = 2.5
    # cps[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize
    cps = []
    cps[0] = [vect(9.18, 4.99, -91.19), cpDefaults[0], false, false, true, null, null, vect(17.75, 5.00, -93.00), cpDefaults[2]]
    cps[1] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(34.19, 5.00, -106.95), cpDefaults[2]]
    cps[2] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(14.04, 4.88, -107.30), cpDefaults[2]]
    cps[3] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-1.69, 11.00, -84.34), cpDefaults[2]]
    cps[4] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(24.98, 2.00, -78.46), cpDefaults[2]]
    cps[5] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(19.48, -0.00, -58.19), cpDefaults[2]]
    cps[6] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(12.30, 1.78, -43.47), cpDefaults[2]]
    cps[7] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-2.86, 8.00, -20.14), cpDefaults[2]]
    cps[8] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-3.55, 5.00, 2.99), cpDefaults[2]]
    cps[9] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-4.85, 3.67, 17.88), cpDefaults[2]]
    cps[10] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-18.65, 8.00, -21.92), cpDefaults[2]]
    cps[11] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-28.33, 6.00, -8.23), cpDefaults[2]]
    cps[12] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(-7.58, 5.00, -3.61), cpDefaults[2]]
    cps[13] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-16.00, 5.75, 22.64), cpDefaults[2]]
    cps[14] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-27.16, -2.14, 53.44), cpDefaults[2]]
    cps[15] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-48.31, 2.14, 45.07), cpDefaults[2]]
    cps[16] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(-52.71, 4.00, 36.53), cpDefaults[2]]
    cps[17] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-27.37, 1.65, 28.16), cpDefaults[2]]
    cps[18] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-21.55, 5.75, 21.01), cpDefaults[2]]
    cps[19] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-2.97, 8.00, -19.34), cpDefaults[2]]
    cps[20] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-13.45, 8.22, -46.30), cpDefaults[2]]
    cps[21] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-20.67, 11.18, -52.79), cpDefaults[2]]
    cps[22] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-5.61, 10.00, -88.07), cpDefaults[2]]
    cps[23] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(0.49, 11.00, -63.08), cpDefaults[2]]
    cps[24] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(11.39, 10.81, -54.25), cpDefaults[2]]
    cps[25] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(5.65, 1.00, -40.71), cpDefaults[2]]
    cps[26] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-22.90, 8.00, -19.73), cpDefaults[2]]
    cps[27] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-23.97, 10.13, -49.69), cpDefaults[2]]
    cps[28] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-8.33, 5.00, -85.18), cpDefaults[2]]
    cps[29] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-6.35, 10.00, -86.90), cpDefaults[2]]
    cps[30] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(26.06, 5.00, -104.43), cpDefaults[2]]
    cps[31] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(19.55, 11.01, -87.68), cpDefaults[2]]
    cps[32] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(4.91, 4.82, -96.56), cpDefaults[2]]
    cps[33] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(6.17, 11.53, -122.86), cpDefaults[2]]
    cps[34] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-25.06, 7.70, -140.69), cpDefaults[2]]
    cps[35] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(-39.10, 6.80, -133.32), cpDefaults[2]]
    cps[36] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-27.58, 8.19, -157.64), cpDefaults[2]]
    cps[37] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(-31.90, 4.75, -163.92), cpDefaults[2]]
    cps[38] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(-39.57, 4.75, -154.24), cpDefaults[2]]
    cps[39] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(-46.34, 6.80, -142.11), cpDefaults[2]]
    cps[40] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-17.39, 0.75, -115.75), cpDefaults[2]]
    cps[41] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-19.52, 4.75, -117.85), cpDefaults[2]]
    cps[42] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-2.39, 11.53, -114.78), cpDefaults[2]]
    cps[43] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-7.72, 6.75, -147.60), cpDefaults[2]]
    cps[44] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(2.21, 5.75, -131.61), cpDefaults[2]]
    cps[45] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-36.17, 2.75, -126.62), cpDefaults[2]]
    cps[46] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-30.76, 4.75, -132.82), cpDefaults[2]]
    cps[47] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-23.41, 4.75, -121.31), cpDefaults[2]]
    cps[48] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-10.97, 6.99, -104.05), cpDefaults[2]]
    cps[49] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-16.88, 5.00, -75.55), cpDefaults[2]]
    cps[50] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-9.73, 8.39, -70.37), cpDefaults[2]]
    cps[51] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(20.10, 11.01, -83.23), cpDefaults[2]]
    cps[52] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(8.45, 10.81, -49.45), cpDefaults[2]]
    cps[53] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-16.07, 6.76, 16.67), cpDefaults[2]]
    cps[54] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(-20.06, -0.16, 18.23), cpDefaults[2]]
    cps[55] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-13.25, 5.75, 27.06), cpDefaults[2]]
    cps[56] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-61.88, -2.14, 68.41), cpDefaults[2]]
    cps[57] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-35.23, 4.03, 23.95), cpDefaults[2]]
    cps[58] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(6.36, 4.19, 6.94), cpDefaults[2]]
    cps[59] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(18.38, 2.67, -3.12), cpDefaults[2]]
    cps[60] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-11.07, 8.22, -45.50), cpDefaults[2]]
    cps[61] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(23.08, 5.00, -87.72), cpDefaults[2]]
    cps[62] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(22.85, 4.88, -93.00), cpDefaults[2]]
    cps[63] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(19.03, 6.61, -98.14), cpDefaults[2]]
    cps[64] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(7.96, 10.00, -81.59), cpDefaults[2]]
    cps[65] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(9.53, 1.01, -43.26), cpDefaults[2]]
    cps[66] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(7.60, 8.99, -44.86), cpDefaults[2]]
    cps[67] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(25.66, 5.00, -90.25), cpDefaults[2]]
    cps[68] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(22.16, 11.01, -84.71), cpDefaults[2]]
    cps[69] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-23.91, 11.18, -55.47), cpDefaults[2]]
    cps[70] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-9.88, 5.00, -78.57), cpDefaults[2]]
    cps[71] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-17.63, 8.00, -22.52), cpDefaults[2]]
    cps[72] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-4.12, 5.00, 2.39), cpDefaults[2]]
    cps[73] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(10.08, 10.81, -47.47), cpDefaults[2]]
    cps[74] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, true, true, null, null, vect(-29.35, 10.52, -59.43), cpDefaults[2]]
    cps[75] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(16.84, 4.88, -100.58), cpDefaults[2]]
    cps[76] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-3.57, 11.00, -65.15), cpDefaults[2]]
    cps[77] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, false, true, null, null, vect(12.84, 10.26, -61.34), cpDefaults[2]]
    cps[78] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-14.93, 5.75, 17.91), cpDefaults[2]]
    cps[79] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-30.09, 4.03, 21.03), cpDefaults[2]]
    cps[80] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-19.87, 8.00, -22.41), cpDefaults[2]]
    cps[81] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-63.53, -2.00, 51.52), cpDefaults[2]]
    cps[82] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-21.45, 5.75, 20.95), cpDefaults[2]]
    cps[83] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-19.64, 1.00, -36.69), cpDefaults[2]]
    cps[84] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(13.34, 4.88, -102.45), cpDefaults[2]]
    cps[85] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-8.55, 6.75, -139.64), cpDefaults[2]]
    cps[86] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-11.39, 8.00, -97.87), cpDefaults[2]]
    cps[87] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(11.61, 10.25, -65.06), cpDefaults[2]]
    cps[88] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-7.84, 10.99, -53.14), cpDefaults[2]]
    cps[89] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-4.85, 0.00, 23.68), cpDefaults[2]]
    cps[90] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-60.32, -2.00, 43.14), cpDefaults[2]]
    cps[91] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-18.95, 5.75, 19.24), cpDefaults[2]]
    cps[92] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-20.88, 11.18, -51.89), cpDefaults[2]]
    cps[93] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(8.48, 1.07, -1.28), cpDefaults[2]]
    cps[94] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(22.69, 3.00, -72.08), cpDefaults[2]]
    cps[95] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-12.70, 8.00, -25.17), cpDefaults[2]]
    cps[96] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(28.68, 4.88, -110.37), cpDefaults[2]]
    cps[97] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-10.89, 8.22, -45.51), cpDefaults[2]]
    cps[98] = [(cps[len(cps) - 2])[7], cpDefaults[0], false, false, true, null, null, vect(-7.26, 11.00, -53.87), cpDefaults[2]]
    cps[99] = [(cps[len(cps) - 2])[7], cpDefaults[0], true, true, true, null, null, vect(-46.38, -3.18, 81.13), cpDefaults[2]]
    cps[100] = [(cps[len(cps) - 2])[7], cpDefaults[0]]


rule "3.2: Disrupter Destructors":
    # ddbots[0]: team; ddbots[i > 0]: [0]spawnLocation [1]facingDirection
    ddBots = []
    ddBots[0] = Team.1
    # Checkpoint 3/4
    ddBots[1] = [vect(-2.63, 11.00, -83.88), vect(22.74, 6.70, -114.18)]
    # Checkpoint 7
    ddBots[2] = [vect(-2.96, 8.00, -18.76), vect(0.40, 9.02, -20.77)]
    # Checkpoint 8
    ddBots[3] = [vect(-3.17, 8.00, -22.04), vect(-10.49, 5.84, 3.58)]
    # Checkpoint 9
    ddBots[4] = [vect(-3.55, 5.00, 2.99), vect(-2.98, 4.32, 34.96)]
    # Checkpoint 11
    ddBots[5] = [vect(-18.65, 8.00, -21.92), vect(-30.13, 7.53, -3.30)]
    ddBots[6] = [vect(-28.33, 6.00, -8.23), vect(-5.20, 7.37, -22.06)]
    # Checkpoint 18
    ddBots[7] = [vect(-21.55, 5.75, 21.01), vect(-38.88, 5.70, 31.53)]
    # Checkpoint 23
    ddBots[8] = [vect(-5.40, 10.00, -87.35), vect(0.55, 10.44, -64.05)]
    ddBots[9] = [vect(0.40, 11.00, -61.71), vect(-5.85, 11.48, -91.18)]
    # Checkpoint 24
    ddBots[10] = [vect(0.49, 11.00, -63.08), vect(86.14, -0.66, -15.75)]
    # Checkpoint 37
    ddBots[11] = [vect(-31.90, 4.75, -163.92), vect(-28.05, 6.15, -160.24)]
    # Checkpoint 38
    ddBots[12] = [vect(-39.71, 4.75, -154.01), vect(-26.85, 5.37, -166.66)]
    # Checkpoint 39
    ddBots[13] = [vect(-39.57, 4.75, -154.24), vect(-46.22, 5.33, -142.42)]
    # Checkpoint 41
    ddBots[14] = [vect(-19.52, 4.75, -117.85), vect(13.02, 4.90, -86.65)]
    # Checkpoint 44
    ddBots[15] = [vect(-7.72, 6.75, -147.60), vect(-2.16, 7.63, -132.99)]
    ddBots[16] = [vect(2.21, 5.75, -131.61), vect(-7.09, 6.82, -126.19)]
    ddBots[17] = [vect(-7.17, 6.76, -142.93), vect(-2.27, 8.12, -132.89)]
    # Checkpoint 46
    ddBots[18] = [vect(-36.17, 2.75, -126.62), vect(-26.00, 5.05, -156.74)]
    ddBots[19] = [vect(-30.76, 4.75, -132.82), vect(-38.27, 5.04, -133.76)]
    # Checkpoint 48
    ddBots[20] = [vect(-10.97, 6.99, -104.05), vect(-26.00, 5.05, -156.74)]
    # Checkpoint 54
    ddBots[21] = [vect(-16.07, 6.76, 16.67), vect(68.47, 5.95, -35.29)]
    # Checkpoint 55
    ddBots[22] = [vect(-13.25, 5.75, 27.06), vect(-19.56, 6.49, 30.68)]
    # Checkpoint 77
    ddBots[23] = [vect(-3.57, 11.00, -65.15), vect(21.84, 11.18, -100.38)]
    # Checkpoint 87
    ddBots[24] = [vect(-11.40, 8.00, -96.35), vect(18.08, 9.67, -125.08)]
    ddBots[25] = [vect(-9.69, 6.10, -100.19), vect(1.51, 4.73, -107.48)]
    ddBots[26] = [vect(-8.19, 5.00, -98.50), vect(6.46, 5.11, -113.01)]
    ddBots[27] = [vect(-11.50, 6.99, -101.11), vect(9.43, 4.89, -119.65)]
    # Checkpoint 88
    ddBots[28] = [vect(-7.84, 10.99, -53.14), vect(-20.91, 9.78, -30.70)]
    # Checkpoint 90
    ddBots[29] = [vect(-10.91, 5.75, 26.76), vect(19.48, 6.95, 8.30)]
    ddBots[30] = [vect(-13.97, 5.75, 24.67), vect(13.76, 0.00, 13.56)]


rule "4: Lobby":
    # lobbyData[i]: [0]spawnpoint [1]facing [2]welcomeSignTop [3]welcomeSignBottom [4]welcomeSignSize [5]startRunRing [6]startRunIcon [7]startRunSign [8]resumeRunRing [9]resumeRunIcon [10]resumeRunSign [11]lbSign [12]lbSignTextSize [13]lbPosTextSize [14]statsSign [15]statsSignSize [16]statsSize [17]elapsedTime [18]newPlayers [19]rejoins [20]legitRuns [21]totalRunTime [22]totalMistakes [23]avgRunTime [24]avgMistakes
    lobbyData = []
    lobbyData[0] = vect(-38.33, 6.01, -96.34)
    lobbyData[5] = vect(-27.165, 6.01, -89.69)
    lobbyData[6] = lobbyData[5] + vect(0, -1, 0)
    lobbyData[7] = lobbyData[5] + vect(0, 1.5, 0)
    lobbyData[1] = lobbyData[5] + vect(0, 2.75, 0)
    lobbyData[2] = lobbyData[5] + vect(0, 5.25, 0)
    lobbyData[3] = lobbyData[2] + vect(0, -0.8, 0)
    lobbyData[4] = 1.5
    lobbyData[8] = vect(-25.805, 6.01, -94.965)
    lobbyData[9] = lobbyData[8] + vect(0, -1, 0)
    lobbyData[10] = lobbyData[8] + vect(0, 1.5, 0)
    lobbyData[11] = vect(-31.81, lobbyData[2].y + 0.5, -84.87)
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
    lobbyData[14] = vect(-30.34, lobbyData[11].y - 0.5, -101.15)
    lobbyData[15] = 1.08
    lobbyData[16] = 0.765
    lobbyData[17] = lobbyData[14] + vect(0, -0.585, 0)
    lobbyData[18] = lobbyData[17] + vect(0, -0.45, 0) * 1
    lobbyData[19] = lobbyData[17] + vect(0, -0.45, 0) * 2
    lobbyData[20] = lobbyData[17] + vect(0, -0.45, 0) * 3
    lobbyData[21] = lobbyData[17] + vect(0, -0.45, 0) * 4
    lobbyData[22] = lobbyData[17] + vect(0, -0.45, 0) * 5
    lobbyData[23] = lobbyData[17] + vect(0, -0.45, 0) * 6
    lobbyData[24] = lobbyData[17] + vect(0, -0.45, 0) * 7


rule "5: Lobby Boundary":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[0]) > 18

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
