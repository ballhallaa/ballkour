#!mainFile "../main.opy"
#!rulePrefix "Checkpoint"


def loadCpData():
    @Name "Load Data"

    # eventPlayer.cpData[i]: [0]cpLocation [1]cpSize [2]isGrappleAllowed [3]isShieldBounceAllowed [4]isPiledriverAllowed [5]bounceLocation [6]bounceSize [7]nextCpLocation [8]nextCpSize [9]isJumping [10]hasJumped [11]hasBhopped [12]isGrappling [13]hasUsedGrapple [14]hasShieldBounced [15]isPiledriving [16]hasUsedBounceJump
    eventPlayer.cpData = []
    eventPlayer.cpData[0] = cps[eventPlayer.runCurrentCp][0]
    eventPlayer.cpData[1] = cps[eventPlayer.runCurrentCp][1]
    eventPlayer.cpData[2] = cps[eventPlayer.runCurrentCp][2]
    eventPlayer.cpData[3] = cps[eventPlayer.runCurrentCp][3]
    eventPlayer.cpData[4] = cps[eventPlayer.runCurrentCp][4]
    eventPlayer.cpData[5] = cps[eventPlayer.runCurrentCp][5]
    eventPlayer.cpData[6] = cps[eventPlayer.runCurrentCp][6]
    eventPlayer.cpData[7] = cps[eventPlayer.runCurrentCp][7]
    eventPlayer.cpData[8] = cps[eventPlayer.runCurrentCp][8]
    eventPlayer.cpData[10] = false
    eventPlayer.cpData[11] = false
    eventPlayer.cpData[13] = false
    eventPlayer.cpData[14] = false
    eventPlayer.cpData[16] = false
    eventPlayer.cpStartTime = eventPlayer.runTime
    eventPlayer.cpTime = 0


def setCpAbilities():
    @Name "Set Abilities"

    if eventPlayer.spectating[0]:
        return
    if (
        eventPlayer.runCurrentCp < len(cps) - 1
        and not eventPlayer.isInFreemode
        and not eventPlayer.spectating[0]
    ):
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


rule "Load Objects":
    # Non-Spectating Objects
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and not localPlayer.runCurrentCp == len(cps) - 1
        ),
        Effect.RING,
        Color.GREEN,
        localPlayer.cpData[0],
        localPlayer.cpData[1],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and localPlayer.cpData[5] != null
            and not localPlayer.runCurrentCp == len(cps) - 1
        ),
        Effect.RING,
        Color.ORANGE,
        localPlayer.cpData[5],
        localPlayer.cpData[6],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and localPlayer.cpData[5] != null
            and not localPlayer.runCurrentCp == len(cps) - 1
        ),
        localPlayer.cpData[5],
        Icon.ARROW_UP,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.YELLOW,
        false
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and not localPlayer.runCurrentCp == len(cps) - 1
        ),
        Effect.RING,
        Color.AQUA,
        localPlayer.cpData[7],
        localPlayer.cpData[8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and not localPlayer.runCurrentCp == len(cps) - 1
        ),
        localPlayer.cpData[7] - vect(0, 0.5, 0),
        Icon.FLAG,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.GREEN
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and not localPlayer.runCurrentCp == len(cps) - 1
        ),
        Effect.LIGHT_SHAFT,
        Color.GRAY,
        localPlayer.cpData[7],
        localPlayer.cpData[8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    # Spectating Objects
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and not localPlayer.spectating[3]
            and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1
        ),
        Effect.RING,
        Color.GREEN,
        localPlayer.spectating[1].cpData[0],
        localPlayer.spectating[1].cpData[1],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and not localPlayer.spectating[3]
            and localPlayer.spectating[1].cpData[5] != null
            and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1
        ),
        Effect.RING,
        Color.ORANGE,
        localPlayer.spectating[1].cpData[5],
        localPlayer.spectating[1].cpData[6],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and not localPlayer.spectating[3]
            and localPlayer.spectating[1].cpData[5] != null
            and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1
        ),
        localPlayer.spectating[1].cpData[5],
        Icon.ARROW_UP,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.YELLOW,
        false
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and not localPlayer.spectating[3]
            and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1
        ),
        Effect.RING,
        Color.AQUA,
        localPlayer.spectating[1].cpData[7],
        localPlayer.spectating[1].cpData[8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and not localPlayer.spectating[3]
            and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1
        ),
        localPlayer.spectating[1].cpData[7] - vect(0, 0.5, 0),
        Icon.FLAG,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.GREEN
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and not localPlayer.spectating[3]
            and not localPlayer.spectating[1].runCurrentCp == len(cps) - 1
        ),
        Effect.LIGHT_SHAFT,
        Color.GRAY,
        localPlayer.spectating[1].cpData[7],
        localPlayer.spectating[1].cpData[8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    # Spectating Objects — Freecam Disconnected
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and not localPlayer.spectating[4] == len(cps) - 1
        ),
        Effect.RING,
        Color.GREEN,
        cps[localPlayer.spectating[4]][0],
        cps[localPlayer.spectating[4]][1],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and cps[localPlayer.spectating[4]][5] != null
            and not localPlayer.spectating[4] == len(cps) - 1
        ),
        Effect.RING,
        Color.ORANGE,
        cps[localPlayer.spectating[4]][5],
        cps[localPlayer.spectating[4]][6],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and cps[localPlayer.spectating[4]][5] != null
            and not localPlayer.spectating[4] == len(cps) - 1
        ),
        cps[localPlayer.spectating[4]][5],
        Icon.ARROW_UP,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.YELLOW,
        false
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and not localPlayer.spectating[4] == len(cps) - 1
        ),
        Effect.RING,
        Color.AQUA,
        cps[localPlayer.spectating[4]][7],
        cps[localPlayer.spectating[4]][8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and not localPlayer.spectating[4] == len(cps) - 1
        ),
        cps[localPlayer.spectating[4]][7] - vect(0, 0.5, 0),
        Icon.FLAG,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.GREEN
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.spectating[0]
            and localPlayer.spectating[3]
            and not localPlayer.spectating[4] == len(cps) - 1
        ),
        Effect.LIGHT_SHAFT,
        Color.GRAY,
        cps[localPlayer.spectating[4]][7],
        cps[localPlayer.spectating[4]][8],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
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
    if eventPlayer.runCurrentCp < len(cps) - 1:
        if eventPlayer.cpData[5] != null:
            eventPlayer.cpData[13] = false
            eventPlayer.setSecondaryFireEnabled(true)
            eventPlayer.cpData[16] = false
        eventPlayer.cpData[10] = false
        eventPlayer.cpData[11] = false
        eventPlayer.cpData[14] = false
        eventPlayer.setAbility2Enabled(eventPlayer.cpData[3])
