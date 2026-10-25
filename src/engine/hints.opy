#!mainFile "../main.opy"
#!rulePrefix "Hints"


rule "Decompress Routes":
    # Each course stores hintData[i] as one compressed vector array: vect(keyframe count, action count, anchor count),
    # then hintRoutes[i], hintTimes[i] three to a vector, hintActions[i] and hintAnchors[i] (one per action, or none)
    for index in range(len(hintData)):
        if hintData[index] != null:
            hintScratch = decompressVectors(hintData[index])
            hintRoutes[index] = hintScratch.slice(1, hintScratch[0].x)
            # Time i is the x, y or z of its vector, which a dot product with Left, Up or Forward picks out
            hintTimes[index] = hintRoutes[index].map(
                lambda keyframe, i: dotProduct(
                    hintScratch[1 + hintScratch[0].x + floor(i / 3)],
                    [Vector.LEFT, Vector.UP, Vector.FORWARD][i % 3]
                )
            )
            hintActions[index] = hintScratch.slice(
                len(hintScratch) - hintScratch[0].y - hintScratch[0].z, hintScratch[0].y
            )
            hintAnchors[index] = hintScratch.slice(len(hintScratch) - hintScratch[0].z, hintScratch[0].z)
    hintData = null
    hintScratch = null


macro hintColor(player):
    hintColors[
        sorted(
            hintActions[player.viewCp].filter(
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
        null,
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
    )


rule "Playback":
    @Event eachPlayer
    @Condition eventPlayer.isHintOn == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.viewCp == viewedCp(eventPlayer)
    @Condition len(hintRoutes[eventPlayer.viewCp]) > 1

    stopChasingVariable(eventPlayer.hintPos)
    stopChasingVariable(eventPlayer.hintTime)
    eventPlayer.hintTime = -1
    eventPlayer.hintIndex = 0
    eventPlayer.hintPlayCp = eventPlayer.viewCp
    # The route being played, so it doesn't need looking up on every step
    eventPlayer.hintKeyframes = hintRoutes[eventPlayer.viewCp]
    eventPlayer.hintKeyframeTimes = hintTimes[eventPlayer.viewCp]
    eventPlayer.hintPos = eventPlayer.hintKeyframes[0]
    eventPlayer.isHintPlaying = true
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.hintTime = 0
    eventPlayer.hintStep = 0
    chaseAtRate(eventPlayer.hintTime, Math.INFINITY, 1)
    while (
        eventPlayer.hintStep < eventPlayer.hintKeyframeTimes.last()
        and eventPlayer.hintPlayCp == eventPlayer.viewCp
    ):
        if eventPlayer.hintStep >= eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex]:
            eventPlayer.hintIndex++
            # hintSpline: [0]start [1]end [2]startVelocity [3]endVelocity
            eventPlayer.hintSpline = [
                eventPlayer.hintKeyframes[eventPlayer.hintIndex - 1],
                eventPlayer.hintKeyframes[eventPlayer.hintIndex],
                (
                    eventPlayer.hintKeyframes[eventPlayer.hintIndex]
                    - eventPlayer.hintKeyframes[max(eventPlayer.hintIndex - 2, 0)]
                )
                * (
                    (
                        eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex]
                        - eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex - 1]
                    )
                    / (
                        eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex]
                        - eventPlayer.hintKeyframeTimes[max(eventPlayer.hintIndex - 2, 0)]
                    )
                ),
                (
                    eventPlayer.hintKeyframes[
                        min(eventPlayer.hintIndex + 1, len(eventPlayer.hintKeyframes) - 1)
                    ]
                    - eventPlayer.hintKeyframes[eventPlayer.hintIndex - 1]
                )
                * (
                    (
                        eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex]
                        - eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex - 1]
                    )
                    / (
                        eventPlayer.hintKeyframeTimes[
                            min(eventPlayer.hintIndex + 1, len(eventPlayer.hintKeyframes) - 1)
                        ]
                        - eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex - 1]
                    )
                )
            ]
        eventPlayer.hintStep = min(
            eventPlayer.hintStep + 0.1,
            eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex]
        )
        eventPlayer.hintS = (
            eventPlayer.hintStep - eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex - 1]
        ) / (
            eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex]
            - eventPlayer.hintKeyframeTimes[eventPlayer.hintIndex - 1]
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
    if eventPlayer.hintPlayCp == eventPlayer.viewCp:
        wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION: loop()


rule "Stop Playback":
    @Event eachPlayer
    @Condition eventPlayer.isHintPlaying == true
    @Condition (
        not eventPlayer.isHintOn
        or eventPlayer.isInLobby
        or len(hintRoutes[eventPlayer.viewCp]) <= 1
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
    @Condition len(hintAnchors[eventPlayer.viewCp]) > 0

    eventPlayer.hintAnchor = hintAnchors[eventPlayer.viewCp][
        hintActions[eventPlayer.viewCp].index(
            hintActions[eventPlayer.viewCp].filter(
                lambda span: span.z == 1
                and span.x <= eventPlayer.hintTime
                and eventPlayer.hintTime < span.y
            )[0]
        )
    ]
    wait()
    if RULE_CONDITION: loop()
    eventPlayer.hintAnchor = null
