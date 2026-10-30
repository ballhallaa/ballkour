#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(Blizzard World (Winter), GMWRF, 8Y14F, 0, 12, "blizzWorldWinter")

#!include "../../declarations.opy"

#!optimizeStrict
#!rulePrefix "Course"


rule "Info":
    logToInspector("Hello! Welcome to Ballkour's Blizzard World (Winter) course!")
    logToInspector("Original course (6B9Z09) created by Spiz. Remade by ballhallaa.")
    logToInspector("Changes: this route's checkpoints are slightly bigger")
    logToInspector("Discord: ballkour.com/discord")
    logToInspector("Set a top-10 time? Submit a video with your run in our Discord!")
    logToInspector("Course playthrough: ballkour.com/blizz-world")


#!include "../../settings.opy"
#!include "leaderboard.opy"
#!include "checkpoints.opy"


rule "Disruptive Environment Destructors":
    # dedBots[0]: team; dedBots[i > 0]: [0]spawnLocation [1]facingDirection
    dedBots = []
    dedBots[0] = Team.2
    # Checkpoint 39
    dedBots[1] = [vect(-109.674, -4.25, 111.782), vect(-98.37, -2.17, 114.92)]
    dedBots[2] = [vect(-109.674, -4.25, 111.782), vect(-94.55, -2.83, 103.54)]
    dedBots[3] = [vect(-108.22, -4.13, 107.72), vect(-104.33, -2.83, 101.1)]
    dedBots[4] = [vect(-103.549, -2.25, 100.17), vect(-108.92, -5.08, 120.59)]
    # Checkpoint 45
    dedBots[5] = [vect(-96.88, -1.25, 111.06), vect(-112.62, -3.65, 107.32)]
    dedBots[6] = [vect(-97.41, -1.25, 114.94), vect(-111.9, 0.21, 111.15)]
    dedBots[7] = [vect(-94.85, -1.25, 108.65), vect(-112.79, -0.62, 105.81)]
    # Checkpoint 46
    dedBots[8] = [vect(-109.511, -4.25, 121.231), vect(-97.74, -2.56, 114.55)]
    dedBots[9] = [vect(-97.917, -1.253, 116.947), vect(-112.85, 0.12, 112.92)]


#!include "hints.opy"
#!include "lobby.opy"
#!include "../../ballkour.opy"
