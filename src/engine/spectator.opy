#!mainFile "../main.opy"
#!rulePrefix "Spectator"


# A hero swap spikes the server's load (one peaks around 170%), so the inputs that swap between
# Wrecking Ball and Jetpack Cat wait until a second after the player's last swap
macro canSwapHero(player):
    getTotalTimeElapsed() - player.heroSwapTime >= 1


rule "Mode Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[5] == false
    @Condition eventPlayer.isInLobby == false
    @Condition canSwapHero(eventPlayer)

    # spectating[i]: [0]isSpectating [1]whoPlayerIsSpectating [2]isInFreecam [3]isInDisconnectedFreecam [4]disconnectedFreecamCp [5]isFirstPersonSpectating [6]isTransitioningIntoFirstPerson [7]hasSpectatableTargets [8]crosshairTarget [9]crosshairTargetDelay [10]spectatorAmnt [11]queuedCamPos [12]queuedCamLookAt
    if not eventPlayer.spectating[0]:
        enableSpectator()
    else:
        disableSpectator()


rule "Load HUD":
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[1] == null
        ),
        ("\n\nSpectating"),
        HudPosition.LEFT,
        12,
        rgb(255, 70, 70),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[1] != null
        ),
        ("\n\nSpectating {}").format(localPlayer.spectating[1]),
        HudPosition.LEFT,
        12,
        rgb(255, 70, 70),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[2]
        ),
        ("Freecam On").format(localPlayer.spectating[1]),
        HudPosition.LEFT,
        13,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0] and localPlayer.spectating[3]
        ),
        ("(Disconnected)").format(localPlayer.spectating[1]),
        HudPosition.LEFT,
        14,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Spectated Player's HUD
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: localPlayer.spectating[10] > 0),
        ("\n\nSpectators: {}").format(localPlayer.spectating[10]),
        HudPosition.LEFT,
        12,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY_AND_STRING
    )


def enableSpectator():
    @Name "Enable"

    eventPlayer.isViewingRunCompletionText = false
    stopChasingVariable(eventPlayer.runTime)
    eventPlayer.isRunPaused = true
    if (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    ):
        eventPlayer.runMistakes++
    eventPlayer.spectating[0] = true
    eventPlayer.spectating[1] = null
    eventPlayer.spectating[3] = true
    eventPlayer.spectating[4] = eventPlayer.runCurrentCp
    enableFreecam()
    enableFreecamForSpectators()


macro spectatorCamPos(target):
    (
        target.getEyePosition()
        + (
            raycast(
                target.getEyePosition(),
                target.getEyePosition()
                + (vect(0, 1, 0) - target.getFacingDirection() * 5) * 1.1,
                null,
                getAllPlayers(),
                false
            ).getHitPosition()
            - target.getEyePosition()
        )
        / 1.1
    )


rule "Camera Loop":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[2] == false
    @Condition eventPlayer.spectating[3] == false
    @Condition eventPlayer.spectating[5] == false

    while (
        eventPlayer.spectating[0]
        and not eventPlayer.spectating[2]
        and not eventPlayer.spectating[3]
        and not eventPlayer.spectating[5]
    ):
        eventPlayer.startCamera(
            spectatorCamPos(eventPlayer.spectating[1]),
            eventPlayer.spectating[1].getEyePosition()
            + eventPlayer.spectating[1].getFacingDirection(),
            250
        )
        wait()


rule "Hold Queued Camera":
    @Event eachPlayer
    @Condition eventPlayer in freecamQueue
    @Condition eventPlayer.spectating[2] == false

    # While waiting in Freecam Queue, the camera stays where it was watching from
    eventPlayer.startCamera(eventPlayer.spectating[11], eventPlayer.spectating[12], 0)


def disableSpectator():
    @Name "Disable"

    eventPlayer.isLoading = true
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.setGravity(100)
    eventPlayer.setMoveSpeed(100)
    eventPlayer.stopForcingPosition()
    eventPlayer.stopCamera()
    eventPlayer.setInvisibility(Invis.NONE)
    swapToWreckingBall()
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.spectating[0] = false
    if not eventPlayer.spectating[3] and eventPlayer.spectating[1] != null:
        eventPlayer.spectating[4] = eventPlayer.spectating[1].runCurrentCp
    if eventPlayer.spectating[4] > eventPlayer.runCurrentCp:
        eventPlayer.isRunLegit = false
    eventPlayer.runCurrentCp = eventPlayer.spectating[4]
    eventPlayer.spectating[1].spectating[10]--
    eventPlayer.spectating[1] = null
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[3] = false
    loadCpData()
    if eventPlayer.isInFreemode:
        eventPlayer.nameplate = "{} | FREEMODE".format(eventPlayer)
    else:
        setCpAbilities()
        cpResetPlayer()
        showCpNameplate()
    eventPlayer.isLoading = false


