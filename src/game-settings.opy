# The custom game settings every course shares: see courses/<course>/<course>.opy for what differs.
# Every player is on team 1, the only team with slots. The engine says PLAYER_TEAM, as black
# can't read OverPy's Team.1.
#!define PLAYER_TEAM Team.1
# Text arguments go in without quotes, as #!define swaps them into the strings below.
# GAMEMODE is the course's game mode entry: "skirmish" with its map, or "practiceRange".
#!define courseSettings(COURSE_ID, COURSE_NAME, BETA_CODE, GAMEMODE) { \
    "main": { \
        "description": f"Course COURSE_ID ● COURSE_NAME \n\nv{VERSION} \n\nBeta Code: BETA_CODE", \
        "modeName": "Ball Parkour ● ballkour.com" \
    }, \
    "lobby": { \
        "allowPlayersInQueue": true, \
        "mapRotation": "paused", \
        "enableMatchVoiceChat": true, \
        "spectatorSlots": 12, \
        "team1Slots": 12, \
        "team2Slots": 0, \
        "returnToLobby": "never", \
        "swapTeamsAfterMatch": false \
    }, \
    "gamemodes": { \
        GAMEMODE, \
        "general": { \
            "heroLimit": "off" \
        } \
    }, \
    "heroes": { \
        "allTeams": { \
            "wreckingBall": { \
                "ability2Cooldown%": 0, \
                "secondaryFireCooldown%": 0, \
                "ability3Cooldown%": 0 \
            }, \
            "jetpackCat": { \
                "enablePassiveUnlimitedFuel": true, \
                "enableAbility1": false, \
                "enableAbility2": false \
            }, \
            "enabledHeroes": [ \
                "wreckingBall" \
            ], \
            "general": { \
                "enableInfiniteAmmo": true, \
                "passiveUltGen%": 0 \
            } \
        } \
    } \
}
