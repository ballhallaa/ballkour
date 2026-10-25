#!mainFile "../main.opy"
#!rulePrefix "Completion"


rule "Checkpoint (No Skipping)":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == false
    @Condition (
        eventPlayer.isOnGround()
        or eventPlayer.cpData[9]
        or eventPlayer.getAltitude() <= 0.02
        and not eventPlayer.cpData[15]
    ) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[7])
        <= eventPlayer.cpData[8]
    )

    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.timeToFormat = eventPlayer.cpTime
    formatTime()
    eventPlayer.cpTimeFormatted = eventPlayer.timeFormatted
    eventPlayer.timeToFormat = eventPlayer.runTime - eventPlayer.cpStartTime
    formatTime()
    eventPlayer.cpTotalTimeFormatted = eventPlayer.timeFormatted
    smallMessage(
        eventPlayer,
        "Time: {} | Total: {}".format(
            eventPlayer.cpTimeFormatted, eventPlayer.cpTotalTimeFormatted
        )
    )
    if settings_[2] and eventPlayer == hostPlayer:
        saveHintRoute()
    eventPlayer.isLoading = true
    eventPlayer.runCurrentCp++
    for eventPlayer.index in range(len(getAllPlayers())):
        if (
            getAllPlayers()[eventPlayer.index].spectating[1] == eventPlayer
            and getAllPlayers()[eventPlayer.index].spectating[3] == false
        ):
            getAllPlayers()[eventPlayer.index].spectating[4]++
            smallMessage(
                getAllPlayers()[eventPlayer.index],
                "Time: {} | Total: {}".format(
                    eventPlayer.cpTimeFormatted, eventPlayer.cpTotalTimeFormatted
                )
            )
    eventPlayer.nameplate = "{} | {}".format(eventPlayer, eventPlayer.runCurrentCp)
    loadCpData()
    setCpAbilities()
    if eventPlayer.runCurrentCp < len(cps) - 1:
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            eventPlayer.isLoading = true
            eventPlayer.teleport(eventPlayer.cpData[0])
            eventPlayer.applyImpulse(
                eventPlayer.getVelocity() * -0.001,
                0.001,
                Relativity.TO_WORLD,
                Impulse.CANCEL_CONTRARY_MOTION_XYZ
            )
            eventPlayer.isLoading = false
        playEffect(
            eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 100
        )
    eventPlayer.isLoading = false


rule "Final Checkpoint Reached":
    @Event eachPlayer
    @Condition eventPlayer.runCurrentCp == len(cps) - 1

    playEffect(
        eventPlayer, 
        DynamicEffect.BAD_PICKUP_EFFECT, 
        Color.GREEN, 
        eventPlayer, 
        200
    )
    playEffect(
        eventPlayer, 
        DynamicEffect.BUFF_IMPACT_SOUND,
        null, 
        eventPlayer, 
        100
    )
    if eventPlayer.spectating[0]:
        return
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if eventPlayer.isRunLegit:
            if settings_[1]:
                updateStats()
    if not eventPlayer.isRunFinished:
        eventPlayer.isRunFinished = true
        eventPlayer.runFinalTimeFormatted = eventPlayer.runTimeFormatted
        eventPlayer.runFinalMistakes = eventPlayer.runMistakes
        eventPlayer.isViewingRunCompletionText = true
    eventPlayer.isInFreemode = true
    eventPlayer.nameplate = "{} | FREEMODE".format(eventPlayer)


rule "Load Run Text":
    @Event eachPlayer
    @Condition eventPlayer.isViewingRunCompletionText == true

    wait(30)
    eventPlayer.isViewingRunCompletionText = false


