#!mainFile "../main.opy"
#!rulePrefix "Timer"


rule "Start/Resume Run":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == true
    @Condition eventPlayer.runCurrentCp < lastCp
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    eventPlayer.isRunPaused = false
    chaseAtRate(eventPlayer.runTime, Math.INFINITY, 1)


rule "Update Run Format":
    @Event eachPlayer
    @Condition eventPlayer.isTimerActive == false
    @Condition eventPlayer.isRunPaused == false
    @Condition eventPlayer.isRunLoaded == true
    @Condition isDebugOn == false

    eventPlayer.isTimerActive = true
    while not eventPlayer.isRunPaused:
        wait(0.016 + getServerLoad() * 0.001)
        eventPlayer.timeToFormat = eventPlayer.runTime
        formatTime()
        eventPlayer.runTimeFormatted = eventPlayer.timeFormatted
        eventPlayer.timeToFormat = eventPlayer.runTime - eventPlayer.splitStart
        formatTime()
        eventPlayer.splitTimeFormatted = eventPlayer.timeFormatted
        eventPlayer.timeToFormat = eventPlayer.cpTime
        formatTime()
        eventPlayer.cpTimeFormatted = eventPlayer.timeFormatted
    eventPlayer.isTimerActive = false


def formatTime():
    @Name "Format Time"

    eventPlayer.timeToFormat = round(eventPlayer.timeToFormat * 100) / 100
    # Every part is built from a whole number, since a number's text drops trailing zeros
    # (65.10 would show as 1:05.1)
    eventPlayer.timeFormatted = "{}.{}".format(
        (
            (floor(eventPlayer.timeToFormat % 60) + 100).substring(1, 2)
            if eventPlayer.timeToFormat >= 60
            else floor(eventPlayer.timeToFormat)
        ),
        (round(eventPlayer.timeToFormat % 1 * 100) + 100).substring(1, 2)
    )
    if eventPlayer.timeToFormat >= 3600:
        eventPlayer.timeFormatted = "{}:{}:{}".format(
            floor(eventPlayer.timeToFormat / 3600),
            (floor(eventPlayer.timeToFormat % 3600 / 60) + 100).substring(1, 2),
            eventPlayer.timeFormatted
        )
    elif eventPlayer.timeToFormat >= 60:
        eventPlayer.timeFormatted = "{}:{}".format(
            floor(eventPlayer.timeToFormat / 60), eventPlayer.timeFormatted
        )


rule "Start Checkpoint Timer":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < lastCp
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    eventPlayer.isCpTimerActive = true
    chaseAtRate(eventPlayer.cpTime, Math.INFINITY, 1)


rule "Restart Checkpoint Timer":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isCpTimerActive == true
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.runCurrentCp < lastCp
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        <= eventPlayer.cpData[1]
    )

    eventPlayer.isCpTimerActive = false
    stopChasingVariable(eventPlayer.cpTime)
    eventPlayer.cpTime = 0
    # The run can be paused here (after freemode), which stops the formatting loop
    eventPlayer.cpTimeFormatted = "0.00"
