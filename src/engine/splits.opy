#!mainFile "../main.opy"
#!rulePrefix "Splits"


# Stats: [0]attemptBest [1]attemptAvg [2]splitBest [3]splitAvg, formatted
macro NO_SPLIT_STATS = ["--", "--", "--", "--"]


# Keeps showing the cleared CP's old stats during its delta, so the deltas can be read against them
macro viewedSplitStats(player):
    (
        player.viewRunner.splitDelta[3]
        if player.viewRunner.isShowingSplitDelta
        else (
            player.viewRunner.splitStatsFormatted[player.viewCp]
            if player.viewRunner.splitClears[player.viewCp]
            else NO_SPLIT_STATS
        )
    )


macro SPLITS_HUD_VISIBILITY = getAllPlayers().filter(
    lambda localPlayer: not localPlayer.isInLobby
    and not localPlayer.spectating[3]
    and (localPlayer.viewCp < lastCp or localPlayer.viewRunner.isShowingSplitDelta)
)


rule "Load HUD":
    # A header, the biggest HUD text, so the CP stands above the times under it.
    # A flag icon instead of a word, so it needs no translation and stays narrow in every language.
    hudHeader(
        SPLITS_HUD_VISIBILITY,
        "{} {}".format(
            iconString(Icon.FLAG),
            (
                localPlayer.viewRunner.splitDelta[0]
                if localPlayer.viewRunner.isShowingSplitDelta
                else localPlayer.viewCp
            )
        ),
        HudPosition.RIGHT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Best and Avg are subheaders, which Overwatch draws smaller than text, so the times stand out.
    # Each part is its own HUD text: Overwatch left-aligns the lines inside one HUD text but
    # centers HUD texts against each other, so this centers each Best and Avg under its time.
    # Only the times are colored, so the labels stay the HUD's orange.
    splitsHudText[0] = _("Attempt: @0")
    hudSubtext(
        SPLITS_HUD_VISIBILITY,
        _(splitsHudText[0]).replace(
            "@0",
            (
                localPlayer.viewRunner.splitDelta[1]
                if localPlayer.viewRunner.isShowingSplitDelta
                else ("{}{}</fg>").format(
                    (
                        "<fgFF4646FF>"
                        if localPlayer.viewRunner.cpTime
                        > localPlayer.viewRunner.attemptCpBest
                        else "<fgFFFFFFFF>"
                    ),
                    (
                        localPlayer.viewRunner.cpTime
                        if isDebugOn
                        else localPlayer.viewRunner.cpTimeFormatted
                    )
                )
            )
        ),
        HudPosition.RIGHT,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    splitsHudText[1] = _(
        "Best: <fgFFFFFFFF>@0</fg>"
        "\nAvg: <fgFFFFFFFF>@1</fg>"
    )
    hudSubheader(
        SPLITS_HUD_VISIBILITY,
        _(splitsHudText[1])
        .replace("@0", viewedSplitStats(localPlayer)[0])
        .replace("@1", viewedSplitStats(localPlayer)[1]),
        HudPosition.RIGHT,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    splitsHudText[2] = _("Split: @0")
    hudSubtext(
        SPLITS_HUD_VISIBILITY,
        _(splitsHudText[2]).replace(
            "@0",
            (
                localPlayer.viewRunner.splitDelta[2]
                if localPlayer.viewRunner.isShowingSplitDelta
                else ("{}{}</fg>").format(
                    (
                        "<fgFF4646FF>"
                        if localPlayer.viewRunner.runTime
                        - localPlayer.viewRunner.splitStart
                        > localPlayer.viewRunner.splitCpBest
                        else "<fgFFFFFFFF>"
                    ),
                    (
                        localPlayer.viewRunner.runTime
                        - localPlayer.viewRunner.splitStart
                        if isDebugOn
                        else localPlayer.viewRunner.splitTimeFormatted
                    )
                )
            )
        ),
        HudPosition.RIGHT,
        6,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    splitsHudText[3] = _(
        "Best: <fgFFFFFFFF>@0</fg>"
        "\nAvg: <fgFFFFFFFF>@1</fg>"
    )
    hudSubheader(
        SPLITS_HUD_VISIBILITY,
        _(splitsHudText[3])
        .replace("@0", viewedSplitStats(localPlayer)[2])
        .replace("@1", viewedSplitStats(localPlayer)[3]),
        HudPosition.RIGHT,
        7,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # The ETA turns red while it's rising: the current split has run past the average split
    splitsHudText[4] = _("\nETA: @0")
    hudSubtext(
        SPLITS_HUD_VISIBILITY,
        _(splitsHudText[4]).replace(
            "@0",
            ("{}{}</fg>").format(
                (
                    "<fgFF4646FF>"
                    if localPlayer.viewRunner.runTime
                    - localPlayer.viewRunner.splitStart
                    > localPlayer.viewRunner.paceSplit
                    else "<fgFFFFFFFF>"
                ),
                (
                    localPlayer.viewRunner.paceEta
                    + max(
                        0,
                        localPlayer.viewRunner.runTime
                        - localPlayer.viewRunner.splitStart
                        - localPlayer.viewRunner.paceSplit
                    )
                    if isDebugOn
                    else localPlayer.viewRunner.paceEtaFormatted
                )
            )
        ),
        HudPosition.RIGHT,
        8,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Hide Delta":
    @Event eachPlayer
    @Condition eventPlayer.isShowingSplitDelta == true

    # After a clear, the HUD shows that CP's deltas for 2s instead of the live times.
    # A flag instead of comparing the time in the HUD, which would run every tick for every player.
    # Another clear during the delta moves splitDelta[4] later.
    while getTotalTimeElapsed() < eventPlayer.splitDelta[4]:
        wait(eventPlayer.splitDelta[4] - getTotalTimeElapsed())
    eventPlayer.isShowingSplitDelta = false


def recordSplit():
    @Name "Record"

    # Each clear records two times: the attempt that cleared the CP, timed from leaving it,
    # and the split from entering the CP to clearing it, which resets and mistakes count toward
    # splitDelta: [0]cp [1]attemptFormatted [2]splitFormatted [3]prevStatsFormatted [4]hideTime
    # Rounded to the hundredths shown, so a new best has to be at least 0.01 faster
    eventPlayer.cpTime = round(eventPlayer.cpTime * 100) / 100
    eventPlayer.splitTime = (
        round((eventPlayer.runTime - eventPlayer.splitStart) * 100) / 100
    )
    eventPlayer.splitDelta = [
        eventPlayer.runCurrentCp,
        "",
        "",
        NO_SPLIT_STATS,
        getTotalTimeElapsed() + 2
    ]
    eventPlayer.isShowingSplitDelta = true
    # A first clear has nothing to compare against, so its times show in yellow without a delta
    if not eventPlayer.splitClears[eventPlayer.runCurrentCp]:
        eventPlayer.attemptBests[eventPlayer.runCurrentCp] = eventPlayer.cpTime
        eventPlayer.splitBests[eventPlayer.runCurrentCp] = eventPlayer.splitTime
        eventPlayer.timeToFormat = eventPlayer.cpTime
        formatTime()
        eventPlayer.splitDelta[1] = "<fgFFFF00FF>{}</fg>".format(
            eventPlayer.timeFormatted
        )
        eventPlayer.timeToFormat = eventPlayer.splitTime
        formatTime()
        eventPlayer.splitDelta[2] = "<fgFFFF00FF>{}</fg>".format(
            eventPlayer.timeFormatted
        )
    else:
        eventPlayer.splitDelta[3] = eventPlayer.splitStatsFormatted[
            eventPlayer.runCurrentCp
        ]
        # A new best is compared to the old best, and anything else to the average
        eventPlayer.timeToFormat = eventPlayer.cpTime
        eventPlayer.splitDiff = eventPlayer.cpTime - (
            eventPlayer.attemptBests[eventPlayer.runCurrentCp]
            if eventPlayer.cpTime < eventPlayer.attemptBests[eventPlayer.runCurrentCp]
            else eventPlayer.attemptTotals[eventPlayer.runCurrentCp]
            / eventPlayer.splitClears[eventPlayer.runCurrentCp]
        )
        formatSplitResult()
        eventPlayer.splitDelta[1] = eventPlayer.splitResult
        eventPlayer.timeToFormat = eventPlayer.splitTime
        eventPlayer.splitDiff = eventPlayer.splitTime - (
            eventPlayer.splitBests[eventPlayer.runCurrentCp]
            if eventPlayer.splitTime < eventPlayer.splitBests[eventPlayer.runCurrentCp]
            else eventPlayer.splitTotals[eventPlayer.runCurrentCp]
            / eventPlayer.splitClears[eventPlayer.runCurrentCp]
        )
        formatSplitResult()
        eventPlayer.splitDelta[2] = eventPlayer.splitResult
        eventPlayer.attemptBests[eventPlayer.runCurrentCp] = min(
            eventPlayer.attemptBests[eventPlayer.runCurrentCp], eventPlayer.cpTime
        )
        eventPlayer.splitBests[eventPlayer.runCurrentCp] = min(
            eventPlayer.splitBests[eventPlayer.runCurrentCp], eventPlayer.splitTime
        )
    eventPlayer.attemptTotals[eventPlayer.runCurrentCp] += eventPlayer.cpTime
    eventPlayer.splitTotals[eventPlayer.runCurrentCp] += eventPlayer.splitTime
    eventPlayer.paceSplitTotal += eventPlayer.splitTime
    eventPlayer.paceSplitClears++
    eventPlayer.splitClears[eventPlayer.runCurrentCp]++
    # In the same order as NO_SPLIT_STATS
    eventPlayer.splitResult = [
        eventPlayer.attemptBests[eventPlayer.runCurrentCp],
        eventPlayer.attemptTotals[eventPlayer.runCurrentCp]
        / eventPlayer.splitClears[eventPlayer.runCurrentCp],
        eventPlayer.splitBests[eventPlayer.runCurrentCp],
        eventPlayer.splitTotals[eventPlayer.runCurrentCp]
        / eventPlayer.splitClears[eventPlayer.runCurrentCp]
    ]
    for eventPlayer.index in range(4):
        eventPlayer.timeToFormat = eventPlayer.splitResult[eventPlayer.index]
        formatTime()
        eventPlayer.splitResult[eventPlayer.index] = eventPlayer.timeFormatted
    eventPlayer.splitStatsFormatted[eventPlayer.runCurrentCp] = eventPlayer.splitResult


def formatSplitResult():
    @Name "Format Result"

    # Formats a time just recorded (timeToFormat) into splitResult, followed by its delta
    # (splitDiff), which is green when faster and red when slower
    formatTime()
    # Rounded first, so a delta that shows as +0.00 counts as a tie
    eventPlayer.splitDiff = round(eventPlayer.splitDiff * 100) / 100
    eventPlayer.splitResult = "<fgFFFFFFFF>{}</fg> {}".format(
        eventPlayer.timeFormatted,
        (
            "<fg00E092FF>(-"
            if eventPlayer.splitDiff < 0
            else ("<fgFF4646FF>(+" if eventPlayer.splitDiff > 0 else "<fgFFFFFFFF>(+")
        )
    )
    eventPlayer.timeToFormat = abs(eventPlayer.splitDiff)
    formatTime()
    eventPlayer.splitResult = "{}{})</fg>".format(
        eventPlayer.splitResult, eventPlayer.timeFormatted
    )


def loadPace():
    @Name "Load Pace"

    # paceEta is the time the current CP started at plus the average of the run's splits so far
    # for each CP left, so 100 CPs at an average of 10 minutes estimate 1000 minutes.
    # Once the current split runs past the average, Update Run Format adds the extra time.
    # Nothing to estimate from until the first clear, so it never turns red
    if not eventPlayer.paceSplitClears:
        eventPlayer.paceEta = 0
        eventPlayer.paceEtaFormatted = "--"
        eventPlayer.paceSplit = Math.INFINITY
        return
    eventPlayer.paceSplit = eventPlayer.paceSplitTotal / eventPlayer.paceSplitClears
    eventPlayer.paceEta = (
        eventPlayer.splitStart
        + (lastCp - eventPlayer.runCurrentCp) * eventPlayer.paceSplit
    )
    eventPlayer.timeToFormat = eventPlayer.paceEta
    formatTime()
    eventPlayer.paceEtaFormatted = eventPlayer.timeFormatted
