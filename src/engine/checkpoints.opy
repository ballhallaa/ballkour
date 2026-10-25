#!mainFile "../main.opy"
#!rulePrefix "Checkpoint"


rule "Expand Data":
    # Fills in what each map's cps[i] leaves out, so cps[i] becomes:
    # [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize
    # and the final checkpoint becomes [0]cpLocation [1]cpSize
    lastCp = len(cps) - 1
    for index in range(lastCp):
        cps[index] = [
            cps[index][0],
            cpDefaults[0],
            cps[index][1],
            cps[index][2],
            cps[index][3],
            cps[index][4],
            cpDefaults[1],
            cps[index + 1][0],
            cpDefaults[2]
        ]
    cps[lastCp] = [cps[lastCp][0], cpDefaults[0]]


def loadCpData():
    @Name "Load Data"

    # eventPlayer.cpData[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize [9]isJumping [10]hasJumped [11]hasBhopped [12]isGrappling [13]hasUsedGrapple [14]hasShieldBounced [15]isPiledriving [16]hasUsedBounceJump
    # Copying the checkpoint leaves [9] onwards unset, which reads as false
    eventPlayer.cpData = cps[eventPlayer.runCurrentCp]
    eventPlayer.cpStartTime = eventPlayer.runTime
    eventPlayer.cpTime = 0
    eventPlayer.splitStart = eventPlayer.runTime
    # The run can be paused here (after a go-back or skip), which stops the formatting loop
    eventPlayer.splitTimeFormatted = "0.00"


def setCpAbilities():
    @Name "Set Abilities"

    if eventPlayer.spectating[0]:
        return
    if eventPlayer.runCurrentCp < lastCp and not eventPlayer.isInFreemode:
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


macro isViewingCp(player):
    (not player.isInLobby and player.viewCp != lastCp)


rule "Load Objects":
    createEffect(
        getAllPlayers().filter(lambda localPlayer: isViewingCp(localPlayer)),
        Effect.RING,
        Color.GREEN,
        cps[localPlayer.viewCp][0],
        cps[localPlayer.viewCp][1],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: isViewingCp(localPlayer)
            and cps[localPlayer.viewCp][5] != null
        ),
        Effect.RING,
        Color.ORANGE,
        cps[localPlayer.viewCp][5],
        cps[localPlayer.viewCp][6],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: isViewingCp(localPlayer)
            and cps[localPlayer.viewCp][5] != null
        ),
        cps[localPlayer.viewCp][5],
        Icon.ARROW_UP,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.YELLOW,
        false
    )
    createEffect(
        getAllPlayers().filter(lambda localPlayer: isViewingCp(localPlayer)),
        Effect.RING,
        Color.AQUA,
        cps[localPlayer.viewCp][7],
        cps[localPlayer.viewCp][8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(lambda localPlayer: isViewingCp(localPlayer)),
        cps[localPlayer.viewCp][7] - vect(0, 0.5, 0),
        Icon.FLAG,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.GREEN
    )
    createEffect(
        getAllPlayers().filter(lambda localPlayer: isViewingCp(localPlayer)),
        Effect.LIGHT_SHAFT,
        Color.GRAY,
        cps[localPlayer.viewCp][7],
        cps[localPlayer.viewCp][8],
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
            eventPlayer.setSecondaryFireEnabled(true)
            eventPlayer.cpData[16] = false
        eventPlayer.cpData[10] = false
        eventPlayer.cpData[11] = false
        eventPlayer.cpData[14] = false
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
