#!mainFile "../main.opy"
#!rulePrefix "Lobby"


def loadLobby():
    @Name "Load"

    eventPlayer.teleport(lobbyData[0])
    eventPlayer.applyImpulse(
        eventPlayer.getVelocity() * -0.001,
        0.001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.3)
    eventPlayer.isInLobby = true
    eventPlayer.setFacing(
        directionTowards(eventPlayer.getEyePosition(), lobbyData[1]),
        Relativity.TO_WORLD
    )
    eventPlayer.isInFreemode = false
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.nameplate = "{}".format(eventPlayer)
    wait()


rule "Load Welcome Area":
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        "Welcome to",
        lobbyData[2],
        lobbyData[4],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        "Ballkour!",
        lobbyData[3],
        lobbyData[4],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(230, 151, 0)
    )


rule "Load Leaderboard Area":
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        "Leaderboard",
        lobbyData[11],
        lobbyData[12],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_COLOR,
        rgb(
            127.5 + 127.5 * cosDeg(getTotalTimeElapsed() * 15),
            127.5 + 127.5 * cosDeg(getTotalTimeElapsed() * 15 + 120),
            127.5 + 127.5 * cosDeg(getTotalTimeElapsed() * 15 + 240)
        )
    )
    # 1st-9th Position Placeholder"
    lb[11] = "---, -:--.--, -, '                                               '"
    # 10th Position Placeholder"
    lb[12] = "---, -:--.--, -, '                                              '"
    for index in range(1, 11):
        if lb[index] == null:
            if index <= 9:
                lbObj = lb[11]
            else:
                lbObj = lb[12]
        else:
            lbObj = lb[index]
        # lbObj[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator [4]rankColor
        lbObj = lbObj.split(",")
        lbObj[3] = lbObj[3].replace("'", "")
        # Gold, silver and bronze, then the rest
        lbObj[4] = ["<fgFFFF00FF>", "<fgC0C0C0FF>", "<fgCD7F32FF>", "<fg00E092FF>"][
            min(index, 4) - 1
        ]
        lbObjFormatted = "{}. {}{}</fg>{}{}{}{}   {}{}</fg>".format(
            index,
            lbObj[4],
            lbObj[0],
            lbObj[3],
            iconString(Icon.BOLT),
            lbObj[4],
            lbObj[1],
            iconString(Icon.SKULL),
            lbObj[2]
        )
        createInWorldText(
            getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
            lbObjFormatted,
            lbPos[index],
            lobbyData[13],
            Clip.SURFACES,
            WorldTextReeval.VISIBILITY,
            rgb(230, 151, 0)
        )


rule "Load Start Run Area":
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        "New Run",
        lobbyData[7],
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(0, 224, 146)
    )
    createEffect(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        Effect.RING,
        Color.AQUA,
        lobbyData[5],
        1.6,
        EffectReeval.VISIBILITY
    )
    createIcon(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        lobbyData[6],
        Icon.FLAG,
        IconReeval.VISIBILITY,
        Color.GREEN,
        false
    )
    createEffect(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        Effect.SPARKLES,
        rgb(230, 151, 0),
        lobbyData[5] + vect(0, -0.85, 0),
        1.6,
        EffectReeval.VISIBILITY
    )


rule "Start Run Circle Entry":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[5]) <= 2

    eventPlayer.isInLobby = false
    eventPlayer.isLoading = true
    newRun()
    showCpNameplate()
    eventPlayer.isLoading = false


rule "Load Resume Run Area":
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        "Resume Run",
        lobbyData[10],
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(0, 224, 146)
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        Effect.RING,
        Color.GREEN,
        lobbyData[8],
        1.6,
        EffectReeval.VISIBILITY
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        lobbyData[9],
        Icon.RECYCLE,
        IconReeval.VISIBILITY,
        Color.GREEN,
        false
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        Effect.SPARKLES,
        rgb(230, 151, 0),
        lobbyData[8] + vect(0, -0.85, 0),
        1.6,
        EffectReeval.VISIBILITY
    )


rule "Resume Run Circle Entry":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isRunFinished == false
    @Condition distance(eventPlayer.getPosition(), lobbyData[8]) <= 2

    eventPlayer.isLoading = true
    eventPlayer.isInLobby = false
    cpResetPlayer()
    setCpAbilities()
    showCpNameplate()
    faceNextCp()
    eventPlayer.isLoading = false


rule "Load Stats":
    @Condition isLobbyStatsOn == true

    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Stats",
        lobbyData[14],
        lobbyData[15],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(0, 224, 146)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Elapsed Time: <fg00E092FF>{}</fg>".format(
            elapsedTimeFormatted if not isDebugOn else elapsedTime
        ),
        lobbyData[17],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "New Players: <fg00E092FF>{}</fg>".format(lobbyStats[0]),
        lobbyData[18],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Rejoins: <fg00E092FF>{}</fg>".format(lobbyStats[1]),
        lobbyData[19],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Legit Runs: <fg00E092FF>{}</fg>".format(lobbyStats[2]),
        lobbyData[20],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Total Run Time: <fg00E092FF>{}</fg>".format(lobbyStats[4]),
        lobbyData[21],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Total Mistakes: <fg00E092FF>{}</fg>".format(lobbyStats[5]),
        lobbyData[22],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Avg Run Time: <fg00E092FF>{}</fg>".format(lobbyStats[7]),
        lobbyData[23],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Avg Mistakes: <fg00E092FF>{}</fg>".format(lobbyStats[8]),
        lobbyData[24],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )


rule "Clear Unused Variables":
    lb = null
    lbPos = null
    lbObj = null
    lbObjFormatted = null
