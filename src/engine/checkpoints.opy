#!mainFile "../main.opy"
#!rulePrefix "Checkpoint"


rule "Expand Data":
    # Unpacks each map's cps and fills in what it leaves out, so cps[i] becomes:
    # [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]orbLocations [6]orbSize [7]nextCpLocation [8]nextCpSize
    # and the final checkpoint becomes [0]cpLocation [1]cpSize
    # orbLocations is the line's orb, then the map's cpExtraOrbs for it, or null without any
    # cpSize and nextCpSize come from cpDefaults, unless the map's cpSizes changes them
    # nextCpLocation is the next checkpoint's, unless the map's cpLandings puts it elsewhere.
    # Checkpoint (No Skipping) then teleports the player from there to the checkpoint.
    cpOrbScratch = []
    if cpExtraOrbs:
        hintScratch = cpExtraOrbs
        decompressScratch()
        cpOrbScratch = hintScratch
    # cpSizes and cpLandings are compressed too, as a vect() is ~7 elements. A map
    # without them leaves them empty arrays, which read as false.
    if cpSizes:
        hintScratch = cpSizes
        decompressScratch()
        cpSizes = hintScratch
    if cpLandings:
        hintScratch = cpLandings
        decompressScratch()
        cpLandings = hintScratch
    hintScratch = cps
    decompressScratch()
    lastCp = (len(hintScratch) - 1) / 3
    cps = []
    for index in range(lastCp):
        # The orbs first, so the list can be checked for being empty
        cps[index] = (
            [hintScratch[index * 3 + 2]]
            if hintScratch[index * 3 + 2] != vect(0, 0, 0)
            else []
        ).concat(
            cpOrbScratch.filter(
                lambda orb, i: i % 2 == 1 and cpOrbScratch[i - 1].x == index
            )
        )
        cps[index] = [
            hintScratch[index * 3],
            cpDefaults[0],
            hintScratch[index * 3 + 1].x != 0,
            hintScratch[index * 3 + 1].y != 0,
            hintScratch[index * 3 + 1].z != 0,
            cps[index] if len(cps[index]) > 0 else null,
            cpDefaults[1],
            hintScratch[(index + 1) * 3],
            cpDefaults[2]
        ]
    cps[lastCp] = [hintScratch[lastCp * 3], cpDefaults[0]]
    for index in range(len(cpSizes)):
        if cpSizes[index].y:
            cps[cpSizes[index].x][1] = cpSizes[index].y
        if cpSizes[index].z:
            cps[cpSizes[index].x][8] = cpSizes[index].z
    for index in range(len(cpLandings) / 2):
        # Through hintScratch, which is done with, since a nested write costs ~30 elements more
        hintScratch = cps[cpLandings[index * 2].x - 1]
        hintScratch[7] = cpLandings[index * 2 + 1]
        cps[cpLandings[index * 2].x - 1] = hintScratch


def loadCpData():
    @Name "Load Data"

    # eventPlayer.cpData[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]orbLocations [6]orbSize [7]nextCpLocation [8]nextCpSize [9]isJumping [10]hasJumped [11]hasBhopped [12]isGrappling [13]hasUsedGrapple [14]hasShieldBounced [15]isPiledriving [16]grabbedOrbs [17]isLastOrbOnGround
    # Copying the checkpoint leaves [9] onwards unset, which reads as false. [16] starts at 0
    # since the Grab Orb rule adds to it.
    eventPlayer.cpData = cps[eventPlayer.runCurrentCp]
    eventPlayer.cpData[16] = 0
    eventPlayer.cpTime = 0
    eventPlayer.splitStart = eventPlayer.runTime
    # The run can be paused here (after a go-back or skip), which stops the formatting loop
    eventPlayer.cpTimeFormatted = "0.00"
    eventPlayer.splitTimeFormatted = "0.00"
    # The live times turn red past these, which they never are on a CP that hasn't been cleared yet
    eventPlayer.attemptCpBest = (
        eventPlayer.attemptBests[eventPlayer.runCurrentCp]
        if eventPlayer.attemptClears[eventPlayer.runCurrentCp]
        else Math.INFINITY
    )
    eventPlayer.splitCpBest = (
        eventPlayer.splitBests[eventPlayer.runCurrentCp]
        if eventPlayer.splitClears[eventPlayer.runCurrentCp]
        else Math.INFINITY
    )
    loadPace()


def setCpAbilities():
    @Name "Set Abilities"

    if eventPlayer.spectating[0]:
        return
    if eventPlayer.runCurrentCp < lastCp and not isFreePlay(eventPlayer):
        eventPlayer.setSecondaryFireEnabled(eventPlayer.cpData[2])
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
        if not eventPlayer.cpData[4]:
            eventPlayer.disallowButton(Button.CROUCH)
        else:
            eventPlayer.allowButton(Button.CROUCH)
    else:
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.allowButton(Button.CROUCH)
        eventPlayer.setAbility2Enabled(true)


macro viewedCp(player):
    (
        (
            player.spectating[4]
            if player.spectating[3]
            else player.spectating[1].runCurrentCp
        )
        if player.spectating[0]
        else player.runCurrentCp
    )


