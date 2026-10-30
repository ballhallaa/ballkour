#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(Watchpoint: Gibraltar, 59W28, 9GTJH, 12, 0, {"watchpointGibraltar": ["972777519512068292"]})

#!include "../../declarations.opy"

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


#!include "../../settings.opy"
#!include "leaderboard.opy"
#!include "checkpoints.opy"
#!include "hints.opy"
#!include "lobby.opy"
#!include "../../ballkour.opy"
