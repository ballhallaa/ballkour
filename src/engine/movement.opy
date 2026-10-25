#!mainFile "../main.opy"
#!rulePrefix "Movement"


rule "Jumping":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.spectating[0] == false

    eventPlayer.cpData[9] = true
    eventPlayer.cpData[10] = true
    waitUntil(eventPlayer.isOnGround(), 0.016)
    eventPlayer.cpData[9] = false


rule "Bhopping":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isJumping() == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isInLobby == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[7])
        > eventPlayer.cpData[8]
    )

    if not eventPlayer.cpData[11]:
        waitUntil(eventPlayer.isOnGround(), Math.INFINITY)
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            eventPlayer.cpData[11] = true


rule "Grapple Use":
    @Event eachPlayer
    @Condition eventPlayer.isFiringSecondaryFire() == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.spectating[0] == false

    if not (
        eventPlayer.isInLobby
        or eventPlayer.cpData[5] == null
        or eventPlayer.isInFreemode
    ):
        eventPlayer.cpData[12] = true
        waitUntil(
            not eventPlayer.isFiringSecondaryFire() or eventPlayer.getSpeed() >= 15,
            Math.INFINITY
        )
        if eventPlayer.getSpeed() >= 15:
            waitUntil(not eventPlayer.isFiringSecondaryFire(), 8.5)
        eventPlayer.cpData[12] = false
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            eventPlayer.cpData[13] = true
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    elif not eventPlayer.isInLobby and not eventPlayer.isInFreemode:
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    if (
        not eventPlayer.isInLobby
        and eventPlayer.cpData[5] != null
        and not eventPlayer.isInFreemode
    ):
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            eventPlayer.setSecondaryFireEnabled(false)
        else:
            eventPlayer.cpData[13] = false
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    elif eventPlayer.isInLobby or eventPlayer.isInFreemode:
        waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)


rule "Shield Bounce Use":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition (
        (eventPlayer.isInLobby or eventPlayer.isInFreemode)
        or (eventPlayer.cpData[3] and not eventPlayer.cpData[14])
    ) == true

    eventPlayer.applyImpulse(
        Vector.UP,
        (
            (10 - 1.25 * max(0, eventPlayer.getSpeed() - 10))
            if eventPlayer.getSpeed() < 18
            else 0
        ),
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    eventPlayer.applyImpulse(
        normalize(vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)),
        min(
            distance(
                vect(0, 0, 0),
                vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)
            ),
            10
        )
        * 0.5
        + max(
            0,
            min(
                distance(
                    vect(0, 0, 0),
                    vect(eventPlayer.getVelocity().x, 0, eventPlayer.getVelocity().z)
                ),
                20
            )
            - 10
        )
        * 0.2,
        Relativity.TO_WORLD,
        Impulse.INCORPORATE_CONTRARY_MOTION
    )
    eventPlayer.setHealth(575)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
    if eventPlayer.isInLobby or eventPlayer.isInFreemode:
        eventPlayer.setAbility2Enabled(true)
    elif eventPlayer.cpData[3] and not eventPlayer.cpData[14]:
        eventPlayer.cpData[14] = true
        eventPlayer.setAbility2Enabled(false)


rule "Piledriving":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.spectating[0] == false

    eventPlayer.cpData[15] = true
    waitUntil(eventPlayer.isOnGround(), Math.INFINITY)
    eventPlayer.cpData[15] = false


rule "Reset Useless Jump/Grapple/Shield Bounce/Bhop":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition (
        eventPlayer.cpData[10]
        or eventPlayer.cpData[11]
        or eventPlayer.cpData[13]
        or eventPlayer.cpData[14]
    ) == true
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.isOnGround() or eventPlayer.cpData[9]) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        <= eventPlayer.cpData[1]
    )

    if eventPlayer.cpData[2]:
        eventPlayer.cpData[13] = false
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.cpData[10] = false
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[16] = false
    wait()
    if eventPlayer.cpData[3]:
        eventPlayer.cpData[14] = false
        if not eventPlayer.isHoldingButton(Button.ABILITY_2):
            eventPlayer.setAbility2Enabled(true)
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
