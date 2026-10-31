#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(Watchpoint: Gibraltar, 59W28, 9GTJH, 12, 0, {"watchpointGibraltar": ["972777519512068292"]})

#!include "../../declarations.opy"

#!optimizeStrict
#!rulePrefix "Course"


rule "Info":
    logToInspector("Hello! Welcome to Ballkour's Watchpoint: Gibraltar course!")
    logToInspector("Legacy Code: W1RWY | Creator: Spiz • Remaker: ballhallaa")
    logToInspector(
        "Changes: checkpoint position QOL adjustments, bigger checkpoints, added shield bounces, and moved checkpoints due to map updates"
    )
    logToInspector("Course playthrough: ballkour.com/gibraltar")


#!include "../../settings.opy"
#!include "../../../leaderboards/1-watchpoint-gibraltar.opy"
#!include "checkpoints.opy"
#!include "hints.opy"
#!include "lobby.opy"
#!include "../../ballkour.opy"
