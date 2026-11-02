#!mainFile "../main.opy"
#!rulePrefix "Spectator"


# A hero swap spikes the server's load, and two close together spike it even more (toggling
# out right after toggling in read 152-220%), so the inputs that swap between Wrecking Ball
# and Jetpack Cat wait until 2 seconds after the player's last swap
macro SWAP_COOLDOWN = 2


macro canSwapHero(player):
    getTotalTimeElapsed() - player.heroSwapTime >= SWAP_COOLDOWN


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
    @Condition eventPlayer.qaPage == 0

    # A press during the cooldown only says how long is left, so it needs pressing again
    if not canSwapHero(eventPlayer):
        # Stored first: worked out inside the translated message, it read over 2s too high
        eventPlayer.swapCooldownLeft = (
            ceil(
                (SWAP_COOLDOWN - (getTotalTimeElapsed() - eventPlayer.heroSwapTime))
                * 10
            )
            / 10
        )
        smallMessage(
            eventPlayer,
            _("SPECTATOR COOLDOWN: {}s").format(eventPlayer.swapCooldownLeft)
        )
        return
    # spectating[i]: [0]isSpectating [1]whoPlayerIsSpectating [2]isInFreecam [3]isInDisconnectedFreecam [4]disconnectedFreecamCp [5]isFirstPersonSpectating [6]isTransitioningIntoFirstPerson [7]hasSpectatableTargets [8]crosshairTarget [9]crosshairTargetDelay [10]spectatorAmnt [11]queuedCamPos [12]queuedCamLookAt
    if not eventPlayer.spectating[0]:
        enableSpectator()
    else:
        disableSpectator()


rule "Load HUD":
    spectatorHudText[0] = _("\nSpectating")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[1] == null
            and localPlayer.qaPage == 0
        ),
        _(spectatorHudText[0]),
        HudPosition.LEFT,
        12,
        rgb(255, 70, 70),
        HudReeval.VISIBILITY_AND_STRING
    )
    spectatorHudText[1] = _("\nSpectating @0")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[1] != null
            and localPlayer.qaPage == 0
        ),
        _(spectatorHudText[1]).replace("@0", localPlayer.spectating[1]),
        HudPosition.LEFT,
        12,
        rgb(255, 70, 70),
        HudReeval.VISIBILITY_AND_STRING
    )
    spectatorHudText[2] = _("Freecam On")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[2]
            and localPlayer.qaPage == 0
        ),
        _(spectatorHudText[2]),
        HudPosition.LEFT,
        13,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    spectatorHudText[3] = _("(Disconnected)")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and localPlayer.qaPage == 0
        ),
        _(spectatorHudText[3]),
        HudPosition.LEFT,
        14,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Spectated Player's HUD
    spectatorHudText[4] = _("\nSpectators: @0")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[10] > 0
            and localPlayer.qaPage == 0
        ),
        _(spectatorHudText[4]).replace("@0", localPlayer.spectating[10]),
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
    # Loading keeps mistakes from counting while the swap finishes
    eventPlayer.isLoading = true
    swapToJetpackCat()
    # Being away from the checkpoint is no mistake in the lobby. Disable drops the player at a
    # checkpoint, so without a run to resume they get a new one. Freecam starts at it too,
    # instead of up in the lobby's sky.
    if eventPlayer.isInLobby:
        leaveLobby()
        if not eventPlayer.isRunLoaded or eventPlayer.isRunFinished:
            resetRun()
        eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
    elif (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    ):
        addMistake()
    eventPlayer.spectating[0] = true
    eventPlayer.spectating[1] = null
    eventPlayer.spectating[3] = true
    eventPlayer.spectating[4] = eventPlayer.runCurrentCp
    enableFreecam()
    enableFreecamForSpectators()
    eventPlayer.isLoading = false


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


# The camera reevaluates its positions, so it keeps following the target without being restarted
macro startSpectatorCamera():
    eventPlayer.startCamera(
        spectatorCamPos(eventPlayer.spectating[1]),
        eventPlayer.spectating[1].getEyePosition()
        + eventPlayer.spectating[1].getFacingDirection(),
        250
    )


rule "Hold Queued Camera":
    @Event eachPlayer
    @Condition eventPlayer in freecamQueue
    @Condition eventPlayer.spectating[2] == false
    @Condition eventPlayer.qaPage == 0

    # While waiting in Freecam Queue, the camera stays where it was watching from
    eventPlayer.startCamera(eventPlayer.spectating[11], eventPlayer.spectating[12], 0)


