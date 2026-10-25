#!mainFile "../main.opy"
#!rulePrefix "Hint Recorder"


rule "Record Route":
    @Event eachPlayer
    @Condition isHintRecorderOn == true
    @Condition eventPlayer == hostPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
    ) == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.spectating[0] == false
    @Condition eventPlayer.runCurrentCp < lastCp

    if (
        eventPlayer.hintRecordCp != eventPlayer.runCurrentCp
        or getTotalTimeElapsed() - eventPlayer.hintRecordLast > 0.3
        or (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            <= eventPlayer.cpData[1]
            and (
                (eventPlayer.isOnGround() and eventPlayer.getSpeed() < 1)
                or eventPlayer.hasStatus(Status.ROOTED)
                or distance(eventPlayer.hintRecording.last(), eventPlayer.cpData[0])
                > eventPlayer.cpData[1]
            )
        )
    ):
        eventPlayer.hintRecordCp = eventPlayer.runCurrentCp
        eventPlayer.hintRecording = [eventPlayer.getPosition()]
        eventPlayer.hintRecordTimes = [0]
        eventPlayer.hintRecordStart = getTotalTimeElapsed()
        eventPlayer.hintRecordActions = []
        eventPlayer.hintRecordAnchors = []
    elif len(eventPlayer.hintRecording) < 999:
        eventPlayer.hintRecording.append(eventPlayer.getPosition())
        eventPlayer.hintRecordTimes.append(
            getTotalTimeElapsed() - eventPlayer.hintRecordStart
        )
    eventPlayer.hintRecordLast = getTotalTimeElapsed()
    wait(0.1)
    if RULE_CONDITION: loop()


rule "Record Grapple":
    @Event eachPlayer
    @Condition isHintRecorderOn == true
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isFiringSecondaryFire() == true

    eventPlayer.hintActionStarts[1] = getTotalTimeElapsed()
    eventPlayer.hintGrappleAnchor = raycast(
        eventPlayer.getEyePosition(),
        eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 20,
        null,
        getAllPlayers(),
        false
    ).getHitPosition()
    waitUntil(not eventPlayer.isFiringSecondaryFire(), Math.INFINITY)
    if eventPlayer.hintActionStarts[1]:
        eventPlayer.hintRecordActions.append(
            vect(eventPlayer.hintActionStarts[1], getTotalTimeElapsed(), 1)
        )
        eventPlayer.hintRecordAnchors.append(eventPlayer.hintGrappleAnchor)
        eventPlayer.hintActionStarts[1] = 0


rule "Record Piledrive":
    @Event eachPlayer
    @Condition isHintRecorderOn == true
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.cpData[15] == true

    eventPlayer.hintActionStarts[2] = getTotalTimeElapsed()
    waitUntil(not eventPlayer.cpData[15], Math.INFINITY)
    if eventPlayer.hintActionStarts[2]:
        eventPlayer.hintRecordActions.append(
            vect(eventPlayer.hintActionStarts[2], getTotalTimeElapsed(), 2)
        )
        eventPlayer.hintRecordAnchors.append(0)
        eventPlayer.hintActionStarts[2] = 0


rule "Record Shield Bounce":
    @Event eachPlayer
    @Condition isHintRecorderOn == true
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.cpData[14] == true

    eventPlayer.hintRecordActions.append(
        vect(getTotalTimeElapsed(), getTotalTimeElapsed() + 0.4, 3)
    )
    eventPlayer.hintRecordAnchors.append(0)


rule "Record Jump":
    @Event eachPlayer
    @Condition isHintRecorderOn == true
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isJumping() == true

    eventPlayer.hintRecordActions.append(
        vect(getTotalTimeElapsed(), getTotalTimeElapsed() + 0.4, 4)
    )
    eventPlayer.hintRecordAnchors.append(0)


def saveHintRoute():
    @Name "Save Route"

    # Wrapped so release builds leave the subroutine out entirely
    if HINT_RECORDER:
        if (
            len(eventPlayer.hintRecording) == 0
            or distance(eventPlayer.hintRecording[0], eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            return
        eventPlayer.hintRecording.append(eventPlayer.getPosition())
        eventPlayer.hintRecordTimes.append(getTotalTimeElapsed() - eventPlayer.hintRecordStart)
        if eventPlayer.hintActionStarts[1]:
            eventPlayer.hintRecordActions.append(
                vect(eventPlayer.hintActionStarts[1], getTotalTimeElapsed(), 1)
            )
            eventPlayer.hintRecordAnchors.append(eventPlayer.hintGrappleAnchor)
            eventPlayer.hintActionStarts[1] = 0
        if eventPlayer.hintActionStarts[2]:
            eventPlayer.hintRecordActions.append(
                vect(eventPlayer.hintActionStarts[2], getTotalTimeElapsed(), 2)
            )
            eventPlayer.hintRecordAnchors.append(0)
            eventPlayer.hintActionStarts[2] = 0
        hintRoutes[eventPlayer.runCurrentCp] = eventPlayer.hintRecording
        hintTimes[eventPlayer.runCurrentCp] = eventPlayer.hintRecordTimes
        hintActions[eventPlayer.runCurrentCp] = eventPlayer.hintRecordActions.map(
            lambda span: vect(
                max(0, span.x - eventPlayer.hintRecordStart),
                span.y - eventPlayer.hintRecordStart,
                span.z
            )
        )
        hintAnchors[eventPlayer.runCurrentCp] = eventPlayer.hintRecordAnchors
        logToInspector(
            "hint {} start {}".format(
                eventPlayer.runCurrentCp, len(eventPlayer.hintRecording)
            )
        )
        for eventPlayer.index in range(len(eventPlayer.hintRecording)):
            logToInspector(
                "hint {} point {} {}".format(
                    eventPlayer.runCurrentCp,
                    eventPlayer.hintRecordTimes[eventPlayer.index],
                    eventPlayer.hintRecording[eventPlayer.index]
                )
            )
        for eventPlayer.index in range(len(eventPlayer.hintRecordActions)):
            logToInspector(
                "hint {} action {} {}".format(
                    eventPlayer.runCurrentCp,
                    hintActions[eventPlayer.runCurrentCp][eventPlayer.index],
                    eventPlayer.hintRecordAnchors[eventPlayer.index]
                )
            )
        logToInspector("hint {} end".format(eventPlayer.runCurrentCp))


rule "Load HUD":
    @Condition isHintRecorderOn == true

    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer == hostPlayer
            and not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and localPlayer.runCurrentCp < lastCp
        ),
        ("Hint Recorder | {}/{} CPs | This CP: {} | {}").format(
            len(hintRoutes.filter(lambda route: len(route) > 1)),
            lastCp,
            (
                "Recorded"
                if len(hintRoutes[localPlayer.runCurrentCp]) > 1
                else "Missing"
            ),
            (
                "Paused"
                if localPlayer.isInFreemode
                else (
                    "<fgFF4646FF>Recording...</fg>"
                    if len(localPlayer.hintRecording) > 1
                    else "Ready"
                )
            )
        ),
        HudPosition.TOP,
        3,
        Color.LIGHT_VIOLET,
        HudReeval.VISIBILITY_AND_STRING
    )
