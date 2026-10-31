#!mainFile "../main.opy"
#!rulePrefix "Mistake"


rule "Missed Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.isInFreemode == false
    @Condition (
        eventPlayer.cpData[5] == null
        or (not eventPlayer.cpData[12] and not eventPlayer.cpData[13])
        or (
            eventPlayer.cpData[16]
            and distance(
                vect(
                    eventPlayer.getPosition().x,
                    eventPlayer.cpData[5].y,
                    eventPlayer.getPosition().z
                ),
                eventPlayer.cpData[5]
            )
            > eventPlayer.cpData[6]
        )
    ) == true
    @Condition (
        eventPlayer.isOnGround() or eventPlayer.cpData[9] and eventPlayer.cpData[11]
    ) == true
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[7])
        > eventPlayer.cpData[8]
    )
    @Condition eventPlayer.isDummy() == false

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    if eventPlayer.isRunPaused:
        eventPlayer.isRunPaused = false
        chaseAtRate(eventPlayer.runTime, Math.INFINITY, 1)
    eventPlayer.isLoading = false


rule "Already Bhopped":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.cpData[11] == true
    @Condition eventPlayer.cpData[5] == null
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[7])
        > eventPlayer.cpData[8]
    )

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "Environment Death":
    @Event playerDied
    @Condition (
        eventPlayer.isHoldingButton(Button.ULTIMATE)
        and eventPlayer.isHoldingButton(Button.ABILITY_1)
    ) == false
    @Condition eventPlayer.spectating[0] == false

    eventPlayer.isLoading = true
    if not eventPlayer.isInLobby:
        if not eventPlayer.isInFreemode and not eventPlayer.spectating[0]:
            cpResetPlayer()
            addMistake()
        else:
            eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
        eventPlayer.resurrect()
    else:
        eventPlayer.resurrect()
        loadLobby()
    eventPlayer.isLoading = false
