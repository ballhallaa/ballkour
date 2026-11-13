#!mainFile "../main.opy"
#!rulePrefix "Mistake"


rule "Missed Checkpoint":
    @Event eachPlayer
    @Condition isFreePlay(eventPlayer) == false
    # An orb checkpoint allows the ground from its grapple until every orb is grabbed, and
    # after a last orb grabbed on the ground, until the ball leaves it (cpData[17])
    @Condition (
        eventPlayer.cpData[5] == null
        or (not eventPlayer.cpData[12] and not eventPlayer.cpData[13])
        or hasAllOrbs(eventPlayer)
        and not eventPlayer.cpData[17]
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
    # Practice Mode's run stays paused
    if eventPlayer.isRunPaused and not eventPlayer.isInPracticeMode:
        # Like Timer: Start/Resume Run, when the player lands outside a CP skipped to as they
        # leave it, before that rule runs
        if isOnSkippedCp(eventPlayer):
            eventPlayer.isRunLegit = false
        eventPlayer.isRunPaused = false
        chaseAtRate(eventPlayer.runTime, Math.INFINITY, 1)
    eventPlayer.isLoading = false


# Assist Mode's stand-in for Missed Checkpoint: instead of a mistake and a reset, the time on
# the ground in the same spots counts up. Assist Mode doesn't track the grapple (cpData[12],
# cpData[13]), so an orb checkpoint's ground counts as its route until every orb is grabbed.
rule "Ground Time":
    @Event eachPlayer
    @Condition eventPlayer.isInAssistMode == true
    @Condition (
        eventPlayer.isRunPaused or eventPlayer.isInFreemode or eventPlayer.isRunFinished
    ) == false
    @Condition eventPlayer.runCurrentCp < lastCp
    @Condition (
        eventPlayer.cpData[5] == null
        or hasAllOrbs(eventPlayer)
        and not eventPlayer.cpData[17]
    ) == true
    @Condition eventPlayer.isOnGround() == true
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

    # Rechecks every tick while it counts: a Wait Until on the rule's conditions would spell
    # them all out again
    chaseAtRate(eventPlayer.runGroundTime, Math.INFINITY, 1)
    wait()
    if RULE_CONDITION:
        loop()
    stopChasingVariable(eventPlayer.runGroundTime)


rule "Already Bhopped":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition isFreePlay(eventPlayer) == false
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