def disableSpectator():
    @Name "Disable"

    eventPlayer.isLoading = true
    if not eventPlayer.spectating[3] and eventPlayer.spectating[1] != null:
        eventPlayer.spectating[4] = eventPlayer.spectating[1].runCurrentCp
    # Leaving freecam, the camera already shows the checkpoint the player lands on while the swap finishes,
    # and the player is invisible (the swap keeps it, and it hides them from their own camera too), so
    # nobody sees Wrecking Ball appear where the freecam was. Stop Camera and the teleport onto the
    # checkpoint below share a tick.
    if eventPlayer.getHero() != Hero.WRECKING_BALL and not eventPlayer.isInFreemode:
        if eventPlayer.qaPage == 0:
            eventPlayer.startCamera(
                cps[eventPlayer.spectating[4]][0] + vect(0, 1.7, 0),
                cps[eventPlayer.spectating[4]][0]
                + vect(0, 1.7, 0)
                + eventPlayer.getFacingDirection(),
                0
            )
        eventPlayer.setInvisibility(Invis.ALL)
        # The camera gets its own tick too, so the swap still happens alone
        wait()
    swapToWreckingBall()
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.setGravity(100)
    eventPlayer.setMoveSpeed(100)
    eventPlayer.stopForcingPosition()
    if eventPlayer.qaPage == 0:
        eventPlayer.stopCamera()
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.spectating[0] = false
    if eventPlayer.spectating[4] > eventPlayer.runCurrentCp:
        eventPlayer.isRunLegit = false
    # Landing back on the CP they left keeps its mistake count
    if eventPlayer.spectating[4] != eventPlayer.runCurrentCp:
        resetCpMistakes()
    eventPlayer.runCurrentCp = eventPlayer.spectating[4]
    eventPlayer.spectating[1].spectating[10]--
    eventPlayer.spectating[1] = null
    eventPlayer.spectating[2] = false
    eventPlayer.spectating[3] = false
    loadCpData()
    if eventPlayer.isInFreemode:
        eventPlayer.nameplate = _("{} | FREEMODE").format(eventPlayer)
    else:
        setCpAbilities()
        cpResetPlayer()
        showCpNameplate()
    eventPlayer.isLoading = false