macro spectatablePlayers(player):
    getAllPlayers().filter(
        lambda p: p != player and p.hasSpawned() and not p.spectating[0]
    )


rule "Track If Anyone Is Spectatable":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[7] != (len(spectatablePlayers(eventPlayer)) > 0)

    eventPlayer.spectating[7] = not eventPlayer.spectating[7]


rule "Prev. Player Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[5] == false
    @Condition len(spectatablePlayers(eventPlayer)) > 0
    # Only switching from freecam swaps hero
    @Condition (not eventPlayer.spectating[2] or canSwapHero(eventPlayer)) == true

    if not (eventPlayer.spectating[2] and eventPlayer.spectating[3]):
        eventPlayer.spectating[1].spectating[10]--
    eventPlayer.spectateTargets = spectatablePlayers(eventPlayer)
    # index() is -1 if they aren't spectatable, which starts from the first player
    eventPlayer.spectating[1] = eventPlayer.spectateTargets[
        (eventPlayer.spectateTargets.index(eventPlayer.spectating[1]) + 1)
        % len(eventPlayer.spectateTargets)
    ]
    reattachToSpectatingTarget()
    eventPlayer.spectating[1].spectating[10]++
    eventPlayer.spectating[4] = eventPlayer.spectating[1].runCurrentCp


rule "Next Player Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[5] == false
    @Condition len(spectatablePlayers(eventPlayer)) > 0
    @Condition (not eventPlayer.spectating[2] or canSwapHero(eventPlayer)) == true

    if not (eventPlayer.spectating[2] and eventPlayer.spectating[3]):
        eventPlayer.spectating[1].spectating[10]--
    eventPlayer.spectateTargets = spectatablePlayers(eventPlayer)
    if eventPlayer.spectating[1] in eventPlayer.spectateTargets:
        eventPlayer.spectating[1] = eventPlayer.spectateTargets[
            (
                eventPlayer.spectateTargets.index(eventPlayer.spectating[1])
                + len(eventPlayer.spectateTargets)
                - 1
            )
            % len(eventPlayer.spectateTargets)
        ]
    else:
        eventPlayer.spectating[1] = eventPlayer.spectateTargets[0]
    reattachToSpectatingTarget()
    eventPlayer.spectating[1].spectating[10]++
    eventPlayer.spectating[4] = eventPlayer.spectating[1].runCurrentCp


rule "Crosshair Player Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[5] == false
    @Condition len(spectatablePlayers(eventPlayer)) > 0
    @Condition canSwapHero(eventPlayer)

    eventPlayer.spectating[8] = getAllPlayers().filter(
        lambda p: p != eventPlayer
        and p.hasSpawned()
        and not p.spectating[0]
        and angleBetweenVectors(
            eventPlayer.getFacingDirection(),
            directionTowards(eventPlayer.getEyePosition(), p.getEyePosition())
        )
        < 20
    )[0]
    if eventPlayer.spectating[8] == null:
        return
    eventPlayer.isLoading = true
    eventPlayer.spectating[1].spectating[10]--
    eventPlayer.spectating[1] = eventPlayer.spectating[8]
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[3] = false
    eventPlayer.spectating[4] = eventPlayer.spectating[1].runCurrentCp
    reattachToSpectatingTarget()
    eventPlayer.spectating[1].spectating[10]++
    eventPlayer.isLoading = false
    eventPlayer.spectating[9] = true
    wait(0.2)
    eventPlayer.spectating[9] = false


rule "Enable Freecam Input":
    @Event eachPlayer
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[2] == false
    @Condition magnitude(eventPlayer.getThrottle()) > 0 or (
        eventPlayer.isHoldingButton(Button.JUMP) and not eventPlayer.spectating[9]
    )
    @Condition (
        not eventPlayer.isHoldingButton(Button.ULTIMATE)
        and not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    ) == true
    @Condition eventPlayer.spectating[5] == false
    @Condition eventPlayer.isLoading == false
    @Condition canSwapHero(eventPlayer)
    # Disconnected without freecam means waiting in Freecam Queue
    @Condition eventPlayer.spectating[3] == false

    enableFreecam()


