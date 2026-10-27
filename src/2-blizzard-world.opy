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
#!rulePrefix "Course"


rule "Info":
    logToInspector("Hello! Welcome to Ballkour's Blizzard World (Winter) course!")
    logToInspector("Original course (6B9Z09) created by Spiz. Recreated by ballhallaa.")
    logToInspector("Changes: this route's checkpoints are slightly bigger")
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")
    logToInspector("Course playthrough: ballkour.com/blizz-world")


#!include "settings.opy"


rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    lb[1] = "BALLMYBLOVED, 7:14.76, 16, '        '"


rule "Checkpoints":
    # cpDefaults[i]: [0]cpSize [1]bounceSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 2.5
    cpDefaults[2] = 2.5
    # cps[i]: [0]cpLocation [1]isGrappleAllowed [2]isShieldBounceAllowed [3]isPiledriverAllowed [4]bounceLocation (if it has a bounce)
    # The final checkpoint only has its location. Sizes come from cpDefaults.
    cps = []
    cps[0] = [vect(3.011, -1.85, -6.987), false, false, true]
    cps[1] = [vect(3.112, -4.1, -15.46), true, true, true]
    cps[2] = [vect(-12.488, -4.1, -28.956), true, true, true]
    cps[3] = [vect(-15.061, -4.1, -6.952), true, true, true]
    cps[4] = [vect(-2.567, -0.1, 10.363), true, true, true]
    cps[5] = [vect(22.806, -4.1, -6.891), true, true, true]
    cps[6] = [vect(14.15, -5.1, 16.387), true, false, true]
    cps[7] = [vect(-0.759, -5.1, 16.522), false, false, true]
    cps[8] = [vect(-8.024, -5.1, 16.514), true, true, true]
    cps[9] = [vect(-25.24, -2, 8.244), true, true, true]
    cps[10] = [vect(2.963, -0.1, 21.386), true, true, true]
    cps[11] = [vect(-8.597, 6, 48.236), true, true, true]
    cps[12] = [vect(-10.812, -4.1, -1.167), true, true, true]
    cps[13] = [vect(-2.16, 2.5, 14.995), true, true, true]
    cps[14] = [vect(-12.01, 1.013, 34.086), true, true, true]
    cps[15] = [vect(-9.78, 1.894, 65.491), true, false, true]
    cps[16] = [vect(18.006, 2, 78.984), true, true, true]
    cps[17] = [vect(37.491, 2.001, 78.629), true, false, true]
    cps[18] = [vect(28.438, 5.938, 69.758), true, true, true]
    cps[19] = [vect(-2.009, -0.971, 100.167), true, true, true]
    cps[20] = [vect(-19.706, 0.286, 115.325), true, true, true]
    cps[21] = [vect(-39.196, -0.135, 122.632), true, true, true]
    cps[22] = [vect(-17.044, 2.099, 81.878), true, true, true]
    cps[23] = [vect(3.142, 8.105, 80.104), true, true, true]
    cps[24] = [vect(-40.516, -0.205, 111.274), true, true, true]
    cps[25] = [vect(-32.354, 5.805, 100.072), true, true, true]
    cps[26] = [vect(-9.743, -0.971, 110.646), true, true, true]
    cps[27] = [vect(11.236, 6, 92.128), true, true, true]
    cps[28] = [vect(22.295, 6, 57.364), true, true, true]
    cps[29] = [vect(2.488, 3.6, 43.773), true, true, true]
    cps[30] = [vect(11.297, 6, 83.438), true, true, true]
    cps[31] = [vect(-12.436, 1.927, 88.845), true, true, true]
    cps[32] = [vect(-29.986, 11.896, 88.363), true, true, true]
    cps[33] = [vect(-66.556, 6.329, 102.812), false, false, true]
    cps[34] = [vect(-56.331, 4.718, 92.693), false, false, true]
    cps[35] = [vect(-62.475, 6.241, 84.122), false, false, true]
    cps[36] = [vect(-63.286, 5.689, 99.603), true, true, true]
    cps[37] = [vect(-75.88, 0.795, 118.482), true, true, true]
    cps[38] = [vect(-121.605, -0.053, 110.725), true, true, true]
    cps[39] = [vect(-109.674, -4.25, 111.782), false, false, true]
    cps[40] = [vect(-103.549, -2.25, 100.17), true, true, true]
    cps[41] = [vect(-128.399, 1.75, 91.229), true, true, true]
    cps[42] = [vect(-110.239, -4.25, 113.923), true, true, true]
    cps[43] = [vect(-114.552, 4.75, 129.523), false, false, true]
    cps[44] = [vect(-105.666, 4.747, 141.857), true, true, true]
    cps[45] = [vect(-95.923, -1.253, 109.751), false, false, true]
    cps[46] = [vect(-109.511, -4.25, 121.231), false, false, true]
    cps[47] = [vect(-97.917, -1.253, 116.947), true, true, true]
    cps[48] = [vect(-138.975, 0.747, 130.492), true, true, true]
    cps[49] = [vect(-104.378, 4.75, 131.192), true, true, true]
    cps[50] = [vect(-60.888, 0.747, 124.561), true, true, true]
    cps[51] = [vect(-78.806, 6.575, 99.486), true, true, true]
    cps[52] = [vect(-42.825, -0.241, 116.719), true, true, true]
    cps[53] = [vect(-35.323, 5.805, 93.245), true, true, true]
    cps[54] = [vect(-21.563, 1.917, 80.519), true, true, true]
    cps[55] = [vect(-4.203, 6, 53.199), false, false, true]
    cps[56] = [vect(-2.225, 2, 67.376), true, true, true]
    cps[57] = [vect(20.274, 2, 66.958), false, false, true]
    cps[58] = [vect(18.322, 4.541, 68.009), false, false, true]
    cps[59] = [vect(21.55, 6, 57.536), true, true, true]
    cps[60] = [vect(6.128, -0.09, 38.622), false, false, true]
    cps[61] = [vect(4.425, 3.6, 40.507), false, false, true]
    cps[62] = [vect(2.62, 3.6, 43.804), false, false, true]
    cps[63] = [vect(-8.523, 6, 48.221), true, true, true]
    cps[64] = [vect(-41.591, -0.394, 75.849), true, true, true]
    cps[65] = [vect(-61.357, 6.359, 81.3), true, true, true]
    cps[66] = [vect(-41.03, 9.425, 102.345), true, true, true]
    cps[67] = [vect(-6.045, 1.881, 66.85), true, true, true]
    cps[68] = [vect(7.874, -0.09, 43.955), true, true, true]
    cps[69] = [vect(12.82, -5, 21.437), false, false, true]
    cps[70] = [vect(9.84, 0, 21.521), true, true, true]
    cps[71] = [vect(1.022, -4.1, -0.224), false, false, true]
    cps[72] = [vect(0.301, 1.78, 4.124), true, true, true]
    cps[73] = [vect(18.269, -0.847, -7), true, false, true]
    cps[74] = [vect(18.598, -5.096, 7.558), false, false, true]
    cps[75] = [vect(10.005, 0, 11.922), true, true, true]
    cps[76] = [vect(-4.956, 0, 26.835), true, false, true]
    cps[77] = [vect(-4.917, 0.008, 44.877), false, false, true]
    cps[78] = [vect(-6.091, 6.097, 48.213), true, true, true]
    cps[79] = [vect(23.501, 6, 61.909), true, true, true]
    cps[80] = [vect(4.102, -0.971, 107.906), false, false, true]
    cps[81] = [vect(16.166, -0.971, 96.608), true, true, true]
    cps[82] = [vect(11.662, 6, 92.034), false, false, true]
    cps[83] = [vect(11.113, 2, 81.002), false, false, true]
    cps[84] = [vect(6.542, 6, 81.517), false, false, true]
    cps[85] = [vect(3.238, 7.917, 79.977), true, true, true]
    cps[86] = [vect(-46.083, -0.205, 64.609), true, true, true]
    cps[87] = [vect(-56.83, 5.418, 82.844), false, false, true]
    cps[88] = [vect(-40.117, -0.205, 82.926), false, false, true]
    cps[89] = [vect(-42.545, 4.723, 89.936), true, true, true]
    cps[90] = [vect(-37.447, -0.359, 122.8), false, false, true]
    cps[91] = [vect(-41.957, -0.205, 133.756), true, true, true]
    cps[92] = [vect(-61.432, 0.747, 126.449), false, false, true]
    cps[93] = [vect(-57.78, -0.21, 128.12), true, true, true]
    cps[94] = [vect(-78.123, 0.597, 127.947), true, true, true]
    cps[95] = [vect(-108.472, 4.846, 138.498), true, true, true]
    cps[96] = [vect(-97.142, -1.252, 101.891), true, true, true]
    cps[97] = [vect(-97.889, 4.747, 143.351), true, true, true]
    cps[98] = [vect(-76.435, 0.747, 139.58), true, true, true]
    cps[99] = [vect(-81.98, 6.772, 104.388), false, false, true]
    cps[100] = [vect(-71.238, 0.793, 114.628), true, false, true, vect(-61.63, 0.79, 118.97)]
    cps[101] = [vect(-42.78, 3.797, 129.447), true, true, true]
    cps[102] = [vect(-10.367, 1.9, 86.273), false, false, true]
    cps[103] = [vect(-0.622, 6.034, 81.12), false, false, true]
    cps[104] = [vect(8.636, 1.9, 74.911), true, false, true, vect(-5.36, 1.9, 74.68)]
    cps[105] = [vect(-0.685, 6.504, 81.114), true, false, true]
    cps[106] = [vect(-1.234, 1.173, 60.973), true, true, true]
    cps[107] = [vect(3.214, -0.097, 30.035), true, true, true]
    cps[108] = [vect(-7.198, -4, -16.403), true, false, true, vect(0.56, -4, -9.23)]
    cps[109] = [vect(2.854, 0, 7.195), false, false, true]
    cps[110] = [vect(2.966, -1.85, -6.891)]


rule "Disrupter Destructors":
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


#!include "hints/2-blizzard-world.opy"


rule "Lobby":
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
    for index in range(2, 11):
        lbPos[index] = lbPos[1] + vect(0, -0.4, 0) * (index - 1)
    if isLobbyStatsOn:
        lobbyData[14] = vect(12.03, 1.25, -32.93)
        lobbyData[15] = 1.2
        lobbyData[16] = 0.7
        lobbyData[17] = lobbyData[14] + vect(0, -0.65, 0)
        # The stats rows use the leaderboard's row spacing
        for index in range(18, 25):
            lobbyData[index] = lobbyData[17] + vect(0, -0.4, 0) * (index - 17)


rule "Lobby Boundary":
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