# Nobody in the lobby, as they're held invisible up in its sky
macro spectatablePlayers(player):
    getAllPlayers().filter(
        lambda p: p != player
        and p.hasSpawned()
        and not p.spectating[0]
        and not p.isInLobby
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
    @Condition eventPlayer.qaPage == 0
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
    @Condition eventPlayer.qaPage == 0
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
    @Condition eventPlayer.qaPage == 0
    @Condition eventPlayer.spectating[5] == false
    @Condition len(spectatablePlayers(eventPlayer)) > 0
    @Condition canSwapHero(eventPlayer)

    eventPlayer.spectating[8] = getAllPlayers().filter(
        lambda p: p != eventPlayer
        and p.hasSpawned()
        and not p.spectating[0]
        and not p.isInLobby
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
    @Condition eventPlayer.qaPage == 0
    @Condition canSwapHero(eventPlayer)
    # Disconnected without freecam means waiting in Freecam Queue
    @Condition eventPlayer.spectating[3] == false

    swapToJetpackCat()
    enableFreecam()


def enableFreecam():
    @Name "Enable Freecam"

    if playerToEnableFreecam == null:
        playerToEnableFreecam = eventPlayer
    # The player is already Jetpack Cat: callers swap first, so the swap gets its own moment
    playerToEnableFreecam.disableEnvironmentCollision(true)
    if playerToEnableFreecam.qaPage == 0:
        playerToEnableFreecam.stopCamera()
    playerToEnableFreecam.stopForcingPosition()
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
    playerToEnableFreecam.nameplate = _("{} | FREECAM").format(playerToEnableFreecam)
    playerToEnableFreecam.spectating[2] = true
    playerToEnableFreecam = null


def swapToJetpackCat():
    @Name "Swap To Jetpack Cat"

    # Swaps, then waits until it's done before the caller changes anything else about the player:
    # a swap at the same moment as the rest of spectator mode (collision, gravity, buttons, camera,
    # teleports) peaked around 180% server load, against ~135% when the swap finished first.
    # The swap alone reads around 100%, so first it waits up to half a second for a reading under 50%,
    # to keep it off other spikes like the one Overwatch has every 5 seconds.
    # heroSwapTime is for canSwapHero, which is waited out here too since not every caller is an
    # input that checks it (going to the lobby, a new run, Prev./Next Checkpoint).
    if eventPlayer.getHero() != Hero.JETPACK_CAT:
        waitUntil(canSwapHero(eventPlayer), SWAP_COOLDOWN)
        waitUntil(getServerLoad() < 50, 0.5)
        eventPlayer.heroSwapTime = getTotalTimeElapsed()
        eventPlayer.startForcingHero(Hero.JETPACK_CAT)
        waitUntil(eventPlayer.getHero() == Hero.JETPACK_CAT, 1)
        wait(0.25)


def swapToWreckingBall():
    @Name "Swap To Wrecking Ball"

    # Like Swap To Jetpack Cat
    if eventPlayer.getHero() != Hero.WRECKING_BALL:
        waitUntil(canSwapHero(eventPlayer), SWAP_COOLDOWN)
        waitUntil(getServerLoad() < 50, 0.5)
        eventPlayer.heroSwapTime = getTotalTimeElapsed()
        eventPlayer.startForcingHero(Hero.WRECKING_BALL)
        waitUntil(eventPlayer.getHero() == Hero.WRECKING_BALL, 1)
        wait(0.25)


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

    # For players spectating someone who enables spectator mode, goes to the lobby or leaves
    for index in range(len(getAllPlayers())):
        if getAllPlayers()[index].spectating[0] == true:
            if getAllPlayers()[index].spectating[1] == eventPlayer:
                if getAllPlayers()[index].spectating[5] == true:
                    getAllPlayers()[index].resurrect()
                    getAllPlayers()[index].spectating[5] = false
                if getAllPlayers()[index].spectating[2] == false:
                    # Its swap to Jetpack Cat waits its turn in Freecam Queue, with the camera held where it was
                    if entityExists(eventPlayer):
                        getAllPlayers()[index].spectating[11] = spectatorCamPos(
                            eventPlayer
                        )
                        getAllPlayers()[index].spectating[12] = (
                            eventPlayer.getEyePosition()
                            + eventPlayer.getFacingDirection()
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

    # One hero swap at a time, since a hero swap spikes the server's load and several watchers can lose their
    # target at once. Skips anyone who left, left spectator mode or started watching someone else meanwhile.
    # Like Swap To Jetpack Cat, the swap waits for a quiet moment and finishes before Enable Freecam
    # changes anything else.
    if (
        entityExists(freecamQueue[0])
        and freecamQueue[0].spectating[0]
        and freecamQueue[0].spectating[3]
        and not freecamQueue[0].spectating[2]
        and freecamQueue[0].getHero() != Hero.JETPACK_CAT
    ):
        waitUntil(getServerLoad() < 50, 0.5)
        freecamQueue[0].heroSwapTime = getTotalTimeElapsed()
        freecamQueue[0].startForcingHero(Hero.JETPACK_CAT)
        waitUntil(
            not entityExists(freecamQueue[0])
            or freecamQueue[0].getHero() == Hero.JETPACK_CAT,
            1
        )
        wait(0.25)
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
            directionTowards(
                freecamQueue[0].spectating[11], freecamQueue[0].spectating[12]
            ),
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
    @Condition eventPlayer.qaPage == 0
    @Condition eventPlayer.spectating[5] == false
    @Condition canSwapHero(eventPlayer)

    reattachToSpectatingTarget()


def reattachToSpectatingTarget():
    @Name "Reattach"

    # Watching someone as Jetpack Cat would play its sounds at their position
    swapToWreckingBall()
    eventPlayer.applyImpulse(
        eventPlayer.getVelocity() * -0.001,
        0.001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.startForcingPosition(eventPlayer.spectating[1].getPosition())
    if eventPlayer.qaPage == 0:
        startSpectatorCamera()
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.setAbility2Enabled(false)
    # Nameplates are shown with _(), so a blank one has to be a translated string too
    eventPlayer.nameplate = _("{}").format("")
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
    @Condition eventPlayer.qaPage == 0
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
            _(
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
