#!include "../../VERSION"
#!include "../../game-settings.opy"

settings courseSettings(5, Practice Range, 7RR2Z, "practiceRange": {"enabledMaps": ["practiceRange"], "spawnTrainingBots": false, "enableTrainingPartner": false})
# The course's original author, credited under BALLKOUR.COM
#!define COURSE_AUTHOR "Spiz"

#!include "../../declarations.opy"

#!optimizeStrict
#!rulePrefix "Course"
#!include "../../../leaderboards/5-practice-range.opy"
#!include "checkpoints.opy"


#!include "hints.opy"
#!include "../../ballkour.opy"