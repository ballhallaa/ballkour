#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(Blizzard World (Winter), GMWRF, 8Y14F, 0, 12, "blizzWorldWinter")

#!include "../../declarations.opy"

#!optimizeStrict
#!rulePrefix "Course"


rule "Info":
    logToInspector("Hello! Welcome to Ballkour's Blizzard World (Winter) course!")
    logToInspector("Original course (6B9Z09) created by Spiz. Recreated by ballhallaa.")
    logToInspector("Changes: this route's checkpoints are slightly bigger")
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")
    logToInspector("Course playthrough: ballkour.com/blizz-world")


#!include "../../settings.opy"
#!include "leaderboard.opy"
#!include "checkpoints.opy"


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


#!include "hints.opy"
#!include "lobby.opy"
#!include "../../ballkour.opy"
