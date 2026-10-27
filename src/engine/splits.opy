#!mainFile "../main.opy"
#!rulePrefix "Splits"


macro NO_SPLIT_STATS = "Best: <fgFFFFFFFF>--</fg>\nAvg: <fgFFFFFFFF>--</fg>"


rule "Load HUD":
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and (
                localPlayer.viewCp < lastCp
                or localPlayer.viewRunner.isShowingSplitDelta
            )
        ),
        # Only the time is colored, so the label stays the HUD's orange
        ("\n\nCP {}: {}{}</fg>").format(
            (
                localPlayer.viewRunner.splitDelta[0]
                if localPlayer.viewRunner.isShowingSplitDelta
                else localPlayer.viewCp
            ),
            (
                localPlayer.viewRunner.splitDelta[2]
                if localPlayer.viewRunner.isShowingSplitDelta
                else (
                    "<fgFF4646FF>"
                    if localPlayer.viewRunner.runTime
                    - localPlayer.viewRunner.splitStart
                    > localPlayer.viewRunner.splitCpBest
                    else "<fgFFFFFFFF>"
                )
            ),
            (
                localPlayer.viewRunner.splitDelta[1]
                if localPlayer.viewRunner.isShowingSplitDelta
                else (
                    localPlayer.viewRunner.runTime - localPlayer.viewRunner.splitStart
                    if isDebugOn
                    else localPlayer.viewRunner.splitTimeFormatted
                )
            )
        ),
        HudPosition.RIGHT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Keeps showing the cleared CP's old Best and Avg during its delta, so the delta can be read against them
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and (
                localPlayer.viewCp < lastCp
                or localPlayer.viewRunner.isShowingSplitDelta
            )
        ),
        (
            localPlayer.viewRunner.splitDelta[3]
            if localPlayer.viewRunner.isShowingSplitDelta
            else (
                localPlayer.viewRunner.splitStatsFormatted[localPlayer.viewCp]
                if localPlayer.viewRunner.splitClears[localPlayer.viewCp]
                else NO_SPLIT_STATS
            )
        ),
        HudPosition.RIGHT,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and localPlayer.viewRunner.isShowingSplitDelta
        ),
        (
            "Time: <fgFFFFFFFF>{}</fg> <fg808080FF>|</fg> Total: <fgFFFFFFFF>{}</fg>"
        ).format(
            localPlayer.viewRunner.cpTimeFormatted,
            localPlayer.viewRunner.cpTotalTimeFormatted
        ),
        HudPosition.RIGHT,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Hide Delta":
    @Event eachPlayer
    @Condition eventPlayer.isShowingSplitDelta == true

    # After a clear, the HUD shows that CP's delta for 2s instead of the live split.
    # A flag instead of comparing the time in the HUD, which would run every tick for every player.
    # Another clear during the delta moves splitDelta[4] later.
    while getTotalTimeElapsed() < eventPlayer.splitDelta[4]:
        wait(eventPlayer.splitDelta[4] - getTotalTimeElapsed())
    eventPlayer.isShowingSplitDelta = false


def recordSplit():
    @Name "Record"

    # A split runs from entering the CP to clearing it, so resets and mistakes count toward it
    # splitDelta: [0]cp [1]deltaFormatted [2]colorTag [3]prevStatsFormatted [4]hideTime
    # Rounded to the hundredths shown, so a new best has to be at least 0.01 faster
    eventPlayer.splitTime = (
        round((eventPlayer.runTime - eventPlayer.splitStart) * 100) / 100
    )
    eventPlayer.splitDelta = [
        eventPlayer.runCurrentCp,
        "",
        "<fgFFFF00FF>",
        NO_SPLIT_STATS,
        getTotalTimeElapsed() + 2
    ]
    eventPlayer.isShowingSplitDelta = true
    eventPlayer.timeToFormat = eventPlayer.splitTime
    # A first clear has nothing to compare against, so it shows the time itself
    if not eventPlayer.splitClears[eventPlayer.runCurrentCp]:
        eventPlayer.splitBests[eventPlayer.runCurrentCp] = eventPlayer.splitTime
    else:
        eventPlayer.splitDelta[3] = eventPlayer.splitStatsFormatted[
            eventPlayer.runCurrentCp
        ]
        # A new best is compared to the old best, and anything else to the average
        if eventPlayer.splitTime < eventPlayer.splitBests[eventPlayer.runCurrentCp]:
            eventPlayer.timeToFormat -= eventPlayer.splitBests[eventPlayer.runCurrentCp]
            eventPlayer.splitBests[eventPlayer.runCurrentCp] = eventPlayer.splitTime
        else:
            eventPlayer.timeToFormat -= (
                eventPlayer.splitTotals[eventPlayer.runCurrentCp]
                / eventPlayer.splitClears[eventPlayer.runCurrentCp]
            )
            # Rounded first, so a delta that shows as +0.00 counts as a tie
            eventPlayer.timeToFormat = round(eventPlayer.timeToFormat * 100) / 100
            eventPlayer.splitDelta[2] = (
                "<fg00E092FF>"
                if eventPlayer.timeToFormat < 0
                else (
                    "<fgFF4646FF>" if eventPlayer.timeToFormat > 0 else "<fgFFFFFFFF>"
                )
            )
        eventPlayer.splitDelta[1] = "-" if eventPlayer.timeToFormat < 0 else "+"
        eventPlayer.timeToFormat = abs(eventPlayer.timeToFormat)
    formatTime()
    eventPlayer.splitDelta[1] = "{}{}".format(
        eventPlayer.splitDelta[1], eventPlayer.timeFormatted
    )
    eventPlayer.splitTotals[eventPlayer.runCurrentCp] += eventPlayer.splitTime
    eventPlayer.splitClears[eventPlayer.runCurrentCp]++
    eventPlayer.timeToFormat = eventPlayer.splitBests[eventPlayer.runCurrentCp]
    formatTime()
    eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp] = (
        eventPlayer.timeFormatted
    )
    eventPlayer.timeToFormat = (
        eventPlayer.splitTotals[eventPlayer.runCurrentCp]
        / eventPlayer.splitClears[eventPlayer.runCurrentCp]
    )
    formatTime()
    eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp] = (
        "Best: <fgFFFFFFFF>{}</fg>\nAvg: <fgFFFFFFFF>{}</fg>".format(
            eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp],
            eventPlayer.timeFormatted
        )
    )
