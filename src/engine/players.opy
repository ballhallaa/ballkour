#!mainFile "../main.opy"
#!rulePrefix "Player"


rule "Joins":
    @Event playerJoined
    @Condition eventPlayer.isDummy() == false

    eventPlayer.isLoading = true
    if isLobbyStatsOn:
        if not "{}".format(eventPlayer) in players:
            if eventPlayer == hostPlayer:
                hostPlayerName = "{}".format(eventPlayer)
            lobbyStats[0]++
            players[len(players)] = "{}".format(eventPlayer)
        else:
            lobbyStats[1]++
    waitUntil(eventPlayer.hasSpawned(), Math.INFINITY)
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
            directionTowards(eventPlayer.getEyePosition(), lobbyData[1])
        )
        > 1
    ):
        eventPlayer.setFacing(
            directionTowards(eventPlayer.getEyePosition(), lobbyData[1]),
            Relativity.TO_WORLD
        )
        wait()
    eventPlayer.isLoading = false


def showCpNameplate():
    @Name "Show Checkpoint On Nameplate"

    eventPlayer.nameplate = _("{} | {}").format(eventPlayer, eventPlayer.runCurrentCp)


rule "Leaves":
    @Event playerLeft

    enableFreecamForSpectators()
    for index in range(len(getAllPlayers())):
        getAllPlayers()[index].spectating[10] = len(
            getAllPlayers().filter(
                lambda p: p.spectating[0] and p.spectating[1] == getAllPlayers()[index]
            )
        )


rule "Turn Inactive Players Tiny":
    @Event eachPlayer
    @Condition eventPlayer.getSpeed() == 0
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.spectating[0] == false
    @Condition eventPlayer.isDummy() == false

    wait(60, Wait.ABORT_WHEN_FALSE)
    eventPlayer.isTiny = true
    eventPlayer.startScalingSize(0.1, false)
    waitUntil(
        eventPlayer.getSpeed() > 0
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