rule "Run Text":
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        "\n\nCongrats, {}!\n".format(localPlayer),
        HudPosition.TOP,
        2,
        Color.TURQUOISE,
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        "Time: {}".format(localPlayer.runFinalTimeFormatted),
        HudPosition.TOP,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        "Time to Beat: {}".format(
            "00:00.00"
            if timeToBeatInMs == 0
            else (
                "{}:{}:{}".format(
                    floor(timeToBeatInMs / 3600000),
                    (timeToBeatInMs % 3600000 / 60000 + 100).substring(1, 2),
                    (timeToBeatInMs % 60000 / 1000 + 100).substring(1, 9999)
                )
                if timeToBeatInMs >= 3600000
                else (
                    "{}:{}".format(
                        floor(timeToBeatInMs / 60000),
                        (timeToBeatInMs % 60000 / 1000 + 100).substring(1, 9999)
                    )
                    if timeToBeatInMs >= 60000
                    else "{}.{}".format(
                        floor(timeToBeatInMs / 1000),
                        (timeToBeatInMs % 1000 / 10 + 100).substring(1, 2)
                    )
                )
            )
        ),
        HudPosition.TOP,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        "Mistakes: {}\n".format(localPlayer.runFinalMistakes),
        HudPosition.TOP,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.runTime * 1000 > timeToBeatInMs
            and timeToBeatInMs > 0
            and localPlayer.isRunLegit
        ),
        "<fgA52A2AFF>Submit a Video of Your Run\n"
        "                        @\n"
        "              ballkour.com</fg>\n\n"
        "       <fg00E697FF>Thanks for Playing!</fg>",
        HudPosition.TOP,
        6,
        Color.WHITE,
        HudReeval.VISIBILITY
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and (timeToBeatInMs == 0 or localPlayer.runTime * 1000 <= timeToBeatInMs)
            and localPlayer.isRunLegit
        ),
        "                Top-10 Time!</fg>\n"
        "<fgEC2300FF>Submit a Video of Your Run\n"
        "                        @\n"
        "              ballkour.com</fg>\n\n"
        "       <fg00E697FF>Thanks for Playing!</fg>",
        HudPosition.TOP,
        6,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and not localPlayer.isRunLegit
        ),
        "             <fgA52A2AFF>Run Not Counted\n"
        "Skipped CPs or Used Freemode</fg>\n\n"
        "         <fg00E697FF>Thanks for Playing!</fg>",
        HudPosition.TOP,
        6,
        Color.WHITE,
        HudReeval.VISIBILITY
    )


def updateStats():
    @Name "Update Lobby Stats"

    lobbyStats[2]++
    lobbyStats[3] += eventPlayer.runTime
    lobbyStats[4] = (
        "{}:{}:{}".format(
            floor(lobbyStats[3] / 3600),
            (lobbyStats[3] % 3600 / 60 + 100).substring(1, 2),
            (lobbyStats[3] % 60 + 100).substring(1, 9999)
        )
        if lobbyStats[3] >= 3600
        else (
            "{}:{}".format(
                floor(lobbyStats[3] / 60), (lobbyStats[3] % 60 + 100).substring(1, 9999)
            )
            if lobbyStats[3] >= 60
            else "{}.{}".format(
                floor(lobbyStats[3]),
                (round(lobbyStats[3] % 1 * 100) + 100).substring(1, 2)
            )
        )
    )
    lobbyStats[5] += eventPlayer.runMistakes
    lobbyStats[6] = lobbyStats[3] / lobbyStats[2]
    lobbyStats[7] = (
        "{}:{}:{}".format(
            floor(lobbyStats[6] / 3600),
            (lobbyStats[6] % 3600 / 60 + 100).substring(1, 2),
            (lobbyStats[6] % 60 + 100).substring(1, 9999)
        )
        if lobbyStats[6] >= 3600
        else (
            "{}:{}".format(
                floor(lobbyStats[6] / 60), (lobbyStats[6] % 60 + 100).substring(1, 9999)
            )
            if lobbyStats[6] >= 60
            else "{}.{}".format(
                floor(lobbyStats[6]),
                (round(lobbyStats[6] % 1 * 100) + 100).substring(1, 2)
            )
        )
    )
    lobbyStats[8] = lobbyStats[5] / lobbyStats[2]