rule "Sync Viewed Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.viewCp != viewedCp(eventPlayer)

    eventPlayer.viewCp = viewedCp(eventPlayer)
    # A change in the same tick as the sync (a restart right as a CP clears) doesn't retrigger
    # the rule, since its condition never reads false in between, so this rechecks a tick later
    wait()
    if RULE_CONDITION:
        loop()


macro isViewingCp(player):
    (not player.isInLobby and player.viewCp != lastCp)


# cpData[16] keeps one bit per orb of the checkpoint: 1 for the first, 2 for the second...
macro hasGrabbedOrb(player, orbIndex):
    (floor(player.cpData[16] / 2**orbIndex) % 2 == 1)


macro hasAllOrbs(player):
    (player.cpData[16] == 2 ** len(player.cpData[5]) - 1)


# Until the runner being viewed (the player, unless spectating) grabs it. A disconnected
# spectator still has the runner they left for Reattach, but views another CP, so every
# orb shows
macro isViewingOrb(player, orbIndex):
    (
        isViewingCp(player)
        and cps[player.viewCp][5][orbIndex] != null
        and (
            (player.spectating[0] and player.spectating[3])
            or not hasGrabbedOrb(player.viewRunner, orbIndex)
        )
    )


rule "Load Objects":
    # The orbs look like the ones in Fasteroid's fork of the Giga editor (orange), without
    # their arrow. One effect per orb slot, as many as the checkpoint with the most orbs needs.
    for index in range(sorted(cps.map(lambda cp: len(cp[5]))).last()):
        createEffect(
            getAllPlayers().filter(
                lambda localPlayer: isViewingOrb(localPlayer, evalOnce(index))
            ),
            Effect.ORB,
            Color.ORANGE,
            cps[localPlayer.viewCp][5][evalOnce(index)],
            cps[localPlayer.viewCp][6],
            EffectReeval.VISIBILITY_POSITION_AND_RADIUS
        )
    createIcon(
        getAllPlayers().filter(lambda localPlayer: isViewingCp(localPlayer)),
        cps[localPlayer.viewCp][7] - vect(0, 0.5, 0),
        Icon.FLAG,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.AQUA
    )
    # One set of rings per size, each with its size fixed: a changing radius animates over
    # about a second, so a checkpoint of another size would grow or shrink into place
    cpRingSizes = []
    for index in range(lastCp):
        if cps[index][1] not in cpRingSizes:
            cpRingSizes.append(cps[index][1])
        if cps[index][8] not in cpRingSizes:
            cpRingSizes.append(cps[index][8])
    for index in range(len(cpRingSizes)):
        createEffect(
            getAllPlayers().filter(
                lambda localPlayer: isViewingCp(localPlayer)
                and cps[localPlayer.viewCp][1] == evalOnce(cpRingSizes[index])
            ),
            Effect.RING,
            Color.WHITE,
            cps[localPlayer.viewCp][0],
            evalOnce(cpRingSizes[index]),
            EffectReeval.VISIBILITY_POSITION_AND_RADIUS
        )
        createEffect(
            getAllPlayers().filter(
                lambda localPlayer: isViewingCp(localPlayer)
                and cps[localPlayer.viewCp][8] == evalOnce(cpRingSizes[index])
            ),
            Effect.RING,
            Color.AQUA,
            cps[localPlayer.viewCp][7],
            evalOnce(cpRingSizes[index]),
            EffectReeval.VISIBILITY_POSITION_AND_RADIUS
        )
        createEffect(
            getAllPlayers().filter(
                lambda localPlayer: isViewingCp(localPlayer)
                and cps[localPlayer.viewCp][8] == evalOnce(cpRingSizes[index])
            ),
            Effect.LIGHT_SHAFT,
            Color.GRAY,
            cps[localPlayer.viewCp][7],
            evalOnce(cpRingSizes[index]),
            EffectReeval.VISIBILITY_POSITION_AND_RADIUS
        )


def faceNextCp():
    @Name "Face Next Checkpoint"

    eventPlayer.setFacing(
        directionTowards(
            eventPlayer.getEyePosition(),
            (
                cps[eventPlayer.spectating[4]][7]
                if eventPlayer.spectating[0]
                else eventPlayer.cpData[7]
            )
        ),
        Relativity.TO_WORLD
    )


def cpResetPlayer():
    @Name "Reset Player"

    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.cpTime = 0
    # The run can be paused here (in freemode), which stops the formatting loop
    eventPlayer.cpTimeFormatted = "0.00"
    if not eventPlayer.spectating[0]:
        eventPlayer.teleport(eventPlayer.cpData[0])
    else:
        eventPlayer.teleport(cps[eventPlayer.spectating[4]][0])
    eventPlayer.applyImpulse(
        eventPlayer.getVelocity() * -0.001,
        0.001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.3)
    if eventPlayer.runCurrentCp < lastCp:
        if eventPlayer.cpData[5] != null:
            eventPlayer.cpData[13] = false
            # Unless the orb checkpoint disables the grapple (Orb Checkpoint: No Grapple)
            eventPlayer.setSecondaryFireEnabled(
                eventPlayer.cpData[2] or isFreePlay(eventPlayer)
            )
            eventPlayer.cpData[16] = false
        eventPlayer.cpData[10] = false
        eventPlayer.cpData[11] = false
        eventPlayer.cpData[14] = false
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3] or isFreePlay(eventPlayer))