def enableFreecam():
    @Name "Enable Freecam"

    if playerToEnableFreecam == null:
        playerToEnableFreecam = eventPlayer
    playerToEnableFreecam.disableEnvironmentCollision(true)
    playerToEnableFreecam.stopCamera()
    playerToEnableFreecam.stopForcingPosition()
    # Records the swap for canSwapHero
    if playerToEnableFreecam.getHero() != Hero.JETPACK_CAT:
        playerToEnableFreecam.heroSwapTime = getTotalTimeElapsed()
    playerToEnableFreecam.startForcingHero(Hero.JETPACK_CAT)
    if entityExists(playerToEnableFreecam.spectating[1]):
        # Starts the freecam where the spectator camera was
        freecamStartPos = spectatorCamPos(playerToEnableFreecam.spectating[1])
        playerToEnableFreecam.teleport(
            freecamStartPos
            - (
                playerToEnableFreecam.getEyePosition()
                - playerToEnableFreecam.getPosition()
            )
        )
        playerToEnableFreecam.setFacing(
            directionTowards(
                freecamStartPos,
                playerToEnableFreecam.spectating[1].getEyePosition()
                + playerToEnableFreecam.spectating[1].getFacingDirection()
            ),
            Relativity.TO_WORLD
        )
    playerToEnableFreecam.setGravity(0)
    playerToEnableFreecam.setStatusEffect(null, Status.ROOTED, 0.1)
    playerToEnableFreecam.setInvisibility(Invis.NONE)
    playerToEnableFreecam.allowButton(Button.PRIMARY_FIRE)
    playerToEnableFreecam.setPrimaryFireEnabled(true)
    playerToEnableFreecam.allowButton(Button.SECONDARY_FIRE)
    playerToEnableFreecam.setSecondaryFireEnabled(true)
    playerToEnableFreecam.allowButton(Button.CROUCH)
    playerToEnableFreecam.disallowButton(Button.ABILITY_1)
    playerToEnableFreecam.setAbility1Enabled(false)
    playerToEnableFreecam.disallowButton(Button.ABILITY_2)
    playerToEnableFreecam.setAbility2Enabled(false)
    playerToEnableFreecam.nameplate = "{} | FREECAM".format(playerToEnableFreecam)
    playerToEnableFreecam.spectating[2] = true
    playerToEnableFreecam = null


def swapToWreckingBall():
    @Name "Swap To Wrecking Ball"

    # Like the swap to Jetpack Cat in Enable Freecam
    if eventPlayer.getHero() != Hero.WRECKING_BALL:
        eventPlayer.heroSwapTime = getTotalTimeElapsed()
    eventPlayer.startForcingHero(Hero.WRECKING_BALL)


rule "Freecam Speed Boost":
    @Event eachPlayer
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.getHero() == Hero.JETPACK_CAT

    eventPlayer.setMoveSpeed(300)


rule "Freecam Boost Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[0] == true

    eventPlayer.setMoveSpeed(400)
    waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
    eventPlayer.setMoveSpeed(300)


rule "Environment Death":
    @Event playerDied
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[6] == false

    eventPlayer.resurrect()
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
    if not eventPlayer.spectating[3]:
        reattachToSpectatingTarget()


def enableFreecamForSpectators():
    @Name "Enable Freecam For Spectators"

    # For players spectating someone who enables spectator mode or leaves
    for index in range(len(getAllPlayers())):
        if getAllPlayers()[index].spectating[0] == true:
            if getAllPlayers()[index].spectating[1] == eventPlayer:
                if getAllPlayers()[index].spectating[5] == true:
                    getAllPlayers()[index].resurrect()
                    getAllPlayers()[index].spectating[5] = false
                if getAllPlayers()[index].spectating[2] == false:
                    # Its swap to Jetpack Cat waits its turn in Freecam Queue, with the camera held where it was
                    if entityExists(eventPlayer):
                        getAllPlayers()[index].spectating[11] = spectatorCamPos(eventPlayer)
                        getAllPlayers()[index].spectating[12] = (
                            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
                        )
                    else:
                        getAllPlayers()[index].spectating[11] = getAllPlayers()[
                            index
                        ].getEyePosition()
                        getAllPlayers()[index].spectating[12] = (
                            getAllPlayers()[index].getEyePosition()
                            + getAllPlayers()[index].getFacingDirection()
                        )
                    getAllPlayers()[index].stopForcingPosition()
                    getAllPlayers()[index].setGravity(0)
                    freecamQueue.append(getAllPlayers()[index])
                getAllPlayers()[index].spectating[1] = null
                getAllPlayers()[index].spectating[3] = true
                eventPlayer.spectating[10]--


rule "Freecam Queue":
    # Enable Freecam only falls back to the event player when playerToEnableFreecam isn't set, which it always is here
    @SuppressWarnings w_mismatched_subroutine_event
    @Condition len(freecamQueue) > 0

    # One hero swap every 0.1s, since a hero swap spikes the server's load and several watchers can lose their
    # target at once. Skips anyone who left, left spectator mode or started watching someone else meanwhile.
    if (
        entityExists(freecamQueue[0])
        and freecamQueue[0].spectating[0]
        and freecamQueue[0].spectating[3]
        and not freecamQueue[0].spectating[2]
    ):
        playerToEnableFreecam = freecamQueue[0]
        enableFreecam()
        # Starts the freecam where its camera was held
        freecamQueue[0].teleport(
            freecamQueue[0].spectating[11]
            - (freecamQueue[0].getEyePosition() - freecamQueue[0].getPosition())
        )
        freecamQueue[0].setFacing(
            directionTowards(freecamQueue[0].spectating[11], freecamQueue[0].spectating[12]),
            Relativity.TO_WORLD
        )
    freecamQueue = freecamQueue.slice(1, len(freecamQueue))
    wait(0.1)
    if RULE_CONDITION:
        loop()


