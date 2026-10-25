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
#!rulePrefix "Course"


rule "Contact & Info":
    logToInspector("Hello! Welcome to Ballkour's Paraíso course!")
    logToInspector(
        "Original course (3700E) created by Spiz. Recreated by ballmybeloved."
    )
    logToInspector(
        "This route was slightly adjusted for quality purposes. Shield bounce has been reworked for better implementation in routes."
    )
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")


#!include "settings.opy"


rule "Leaderboard (LB)":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []


rule "Checkpoints (CPs)":
    # cpDefaults[i]: [0]cpSize [1]bounceSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 2.5
    cpDefaults[2] = 2.5
    # cps[i]: [0]cpLocation [1]isGrappleAllowed [2]isShieldBounceAllowed [3]isPiledriverAllowed [4]bounceLocation (if it has a bounce)
    # The final checkpoint only has its location. Sizes come from cpDefaults.
    cps = []
    cps[0] = [vect(9.18, 4.99, -91.19), false, false, true]
    cps[1] = [vect(17.75, 5.00, -93.00), true, false, true]
    cps[2] = [vect(34.19, 5.00, -106.95), false, true, true]
    cps[3] = [vect(14.04, 4.88, -107.30), true, true, true]
    cps[4] = [vect(-1.69, 11.00, -84.34), true, true, true]
    cps[5] = [vect(20.61, 3.00, -71.83), false, false, true]
    cps[6] = [vect(22.44, 3.00, -59.43), true, false, true]
    cps[7] = [vect(12.30, 1.78, -43.47), true, true, true]
    cps[8] = [vect(-2.86, 8.00, -20.14), true, true, true]
    cps[9] = [vect(-3.55, 5.00, 2.99), false, false, true]
    cps[10] = [vect(-4.85, 3.67, 17.88), true, true, true]
    cps[11] = [vect(-18.65, 8.00, -21.92), false, false, true]
    cps[12] = [vect(-28.33, 6.00, -8.23), true, false, true]
    cps[13] = [vect(-7.58, 5.00, -3.61), true, true, true]
    cps[14] = [vect(-16.00, 5.75, 22.64), true, true, true]
    cps[15] = [vect(-27.16, -2.14, 53.44), true, true, true]
    cps[16] = [vect(-48.31, 2.14, 45.07), false, true, true]
    cps[17] = [vect(-51.49, 1.43, 25.74), true, true, true]
    cps[18] = [vect(-27.37, 1.65, 28.16), false, false, true]
    cps[19] = [vect(-21.55, 5.75, 21.01), true, true, true]
    cps[20] = [vect(-2.97, 8.00, -19.34), true, true, true]
    cps[21] = [vect(-15.71, 9.49, -46.88), false, false, true]
    cps[22] = [vect(-21.15, 4.85, -56.92), true, true, true]
    cps[23] = [vect(-5.61, 10.00, -88.07), true, true, true]
    cps[24] = [vect(0.49, 11.00, -63.08), false, false, true]
    cps[25] = [vect(10.02, 10.04, -53.76), false, false, true]
    cps[26] = [vect(5.65, 1.00, -40.71), true, true, true]
    cps[27] = [vect(-22.90, 8.00, -19.73), true, true, true]
    cps[28] = [vect(-19.16, 9.50, -49.11), true, true, true]
    cps[29] = [vect(-8.33, 5.00, -85.18), false, false, true]
    cps[30] = [vect(-6.35, 10.00, -86.90), true, true, true]
    cps[31] = [vect(26.06, 5.00, -104.43), true, true, true]
    cps[32] = [vect(19.55, 11.01, -87.68), false, false, true]
    cps[33] = [vect(4.91, 4.82, -96.56), true, true, true]
    cps[34] = [vect(8.63, 12.67, -123.70), true, true, true]
    cps[35] = [vect(-16.09, 7.04, -138.80), true, true, true]
    cps[36] = [vect(-48.08, 5.28, -132.20), true, true, true]
    cps[37] = [vect(-28.03, 4.32, -159.00), false, false, true]
    cps[38] = [vect(-31.90, 4.75, -163.92), false, false, true]
    cps[39] = [vect(-42.35, 3.78, -156.35), false, false, true]
    cps[40] = [vect(-44.27, 4.32, -143.61), true, true, true]
    cps[41] = [vect(-11.08, 1.77, -117.12), false, false, true]
    cps[42] = [vect(-14.52, 6.34, -109.04), true, true, true]
    cps[43] = [vect(-1.50, 12.67, -113.76), true, true, true]
    cps[44] = [vect(-8.03, 7.04, -139.50), false, false, true]
    cps[45] = [vect(5.03, 6.75, -135.12), true, true, true]
    cps[46] = [vect(-22.71, 4.25, -123.58), true, true, true]
    cps[47] = [vect(-48.29, 5.28, -132.41), true, true, true]
    cps[48] = [vect(-22.57, 4.32, -124.03), true, true, true]
    cps[49] = [vect(-10.97, 6.99, -104.05), true, true, true]
    cps[50] = [vect(-18.15, 5.01, -80.34), false, false, true]
    cps[51] = [vect(-14.90, 9.74, -76.17), true, true, true]
    cps[52] = [vect(20.10, 11.01, -83.23), true, true, true]
    cps[53] = [vect(8.45, 10.81, -49.45), true, true, true]
    cps[54] = [vect(-16.07, 6.76, 16.67), false, true, true]
    cps[55] = [vect(-20.06, -0.16, 18.23), true, true, true]
    cps[56] = [vect(-13.25, 5.75, 27.06), true, true, true]
    cps[57] = [vect(-61.88, -2.14, 68.41), true, true, true]
    cps[58] = [vect(-35.23, 4.03, 23.95), true, true, true]
    cps[59] = [vect(13.28, 4.19, 9.54), false, false, true]
    cps[60] = [vect(18.38, 2.67, -3.12), true, true, true]
    cps[61] = [vect(-14.66, 5.02, -41.68), true, true, true]
    cps[62] = [vect(23.08, 5.00, -87.72), false, false, true]
    cps[63] = [vect(22.85, 4.88, -93.00), false, false, true]
    cps[64] = [vect(19.03, 6.61, -98.14), true, true, true]
    cps[65] = [vect(7.96, 10.00, -81.59), true, true, true]
    cps[66] = [vect(15.21, 2.99, -49.11), true, true, true]
    cps[67] = [vect(13.96, 10.04, -51.00), true, true, true]
    cps[68] = [vect(25.66, 5.00, -90.25), false, false, true]
    cps[69] = [vect(22.16, 11.01, -84.71), true, true, true]
    cps[70] = [vect(-27.35, 7.87, -57.25), true, true, true]
    cps[71] = [vect(-9.88, 5.00, -78.57), true, true, true]
    cps[72] = [vect(-17.63, 8.00, -22.52), true, true, true]
    cps[73] = [vect(-4.12, 5.00, 2.39), true, true, true]
    cps[74] = [vect(12.29, 10.04, -50.39), false, true, true]
    cps[75] = [vect(-20.95, 4.85, -57.38), true, true, true]
    cps[76] = [vect(16.84, 4.88, -100.58), true, true, true]
    cps[77] = [vect(-3.81, 9.74, -61.53), false, false, true]
    cps[78] = [vect(13.42, 7.83, -61.18), true, true, true]
    cps[79] = [vect(-14.93, 5.75, 17.91), false, false, true]
    cps[80] = [vect(-30.09, 4.03, 21.03), true, true, true]
    cps[81] = [vect(-19.87, 8.00, -22.41), true, true, true]
    cps[82] = [vect(-63.53, -2.00, 51.52), true, true, true]
    cps[83] = [vect(-21.45, 5.75, 20.95), true, true, true]
    cps[84] = [vect(-19.64, 1.00, -36.69), true, true, true]
    cps[85] = [vect(13.34, 4.88, -102.45), true, true, true]
    cps[86] = [vect(-7.65, 7.04, -139.10), true, true, true]
    cps[87] = [vect(-11.39, 8.00, -97.87), true, true, true]
    cps[88] = [vect(11.61, 7.83, -65.06), true, true, true]
    cps[89] = [vect(-7.84, 8.74, -53.14), true, true, true]
    cps[90] = [vect(-4.85, 0.00, 23.68), true, true, true]
    cps[91] = [vect(-60.32, -2.00, 43.14), true, true, true]
    cps[92] = [vect(-18.95, 5.75, 19.24), true, true, true]
    cps[93] = [vect(-18.64, 9.49, -49.18), true, true, true]
    cps[94] = [vect(8.48, 1.07, -1.28), true, true, true]
    cps[95] = [vect(19.28, 3.00, -65.92), true, true, true]
    cps[96] = [vect(-12.70, 8.00, -25.17), true, true, true]
    cps[97] = [vect(28.68, 4.88, -110.37), true, true, true]
    cps[98] = [vect(-9.66, 2.97, -48.15), false, false, true]
    cps[99] = [vect(-5.96, 8.74, -52.41), true, true, true]
    cps[100] = [vect(-46.38, -3.18, 81.13)]


rule "Disrupter Destructors":
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
    # Checkpoint 98
    ddBots[31] = [vect(-5.35, 8.74, -52.93), vect(-6.86, 9.95, -50.95)]


#!include "hints/3-paraíso.opy"


rule "Lobby":
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
    for index in range(2, 11):
        lbPos[index] = lbPos[1] + vect(0, -0.5, 0) * (index - 1)
    if isLobbyStatsOn:
        lobbyData[14] = vect(-30.34, lobbyData[11].y - 0.5, -101.15)
        lobbyData[15] = 1.08
        lobbyData[16] = 0.765
        lobbyData[17] = lobbyData[14] + vect(0, -0.585, 0)
        for index in range(18, 25):
            lobbyData[index] = lobbyData[17] + vect(0, -0.45, 0) * (index - 17)


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
