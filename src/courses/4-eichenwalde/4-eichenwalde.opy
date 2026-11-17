#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(4, Eichenwalde, N/A, S7QD6, "skirmish": {"enabledMaps": [{"eichenwalde": ["972777519512095572"]}]})
# The course's original author, credited under BALLKOUR.COM
#!define COURSE_AUTHOR "Spiz"

#!include "../../declarations.opy"

#!optimizeStrict
#!rulePrefix "Course"
#!include "../../../leaderboards/4-eichenwalde.opy"
#!include "checkpoints.opy"


rule "Disruptive Environment Destructors":
    # dedBots[i]: [0]spawnLocation [1]facingDirection
    # Checkpoint 8
    dedBots[0] = [vect(11.82, 11.01, -84.25), vect(14.08, 13.04, -81.65)]
    # Checkpoint 30
    dedBots[1] = [vect(11.82, 11.01, -84.25), vect(-9.45, 10.83, -80.27)]
    # Checkpoint 47
    dedBots[2] = [vect(129.96, 14.74, -37.18), vect(111.03, 16.72, -30.29)]
    dedBots[3] = [vect(113.63, 14.72, -30.96), vect(128.22, 15.46, -35.29)]
    # Checkpoint 50
    dedBots[4] = [vect(113.63, 14.72, -30.96), vect(124.31, 16.64, -19.32)]
    # Checkpoint 51
    dedBots[5] = [vect(125.75, 14.73, -18.33), vect(116.19, 16.02, -52.26)]
    # Checkpoint 53
    dedBots[6] = [vect(82.65, 15.72, -36.61), vect(129.16, 15.87, -51.68)]
    # Checkpoint 54
    dedBots[7] = [vect(129.95, 14.74, -39.44), vect(128.33, 15.74, -39.16)]


#!include "hints.opy"
#!include "../../ballkour.opy"