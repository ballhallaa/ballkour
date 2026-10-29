#!include "VERSION"

settings {
    "main": {
        "description": f"Watchpoint: Gibraltar \n\nv{VERSION} \n\nLatest Code: 59W28 \n\nBeta Code: 9GTJH",
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
#!rulePrefix "Course"


rule "Info":
    logToInspector("Hello! Welcome to Ballkour's Watchpoint: Gibraltar course!")
    logToInspector("Original course (W1RWY) created by Spiz. Recreated by ballhallaa.")
    logToInspector(
        "This route was slightly adjusted for quality purposes and also because this map was updated in Feb, 2026. Checkpoints are slightly bigger too."
    )
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")
    logToInspector("Course playthrough: ballkour.com/gibraltar")


#!include "settings.opy"


rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    lb[1] = "BALLMYBLOVED, 3:54.23, 5, '           '"
    lb[2] = "COLDSKIN, 4:05.81, 2, '                     '"
    lb[3] = "JAKOBONEDGE, 4:21.96, 12, '         '"
    lb[4] = "BACKLINEREIN, 4:34.15, 15, '           '"
    lb[5] = "DVD, 5:02.50, 15, '                            '"
    lb[6] = "GAMINGCHAIR, 5:08.37, 16, '         '"
    lb[7] = "BLOWSKI, 5:40.50, 24, '                    '"
    lb[8] = "安宁, 5:50.20, 40, '                           '"
    lb[9] = "KINGO, 6:26.18, 37, '                        '"
    lb[10] = "VANESSA, 6:59.56, 58, '                  '"


rule "Checkpoints":
    # cpDefaults[i]: [0]cpSize [1]bounceSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 2.5
    cpDefaults[2] = 2.5
    # cps[i]: [0]cpLocation [1]isGrappleAllowed [2]isShieldBounceAllowed [3]isPiledriverAllowed [4]bounceLocation (if it has a bounce)
    # The final checkpoint only has its location. Sizes come from cpDefaults.
    cps = []
    cps[0] = [vect(30.354, 5, -151.022), false, false, true]
    cps[1] = [vect(36.24, 5.00, -145.78), false, false, true]
    cps[2] = [vect(42.536, 3.218, -140.939), true, false, true]
    cps[3] = [vect(37.89, 4.03, -125.11), true, false, true]
    cps[4] = [vect(19.895, 6, -130.757), true, true, true]
    cps[5] = [vect(46.563, 4.01, -129.999), true, true, true]
    cps[6] = [vect(32.38, 6.56, -108.87), true, false, true]
    cps[7] = [vect(27.37, 4, -88.81), true, false, true]
    cps[8] = [vect(16.181, 3.046, -67.936), false, false, true]
    cps[9] = [vect(27.89, 3.05, -70.12), true, true, true]
    cps[10] = [vect(28.072, 3.998, -105.3), true, true, true]
    cps[11] = [vect(60.854, 1, -113.372), true, true, true]
    cps[12] = [vect(44.855, 4.01, -131.473), false, false, true]
    cps[13] = [vect(39.7, 1, -144.094), false, false, true]
    cps[14] = [vect(44.91, 1, -138.61), false, false, true]
    cps[15] = [vect(44.35, 4.01, -130.82), true, true, true]
    cps[16] = [vect(33.83, 4, -90), true, false, true]
    cps[17] = [vect(30.991, 3, -72.417), true, false, true]
    cps[18] = [vect(39.055, -4.947, -75.702), false, false, true]
    cps[19] = [vect(45.022, -5, -69.766), true, true, true]
    cps[20] = [vect(47.22, 6, -67.5), false, false, true]
    cps[21] = [vect(45.4, 5.31, -51.18), false, false, true]
    cps[22] = [vect(36.368, -2.134, -56.973), true, true, true]
    cps[23] = [vect(45.662, 3, -36.151), true, true, true]
    cps[24] = [vect(67.50, 9.01, -42.18), true, true, true]
    cps[25] = [vect(41.77, 3, -73.61), false, false, true]
    cps[26] = [vect(36.668, -2.134, -57.072), true, true, true]
    cps[27] = [vect(53.683, 8.908, -36.387), true, true, true]
    cps[28] = [vect(81.77, 3, -33.09), false, false, true]
    cps[29] = [vect(86.119, 3.01, -29.821), true, true, true]
    cps[30] = [vect(77.563, 6, 6.752), true, true, true]
    cps[31] = [vect(101.21, -0.94, 40.44), true, true, true]
    cps[32] = [vect(91.745, 6, 9.719), true, true, true]
    cps[33] = [vect(83.1, 1, 56.16), true, true, true]
    cps[34] = [vect(81.151, 2.845, 28.89), true, true, true]
    cps[35] = [vect(71.21, 1, 18.59), true, true, true]
    cps[36] = [vect(77.622, 6.01, 6.08), false, false, true]
    cps[37] = [vect(75.526, 10, 7.506), false, false, true]
    cps[38] = [vect(69.811, 9.01, 12.958), false, false, true]
    cps[39] = [vect(66.62, 8.32, 26.39), true, true, true]
    cps[40] = [vect(98.874, 2.745, -16.184), true, true, true]
    cps[41] = [vect(68.47, -3.14, -13.22), false, false, true]
    cps[42] = [vect(64.54, -3, -17.9), true, true, true]
    cps[43] = [vect(64.75, 9.67, -32.17), false, false, true]
    cps[44] = [vect(53.419, 8.734, -38.662), false, false, true]
    cps[45] = [vect(36.26, -0.26, -47.19), false, false, true]
    cps[46] = [vect(45.993, 3, -36.446), true, true, true]
    cps[47] = [vect(57.496, 3, -54.121), true, false, true]
    cps[48] = [vect(47.01, 6.00, -67.42), false, false, true]
    cps[49] = [vect(32.38, -5.15, -57.33), false, false, true]
    cps[50] = [vect(34.29, 1.19, -53.24), false, false, true]
    cps[51] = [vect(40.6, -5.01, -51.2), false, false, true]
    cps[52] = [vect(43.11, -0.51, -49.171), true, true, true]
    cps[53] = [vect(65.46, -3.14, -26.55), false, false, true]
    cps[54] = [vect(62.097, 2.028, -22.853), true, true, true]
    cps[55] = [vect(73.6, -3.14, -38.12), false, false, true]
    cps[56] = [vect(74.748, 2.107, -34.64), true, true, true]
    cps[57] = [vect(50.72, 8.72, -47.45), false, false, true]
    cps[58] = [vect(45.49, 3, -36.66), true, true, true]
    cps[59] = [vect(47.22, 6, -67.5), true, true, true]
    cps[60] = [vect(39.46, -5.02, -75.88), true, true, true]
    cps[61] = [vect(14.081, 3.045, -70.069), true, true, true]
    cps[62] = [vect(27.17, 0, -104.23), false, false, true]
    cps[63] = [vect(29.24, 4, -106.27), false, false, true]
    cps[64] = [vect(42.742, -6.137, -119.077), false, false, true]
    cps[65] = [vect(36.423, 0, -112.203), false, false, true]
    cps[66] = [vect(33.015, 6.561, -109.607), false, false, true]
    cps[67] = [vect(38.88, 0, -99.49), false, false, true]
    cps[68] = [vect(32.37, 4.00, -93.09), false, false, true]
    cps[69] = [vect(39.957, 3.998, -102.764), true, false, true]
    cps[70] = [vect(33.417, 4.01, -86.09), true, true, true]
    cps[71] = [vect(44.14, 4.03, -131.19), false, false, true]
    cps[72] = [vect(35.776, 5, -144.535), true, false, true]
    cps[73] = [vect(16.589, -2, -133.052), true, false, true, vect(21.742, -1.91, -129.95)]
    cps[74] = [vect(37.649, 4.01, -124.211), true, true, true]
    cps[75] = [vect(61.452, -7.192, -141.705), true, false, true, vect(64.37, -6.31, -131.28)]
    cps[76] = [vect(60.992, 1, -115.213), true, false, true, vect(36.918, 0.092, -95.332)]
    cps[77] = [vect(27.284, 3.013, -84.642), false, false, true]
    cps[78] = [vect(16.503, -5, -70.262), true, false, true, vect(23.858, -5.068, -82.402)]
    cps[79] = [vect(29.458, 6.938, -90.962), true, true, true]
    cps[80] = [vect(38.373, -5.02, -77.208), true, false, true, vect(44.188, -5.058, -60.366)]
    cps[81] = [vect(56.069, 3, -52.942), true, false, true]
    cps[82] = [vect(47.966, -5, -68.898), true, false, true, vect(41.762, -5.059, -62.347)]
    cps[83] = [vect(36.26, -0.26, -47.19), true, true, true]
    cps[84] = [vect(62.694, -3.003, -16.511), true, false, true, vect(74.99, -2.09, -9.26)]
    cps[85] = [vect(83.645, 6, 1.309), false, false, true]
    cps[86] = [vect(97.81, 1, 12.53), true, true, true]
    cps[87] = [vect(82.13, 10.36, 14.07), false, false, true]
    cps[88] = [vect(75.569, 9, 22.556), false, false, true]
    cps[89] = [vect(59.696, 8.354, 20.334), false, false, true]
    cps[90] = [vect(51.531, 9, 9.279), false, false, true]
    cps[91] = [vect(41.032, 3, 7.798), false, false, true]
    cps[92] = [vect(46.18, 9, 10.57), false, false, true]
    cps[93] = [vect(45.06, 3, 3.14), false, false, true]
    cps[94] = [vect(48.646, 9, 7.999), true, true, true]
    cps[95] = [vect(81.852, 1, 23.622), false, false, true]
    cps[96] = [vect(79.799, 9, 21.207), true, true, true]
    cps[97] = [vect(86.008, -3.141, -1.915), false, false, true]
    cps[98] = [vect(83.375, 6, 0.473), false, false, true]
    cps[99] = [vect(90.713, -3.045, -5.413), true, false, true, vect(85.5, -3.15, -1.5)]
    cps[100] = [vect(83.375, 6, 0.473)]


#!include "hints/1-watchpoint-gibraltar.opy"


rule "Lobby":
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
    for index in range(2, 11):
        lbPos[index] = lbPos[1] + vect(0, -0.5, 0) * (index - 1)
    if isLobbyStatsOn:
        lobbyData[14] = vect(101.52, lobbyData[11].y, 62.81)
        lobbyData[15] = 1.2
        lobbyData[16] = 0.85
        lobbyData[17] = lobbyData[14] + vect(0, -0.65, 0)
        # The stats rows use the leaderboard's row spacing
        for index in range(18, 25):
            lobbyData[index] = lobbyData[17] + vect(0, -0.5, 0) * (index - 17)


rule "Lobby Boundary":
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
