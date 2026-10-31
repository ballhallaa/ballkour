#!mainFile "../main.opy"
#!rulePrefix "Bounce Checkpoint"


rule "No Grapple":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[12] == false
    @Condition eventPlayer.cpData[13] == false
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "Too Slow":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[13] == true
    @Condition (
        not eventPlayer.cpData[16]
        or (
            eventPlayer.cpData[16]
            and eventPlayer.isOnGround()
            and distance(
                vect(
                    eventPlayer.getPosition().x,
                    eventPlayer.cpData[5].y,
                    eventPlayer.getPosition().z
                ),
                eventPlayer.cpData[5]
            )
            <= eventPlayer.cpData[6]
        )
    ) == true
    @Condition eventPlayer.getSpeed() <= 10
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false


rule "Bounce Used Properly":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(
            vect(
                eventPlayer.getPosition().x,
                eventPlayer.cpData[5].y,
                eventPlayer.getPosition().z
            ),
            eventPlayer.cpData[5]
        )
        <= eventPlayer.cpData[6]
    )

    eventPlayer.cpData[16] = true


rule "Improperly Airborne":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.cpData[5] != null
    @Condition eventPlayer.cpData[16] == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )
    @Condition (
        distance(
            vect(
                eventPlayer.getPosition().x,
                eventPlayer.cpData[5].y,
                eventPlayer.getPosition().z
            ),
            eventPlayer.cpData[5]
        )
        > eventPlayer.cpData[6]
    )

    eventPlayer.isLoading = true
    addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false
