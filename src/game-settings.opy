# The custom game settings every course shares: see courses/<course>/<course>.opy for what differs.
# Text arguments go in without quotes, as #!define swaps them into the strings below.
#!define courseSettings(COURSE_NAME, LATEST_CODE, BETA_CODE, TEAM_1_SLOTS, TEAM_2_SLOTS, ENABLED_MAP) { \
    "main": { \
        "description": f"COURSE_NAME \n\nv{VERSION} \n\nLatest Code: LATEST_CODE \n\nBeta Code: BETA_CODE", \
        "modeName": "Ball Parkour ● ballkour.com" \
    }, \
    "lobby": { \
        "allowPlayersInQueue": true, \
        "mapRotation": "paused", \
        "enableMatchVoiceChat": true, \
        "spectatorSlots": 12, \
        "team1Slots": TEAM_1_SLOTS, \
        "team2Slots": TEAM_2_SLOTS, \
        "returnToLobby": "never", \
        "swapTeamsAfterMatch": false \
    }, \
    "gamemodes": { \
        "skirmish": { \
            "enabledMaps": [ENABLED_MAP] \
        }, \
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
