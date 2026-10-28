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
    recordSplit()
    if isHintRecorderOn and eventPlayer == hostPlayer:
        saveHintRoute()
    resetCpMistakes()
    eventPlayer.isLoading = true
    eventPlayer.runCurrentCp++
    syncSpectatorCps()
    showCpNameplate()
    loadCpData()
    setCpAbilities()
    if eventPlayer.runCurrentCp < lastCp:
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
    @Condition eventPlayer.runCurrentCp == lastCp

    playEffect(
        eventPlayer, DynamicEffect.BAD_PICKUP_EFFECT, Color.GREEN, eventPlayer, 200
    )
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
    if eventPlayer.spectating[0]:
        return
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if eventPlayer.isRunLegit:
            if isLobbyStatsOn:
                updateStats()
    if not eventPlayer.isRunFinished:
        eventPlayer.isRunFinished = true
        eventPlayer.runFinalTimeFormatted = eventPlayer.runTimeFormatted
        eventPlayer.runFinalMistakes = eventPlayer.runMistakes
        eventPlayer.isViewingRunCompletionText = true
    eventPlayer.isInFreemode = true
    eventPlayer.nameplate = _("{} | FREEMODE").format(eventPlayer)


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
        _("\n\nCongrats, {}!\n").format(localPlayer),
        HudPosition.TOP,
        2,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        _("Time: {}").format(localPlayer.runFinalTimeFormatted),
        HudPosition.TOP,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        _("Time to Beat: {}").format(timeToBeatFormatted),
        HudPosition.TOP,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
        ),
        _("Mistakes: {}\n").format(localPlayer.runFinalMistakes),
        HudPosition.TOP,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Lines start with a color tag and then their centering spaces: OverPy adds a line's
    # leading spaces to every translation, but spaces after the tag are the translation's own
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.runTime > timeToBeat
            and timeToBeat > 0
            and localPlayer.isRunLegit
        ),
        _(
            "<fgFF4646FF>Submit a Video of Your Run</fg>\n"
            "<fgFF4646FF>                        @</fg>\n"
            "<fgFF4646FF>              ballkour.com</fg>\n\n"
            "<fg00E092FF>       Thanks for Playing!</fg>"
        ),
        HudPosition.TOP,
        6,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and (timeToBeat == 0 or localPlayer.runTime <= timeToBeat)
            and localPlayer.isRunLegit
        ),
        _(
            "<fgE69700FF>                Top-10 Time!</fg>\n"
            "<fgFF4646FF>Submit a Video of Your Run</fg>\n"
            "<fgFF4646FF>                        @</fg>\n"
            "<fgFF4646FF>              ballkour.com</fg>\n\n"
            "<fg00E092FF>       Thanks for Playing!</fg>"
        ),
        HudPosition.TOP,
        6,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and not localPlayer.isRunLegit
        ),
        _(
            "<fgFF4646FF>             Run Not Counted\n"
            "Skipped CPs or Used Freemode</fg>\n\n"
            "<fg00E092FF>         Thanks for Playing!</fg>"
        ),
        HudPosition.TOP,
        6,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING
    )


def updateStats():
    @Name "Update Lobby Stats"

    # Wrapped so release builds leave the subroutine out entirely
    if DEV:
        lobbyStats[2]++
        lobbyStats[3] += eventPlayer.runTime
        eventPlayer.timeToFormat = lobbyStats[3]
        formatTime()
        lobbyStats[4] = eventPlayer.timeFormatted
        lobbyStats[5] += eventPlayer.runMistakes
        lobbyStats[6] = lobbyStats[3] / lobbyStats[2]
        eventPlayer.timeToFormat = lobbyStats[6]
        formatTime()
        lobbyStats[7] = eventPlayer.timeFormatted
        lobbyStats[8] = lobbyStats[5] / lobbyStats[2]