def syncSpectatorCps():
    @Name "Sync Spectators' Checkpoint"

    # For players spectating someone whose checkpoint changed
    getAllPlayers().filter(
        lambda p: p.spectating[1] == eventPlayer and not p.spectating[3]
    ).spectating[4] = eventPlayer.runCurrentCp


rule "Reattach Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[1] != null
    @Condition eventPlayer.spectating[2] == true
    @Condition eventPlayer.spectating[5] == false
    @Condition canSwapHero(eventPlayer)

    reattachToSpectatingTarget()


def reattachToSpectatingTarget():
    @Name "Reattach"

    eventPlayer.applyImpulse(
        eventPlayer.getVelocity() * -0.001,
        0.001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    # Watching someone as Jetpack Cat would play its sounds at their position
    swapToWreckingBall()
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
    eventPlayer.startCamera(
        spectatorCamPos(eventPlayer.spectating[1]),
        eventPlayer.spectating[1].getEyePosition()
        + eventPlayer.spectating[1].getFacingDirection(),
        500
    )
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.nameplate = ""
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[3] = false


rule "Enable First Person Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == true
    @Condition eventPlayer.spectating[1] != null
    @Condition eventPlayer.spectating[5] == false

    waitUntil(
        not eventPlayer.isHoldingButton(Button.INTERACT)
        and not eventPlayer.isHoldingButton(Button.ABILITY_1),
        Math.INFINITY
    )
    enableFirstPersonSpectator()


def enableFirstPersonSpectator():
    @Name "Enable First Person"
    @SuppressWarnings w_chase_9999

    eventPlayer.setRespawnTime(Math.INFINITY)
    eventPlayer.spectating[6] = true
    kill(eventPlayer)
    eventPlayer.firstPersonSpectatingTime = 0
    chaseAtRate(eventPlayer.firstPersonSpectatingTime, 9999, 1)
    wait()
    eventPlayer.spectating[6] = false
    eventPlayer.spectating[5] = true
    eventPlayer.enableDeathSpectateTargetHud()
    eventPlayer.startCamera(
        spectatorCamPos(eventPlayer.spectating[1]),
        eventPlayer.spectating[1].getEyePosition()
        + eventPlayer.spectating[1].getFacingDirection(),
        500
    )
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[3] = false
    waitUntil(
        not eventPlayer.isHoldingButton(Button.INTERACT)
        and not eventPlayer.isHoldingButton(Button.ABILITY_1),
        1
    )
    for eventPlayer.index in range(1, 4):
        bigMessage(
            eventPlayer,
            (
                "{0}<fgE62400FF>HEADS UP</fg>{0}\n"
                "<fgFFD700FF>Hold {1} to exit!</fg>\n"
                "<fgFFFFFFFF>- - - - - - - - - - - - - - - - -</fg>\n"
                "<fgE69700FF>Press {2} to change perspective</fg>"
            ).format(
                iconString(Icon.WARNING),
                inputBindingString(Button.ULTIMATE),
                inputBindingString(Button.JUMP)
            )
        )
        wait(3, Wait.RESTART_WHEN_TRUE)
        if eventPlayer.spectating[5] == false:
            return


rule "First Person Expires":
    @Event eachPlayer
    @Condition eventPlayer.firstPersonSpectatingTime == 9999
    @Condition eventPlayer.spectating[5] == true
    @SuppressWarnings w_ow2_rule_condition_chase

    eventPlayer.resurrect()
    reattachToSpectatingTarget()
    enableFirstPersonSpectator()


rule "Disable First Person Input":
    @Event eachPlayer
    @Condition (
        eventPlayer.isHoldingButton(Button.ULTIMATE)
        or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
        or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.isHoldingButton(Button.RELOAD)
        or eventPlayer.isHoldingButton(Button.INTERACT)
        or eventPlayer.isHoldingButton(Button.CROUCH)
        or eventPlayer.isHoldingButton(Button.ABILITY_1)
        or eventPlayer.isHoldingButton(Button.ABILITY_2)
        or eventPlayer.isCommunicatingAnything()
    ) == true
    @Condition eventPlayer.spectating[5] == true
    @Condition eventPlayer.spectating[0] == true

    # Exits once something has been held for 0.25s
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.disableDeathSpectateTargetHud()
    eventPlayer.resurrect()
    reattachToSpectatingTarget()
    eventPlayer.spectating[5] = false
