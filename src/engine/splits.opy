#!mainFile "../main.opy"
#!rulePrefix "Splits"


macro NO_SPLIT_STATS = "Best   --\nAvg   --"


# After a clear, the HUD shows that CP's delta for 2s instead of the live split
macro isShowingSplitDelta(runner):
    getTotalTimeElapsed() < runner.splitDelta[4]


rule "Load HUD":
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and (
                localPlayer.viewCp < lastCp
                or isShowingSplitDelta(localPlayer.viewRunner)
            )
        ),
        ("\nCP {}   {}").format(
            (
                localPlayer.viewRunner.splitDelta[0]
                if isShowingSplitDelta(localPlayer.viewRunner)
                else localPlayer.viewCp
            ),
            (
                localPlayer.viewRunner.splitDelta[1]
                if isShowingSplitDelta(localPlayer.viewRunner)
                else (
                    localPlayer.viewRunner.runTime - localPlayer.viewRunner.splitStart
                    if settings_[0]
                    else localPlayer.viewRunner.splitTimeFormatted
                )
            )
        ),
        HudPosition.RIGHT,
        3,
        (
            localPlayer.viewRunner.splitDelta[2]
            if isShowingSplitDelta(localPlayer.viewRunner)
            else (
                rgb(255, 70, 70)
                if localPlayer.viewRunner.splitClears[localPlayer.viewCp]
                and localPlayer.viewRunner.runTime - localPlayer.viewRunner.splitStart
                > localPlayer.viewRunner.splitBests[localPlayer.viewCp]
                else rgb(230, 151, 0)
            )
        ),
        HudReeval.VISIBILITY_STRING_AND_COLOR
    )
    # Keeps showing the cleared CP's old Best and Avg during its delta, so the delta can be read against them
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and (
                localPlayer.viewCp < lastCp
                or isShowingSplitDelta(localPlayer.viewRunner)
            )
        ),
        (
            localPlayer.viewRunner.splitDelta[3]
            if isShowingSplitDelta(localPlayer.viewRunner)
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
            and isShowingSplitDelta(localPlayer.viewRunner)
        ),
        ("Time: {} | Total: {}").format(
            localPlayer.viewRunner.cpTimeFormatted,
            localPlayer.viewRunner.cpTotalTimeFormatted
        ),
        HudPosition.RIGHT,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


def recordSplit():
    @Name "Record"

    # A split runs from entering the CP to clearing it, so resets and mistakes count toward it
    # splitDelta: [0]cp [1]deltaFormatted [2]color [3]prevStatsFormatted [4]hideTime
    # Rounded to the hundredths shown, so a new best has to be at least 0.01 faster
    eventPlayer.splitTime = round((eventPlayer.runTime - eventPlayer.splitStart) * 100) / 100
    eventPlayer.splitDelta = [
        eventPlayer.runCurrentCp,
        "",
        rgb(255, 255, 0),
        NO_SPLIT_STATS,
        getTotalTimeElapsed() + 2
    ]
    eventPlayer.timeToFormat = eventPlayer.splitTime
    # A first clear has nothing to compare against, so it shows the time itself
    if not eventPlayer.splitClears[eventPlayer.runCurrentCp]:
        eventPlayer.splitBests[eventPlayer.runCurrentCp] = eventPlayer.splitTime
    else:
        eventPlayer.splitDelta[3] = eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp]
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
                Color.GREEN
                if eventPlayer.timeToFormat < 0
                else (rgb(255, 70, 70) if eventPlayer.timeToFormat > 0 else rgb(230, 151, 0))
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
    eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp] = eventPlayer.timeFormatted
    eventPlayer.timeToFormat = (
        eventPlayer.splitTotals[eventPlayer.runCurrentCp]
        / eventPlayer.splitClears[eventPlayer.runCurrentCp]
    )
    formatTime()
    eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp] = "Best   {}\nAvg   {}".format(
        eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp], eventPlayer.timeFormatted
    )
