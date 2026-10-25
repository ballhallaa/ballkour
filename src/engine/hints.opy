#!mainFile "../main.opy"
#!rulePrefix "Hints"


macro hintViewCp(player):
    (
        (
            player.spectating[4]
            if player.spectating[3]
            else player.spectating[1].runCurrentCp
        )
        if player.spectating[0]
        else player.runCurrentCp
    )


macro hintColor(player):
    hintColors[
        sorted(
            hintActions[player.hintCp].filter(
                lambda span: span.x <= player.hintTime and player.hintTime < span.y
            ),
            lambda span: -(span.z % 4)
        )[0].z
    ]


rule "Load Objects":
    hintColors = [
        Color.VIOLET,
        rgb(255, 210, 0),
        rgb(255, 70, 70),
        rgb(0, 190, 255),
        Color.WHITE
    ]
    createEffect(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isHintPlaying),
        Effect.ORB,
        hintColor(localPlayer),
        localPlayer.hintPos + vect(0, 1, 0),
        0.5,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    createBeam(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isHintPlaying and localPlayer.hintAnchor
        ),
        Beam.GRAPPLE,
        localPlayer.hintPos + vect(0, 1, 0),
        localPlayer.hintAnchor,
        hintColors[1],
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )


rule "Sync Checkpoint":
    @Event eachPlayer
    @Condition eventPlayer.hintCp != hintViewCp(eventPlayer)

    eventPlayer.hintCp = hintViewCp(eventPlayer)


rule "Playback":
    @Event eachPlayer
    @Condition eventPlayer.isHintOn == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.hintCp == hintViewCp(eventPlayer)
    @Condition len(hintRoutes[eventPlayer.hintCp]) > 1

    stopChasingVariable(eventPlayer.hintPos)
    stopChasingVariable(eventPlayer.hintTime)
    eventPlayer.hintTime = -1
    eventPlayer.hintIndex = 0
    eventPlayer.hintPlayCp = eventPlayer.hintCp
    eventPlayer.hintPos = hintRoutes[eventPlayer.hintCp][0]
    eventPlayer.isHintPlaying = true
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.hintTime = 0
    eventPlayer.hintStep = 0
    chaseAtRate(eventPlayer.hintTime, Math.INFINITY, 1)
    while (
        eventPlayer.hintStep < hintTimes[eventPlayer.hintCp].last()
        and eventPlayer.hintPlayCp == eventPlayer.hintCp
    ):
        if eventPlayer.hintStep >= hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex]:
            eventPlayer.hintIndex++
            # hintSpline: [0]start [1]end [2]startVelocity [3]endVelocity
            eventPlayer.hintSpline = [
                hintRoutes[eventPlayer.hintCp][eventPlayer.hintIndex - 1],
                hintRoutes[eventPlayer.hintCp][eventPlayer.hintIndex],
                (
                    hintRoutes[eventPlayer.hintCp][eventPlayer.hintIndex]
                    - hintRoutes[eventPlayer.hintCp][max(eventPlayer.hintIndex - 2, 0)]
                )
                * (
                    (
                        hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex]
                        - hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex - 1]
                    )
                    / (
                        hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex]
                        - hintTimes[eventPlayer.hintCp][max(eventPlayer.hintIndex - 2, 0)]
                    )
                ),
                (
                    hintRoutes[eventPlayer.hintCp][
                        min(eventPlayer.hintIndex + 1, len(hintRoutes[eventPlayer.hintCp]) - 1)
                    ]
                    - hintRoutes[eventPlayer.hintCp][eventPlayer.hintIndex - 1]
                )
                * (
                    (
                        hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex]
                        - hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex - 1]
                    )
                    / (
                        hintTimes[eventPlayer.hintCp][
                            min(eventPlayer.hintIndex + 1, len(hintRoutes[eventPlayer.hintCp]) - 1)
                        ]
                        - hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex - 1]
                    )
                )
            ]
        eventPlayer.hintStep = min(
            eventPlayer.hintStep + 0.1,
            hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex]
        )
        eventPlayer.hintS = (
            eventPlayer.hintStep - hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex - 1]
        ) / (
            hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex]
            - hintTimes[eventPlayer.hintCp][eventPlayer.hintIndex - 1]
        )
        chaseOverTime(
            eventPlayer.hintPos,
            eventPlayer.hintSpline[0] * (2 * eventPlayer.hintS ** 3 - 3 * eventPlayer.hintS ** 2 + 1)
            + eventPlayer.hintSpline[1] * (3 * eventPlayer.hintS ** 2 - 2 * eventPlayer.hintS ** 3)
            + eventPlayer.hintSpline[2]
            * (eventPlayer.hintS ** 3 - 2 * eventPlayer.hintS ** 2 + eventPlayer.hintS)
            + eventPlayer.hintSpline[3] * (eventPlayer.hintS ** 3 - eventPlayer.hintS ** 2),
            eventPlayer.hintStep - eventPlayer.hintTime,
            ChaseTimeReeval.NONE
        )
        wait(eventPlayer.hintStep - eventPlayer.hintTime, Wait.ABORT_WHEN_FALSE)
    stopChasingVariable(eventPlayer.hintTime)
    eventPlayer.hintTime = -1
    eventPlayer.hintIndex = 0
    if eventPlayer.hintPlayCp == eventPlayer.hintCp:
        wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION: loop()


rule "Stop Playback":
    @Event eachPlayer
    @Condition eventPlayer.isHintPlaying == true
    @Condition (
        not eventPlayer.isHintOn
        or eventPlayer.isInLobby
        or len(hintRoutes[eventPlayer.hintCp]) <= 1
    ) == true

    eventPlayer.isHintPlaying = false
    stopChasingVariable(eventPlayer.hintPos)
    stopChasingVariable(eventPlayer.hintTime)


rule "Trail":
    @Event eachPlayer
    @Condition eventPlayer.isHintPlaying == true
    @Condition eventPlayer.hintIndex > 0

    playEffect(
        eventPlayer,
        DynamicEffect.GOOD_EXPLOSION,
        hintColor(eventPlayer),
        eventPlayer.hintPos + vect(0, 1, 0),
        0.3
    )
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION: loop()


rule "Grapple":
    @Event eachPlayer
    @Condition eventPlayer.isHintPlaying == true
    @Condition len(hintAnchors[eventPlayer.hintCp]) > 0

    eventPlayer.hintAnchor = hintAnchors[eventPlayer.hintCp][
        hintActions[eventPlayer.hintCp].index(
            hintActions[eventPlayer.hintCp].filter(
                lambda span: span.z == 1
                and span.x <= eventPlayer.hintTime
                and eventPlayer.hintTime < span.y
            )[0]
        )
    ]
    wait()
    if RULE_CONDITION: loop()
    eventPlayer.hintAnchor = null
