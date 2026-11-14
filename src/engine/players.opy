#!mainFile "../main.opy"
#!rulePrefix "Player"


rule "Joins":
    @Event playerJoined
    @Condition eventPlayer.isDummy() == false

    eventPlayer.isLoading = true
    # They're on the scorecard before their first run (Update Scorecard), with a 0 time and
    # no ×, like a new run's
    eventPlayer.runTimeFormatted = "0.00"
    eventPlayer.runGroundTimeFormatted = "0.00"
    eventPlayer.isRunLegit = true
    # Every HUD line on, filled out to HUD_LINES, as an index past an array's end fills the
    # rest with zeros
    eventPlayer.hudHidden[HUD_LINES - 1] = false
    if isLobbyStatsOn:
        if not "{}".format(eventPlayer) in players:
            if eventPlayer == hostPlayer:
                hostPlayerName = "{}".format(eventPlayer)
            lobbyStats[0]++
            players[len(players)] = "{}".format(eventPlayer)
        else:
            lobbyStats[1]++
    waitUntil(eventPlayer.hasSpawned(), Math.INFINITY)
    # Their game's language, for the translations (#!translateWithPlayerVar): their client
    # turns them 10° per language, by its name for Ilios Ruins, and the server reads it back
    eventPlayer.startFacing(
        directionFromAngles(
            10
            * __overpyTranslationHelper__.index(
                updateEveryFrame(Map.ILIOS_RUINS).split([])
            ),
            5
        ),
        Math.INFINITY,
        Relativity.TO_WORLD,
        FacingReeval.DIRECTION_AND_TURN_RATE
    )
    # To within 1/100 of a degree, for precision errors
    waitUntil(
        not (round(eventPlayer.getHorizontalFacingAngle() * 100) % 1000)
        and abs(eventPlayer.getVerticalFacingAngle() - 5) < 0.01,
        15
    )
    # 0 is English, which a language it can't tell gets too
    eventPlayer.__languageIndex__ = (
        max(
            1,
            (abs(eventPlayer.getVerticalFacingAngle() - 5) < 0.01)
            * round(eventPlayer.getHorizontalFacingAngle() / 10)
        )
        - 1
    )
    eventPlayer.stopFacing()
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableKillFeed()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disablePlayerCollision()
    eventPlayer.setDamageDealt(false)
    eventPlayer.disableNameplatesFor(getAllPlayers())
    getAllPlayers().disableNameplatesFor(eventPlayer)
    if nameplateObjs[eventPlayer.getSlot()] != null:
        destroyInWorldText(nameplateObjs[eventPlayer.getSlot()])
    if tinyNameplateObjs[eventPlayer.getSlot()] != null:
        destroyInWorldText(tinyNameplateObjs[eventPlayer.getSlot()])
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer != eventPlayer and not eventPlayer.isTiny
        ),
        _(eventPlayer.nameplate),
        eventPlayer,
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING
    )
    nameplateObjs[eventPlayer.getSlot()] = getLastCreatedText()
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer != eventPlayer and eventPlayer.isTiny
        ),
        _(eventPlayer.nameplate),
        eventPlayer,
        0.5,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING
    )
    tinyNameplateObjs[eventPlayer.getSlot()] = getLastCreatedText()
    wait()
    loadLobby()
    while (
        angleBetweenVectors(
            eventPlayer.getFacingDirection(),
            directionTowards(eventPlayer.getEyePosition(), lobbyPos[0])
        )
        > 1
    ):
        eventPlayer.setFacing(
            directionTowards(eventPlayer.getEyePosition(), lobbyPos[0]),
            Relativity.TO_WORLD
        )
        wait()
    eventPlayer.isLoading = false


def showCpNameplate():
    @Name "Show Checkpoint On Nameplate"

    # Freemode keeps its tag through anything that moves the player between CPs
    if eventPlayer.isInFreemode:
        eventPlayer.nameplate = _("{} | FREEMODE").format(eventPlayer)
    else:
        eventPlayer.nameplate = _("{} | {}").format(
            eventPlayer, eventPlayer.runCurrentCp
        )


rule "Leaves":
    @Event playerLeft

    enableFreecamForSpectators()
    for index in range(len(getAllPlayers())):
        getAllPlayers()[index].spectating[10] = len(
            getAllPlayers().filter(
                lambda p: p.spectating[0] and p.spectating[1] == getAllPlayers()[index]
            )
        )
    # Their nameplates go with them: Joins only replaces a slot's when someone new takes it,
    # so they'd hold 2 of the server's 128 texts until then. The player who left can't be
    # read anymore, so it's every slot left empty.
    for index in range(getNumberOfSlots(PLAYER_TEAM)):
        if (
            nameplateObjs[index] != null
            and getPlayersInSlot(index, PLAYER_TEAM) == null
        ):
            destroyInWorldText(nameplateObjs[index])
            destroyInWorldText(tinyNameplateObjs[index])
            nameplateObjs[index] = null
            tinyNameplateObjs[index] = null
    # Drops the run info they had open
    showRunInfo()
    # Their row comes off the scorecard
    scorecardDirty = true


rule "Turn Inactive Players Tiny":
    @Event eachPlayer
    # Their input rather than their speed, which an idle ball rarely holds at exactly 0: it
    # drifts on slopes, and drifting off its checkpoint resets it there (Mistake: Missed
    # Checkpoint), which started the 60 seconds over each time
    @Condition eventPlayer.getThrottle() == vect(0, 0, 0)
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.spectating[0] == false
    @Condition eventPlayer.isDummy() == false

    wait(60, Wait.ABORT_WHEN_FALSE)
    eventPlayer.isTiny = true
    eventPlayer.startScalingSize(0.1, false)
    waitUntil(
        eventPlayer.getThrottle() != vect(0, 0, 0)
        or eventPlayer.isHoldingButton(Button.JUMP)
        or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
        or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.isHoldingButton(Button.ABILITY_1)
        or eventPlayer.isHoldingButton(Button.ABILITY_2)
        or eventPlayer.spectating[0]
        or eventPlayer.isInLobby,
        Math.INFINITY
    )
    eventPlayer.isTiny = false
    eventPlayer.stopScalingSize()
    if RULE_CONDITION:
        loop()
