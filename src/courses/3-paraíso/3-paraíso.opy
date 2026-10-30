#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(Paraíso, NT5G3K, MXJ0W, 12, 0, "paraiso")

#!include "../../declarations.opy"

#!optimizeStrict
#!rulePrefix "Course"


rule "Info":
    logToInspector("Hello! Welcome to Ballkour's Paraíso course!")
    logToInspector(
        "Original course (3700E) created by Spiz. Recreated by ballmybeloved."
    )
    logToInspector(
        "This route was slightly adjusted for quality purposes. Shield bounce has been reworked for better implementation in routes."
    )
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")


#!include "../../settings.opy"
#!include "leaderboard.opy"
#!include "checkpoints.opy"


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


#!include "hints.opy"
#!include "lobby.opy"
#!include "../../ballkour.opy"
