#!mainFile "../main.opy"
#!rulePrefix "Run"


# The player whose run a player's HUD follows: the one they're spectating, or themselves.
# Disconnected freecam (spectating[3]) doesn't follow anyone's run.
macro viewedRunner(player):
    (player.spectating[1] if player.spectating[0] else player)


# Everyone with a run out on the course: runners, then players in freemode or spectating
macro isOnScorecard(player):
    (not player.isDummy() and player.isRunLoaded and not player.isInLobby)


# Listed above the players in freemode, which finishing turns on, and spectating
macro isRunningOnScorecard(player):
    (not player.isInFreemode and not player.spectating[0])


# The scorecard's order within runners and within the rest: furthest, then fastest
macro scorecardOrder(player):
    (player.runTime - player.runCurrentCp * 100000)


# Everything a player's scorecard row shows but the time, so a change to it can refresh the
# scorecard at once. The CP stays under 1000, and the flags fit below 1.
macro scorecardKey(player):
    (
        player.runCurrentCp
        + player.runMistakes * 1000
        + player.isRunLegit * 0.5
        + isOnScorecard(player) * 0.25
        + player.isInFreemode * 0.125
        + player.spectating[0] * 0.0625
    )


# Whether the scorecard lists its rows: not when the only player listed is the viewer
macro scorecardHasRows(player):
    len(scorecardPlayers.exclude(player)) > 0


# How many runs the All-Time Top 3 lists: up to the leaderboard's first 3
macro allTimeRuns = min(lbRunCount, 3)


# Whether the scorecard and the Top 3s list rows: with players or runs to list, or on the
# HUD page, which lists made-up ones (Lobby: Load HUD Page), unless they're turned off
macro isScorecardShown(player):
    (
        (scorecardHasRows(player) or isHudPage(player))
        and isHudLineOn(player, HUD_SCORECARD)
    )


macro isAllTimeTopShown(player):
    ((allTimeRuns > 0 or isHudPage(player)) and isHudLineOn(player, HUD_ALL_TIME_TOP))


macro isLobbyTopShown(player):
    ((len(topRuns) > 0 or isHudPage(player)) and isHudLineOn(player, HUD_LOBBY_TOP))


# The blank lines above the CP, time and mistakes: 2 under the counters, or 5 standing in
# for them in disconnected freecam, which hides them, so the CP barely moves. With the
# counters all turned off there's nothing above, so none.
macro runStatsGap(player):
    (
        ""
        if areHudLinesOff(player, HUD_RUNS, 3)
        else ("\n\n\n\n\n" if player.spectating[3] else "\n\n")
    )


# The same for Time and Mistakes, which take them over when the lines above them are turned
# off, and don't show in disconnected freecam
macro hudLinesGap(player):
    ("" if areHudLinesOff(player, HUD_RUNS, 3) else "\n\n")


# Whether Disqualified shows: while the viewed run doesn't count, outside disconnected
# freecam. It can't be turned off, as it says the run won't count, and the HUD page shows
# it either way, struck through, so it's clear it stays.
macro isDisqualifiedShown(player):
    (
        isCourseHudShown(player)
        and not player.spectating[3]
        and (not player.viewRunner.isRunLegit or isHudPage(player))
    )


# Whether the splits show any line: before the last CP or during a delta, unless they're
# all turned off
macro areSplitsShown(player):
    (
        (player.viewCp < lastCp or player.viewRunner.isShowingSplitDelta)
        and not areHudLinesOff(player, HUD_SPLIT_CP, 6)
    )


# Fills out a scorecard column of 3 digits and its 3-space gap, as a digit is about as wide as 2 spaces
macro scorecardPad(value):
    "       ".substring(0, 3 + 2 * max(3 - strLen("{}".format(value)), 0))


rule "Sync Viewed Runner":
    @Event eachPlayer
    @Condition eventPlayer.viewRunner != viewedRunner(eventPlayer)

    eventPlayer.viewRunner = viewedRunner(eventPlayer)
    # Rechecks a tick later, like Sync Viewed Checkpoint
    wait()
    if RULE_CONDITION:
        loop()


rule "Load HUD":
    # A header, the biggest HUD text. The FAQ keeps the smaller one, as its own header goes
    # under it. Every line of the HUD can be turned off on the HUD page (hudHidden).
    hudHeader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_SITE)
        ),
        "ballkour.com",
        HudPosition.TOP,
        0,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.faqPage > 0
            and isHudLineOn(localPlayer, HUD_SITE)
        ),
        "ballkour.com",
        HudPosition.TOP,
        0,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY
    )
    # At the top left, with FAQ and Hints under it, in the smallest text. The lobby leaves it
    # out, as its controls are buttons there. Turned off, the lines under it move up, and Hints
    # ends in a blank line in its place, so the 3 lines keep their height and the lines under
    # them stay clear of the player's name tag on the 4th line (Controls: Load Hints HUD).
    runHudText = _("Controls: <fgFFFFFFFF>@0 (Hold)</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_CONTROLS)
        ),
        _(runHudText).replace("@0", inputBindingString(Button.ULTIMATE)),
        HudPosition.LEFT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Runs counts the runs finished or restarted (see Initialize New Run). Attempts counts the
    # CP's mistakes and clears, and Mistakes only its mistakes, over all the player's runs, like
    # its Best and Avg.
    # Subheaders, the smallest HUD text, so they stay quieter than the run's own numbers.
    # Only the numbers are white, so the labels stay the HUD's orange.
    # Attempts and Mistakes follow the runner's own CP, not viewCp, which syncs a tick later: a
    # clear would show the cleared CP's new count for that tick.
    # The CP keeps 2 blank lines under them, like the 2 above the splits, so the 3 sections read
    # apart. Hiding them gives it 5, about their height, so the CP barely moves (runStatsGap).
    counterHudText[0] = _("Runs: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and not localPlayer.spectating[3]
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_RUNS)
        ),
        _(counterHudText[0]).replace(
            "@0", ("<fgFFFFFFFF>{}</fg>").format(localPlayer.viewRunner.runCount)
        ),
        HudPosition.RIGHT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    counterHudText[1] = _("Attempts: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and not localPlayer.spectating[3]
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_ATTEMPTS)
        ),
        _(counterHudText[1]).replace(
            "@0",
            ("<fgFFFFFFFF>{}</fg>").format(
                localPlayer.viewRunner.cpAttempts[localPlayer.viewRunner.runCurrentCp]
            )
        ),
        HudPosition.RIGHT,
        0.1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    counterHudText[2] = _("Mistakes: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and not localPlayer.spectating[3]
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_CP_MISTAKES)
        ),
        _(counterHudText[2]).replace(
            "@0",
            ("<fgFFFFFFFF>{}</fg>").format(
                localPlayer.viewRunner.cpMistakes[localPlayer.viewRunner.runCurrentCp]
            )
        ),
        HudPosition.RIGHT,
        0.2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Each of these 3 ends in a blank line, and Mistakes in 2, which keep the splits apart.
    # A line turned off hands its blank lines to the one above, and the ones above it to the
    # one below. With all 3 off under a counter, the CP stays as just its blank lines, so the
    # counters stay apart from the splits.
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and localPlayer.faqPage == 0
            # Spelled out instead of areHudLinesOff, which the Workshop can't nest in a filter
            and (
                isHudLineOn(localPlayer, HUD_CP)
                or localPlayer.hudHidden[HUD_TIME]
                and localPlayer.hudHidden[HUD_MISTAKES]
                and not (
                    localPlayer.hudHidden[HUD_RUNS]
                    and localPlayer.hudHidden[HUD_ATTEMPTS]
                    and localPlayer.hudHidden[HUD_CP_MISTAKES]
                )
                and not localPlayer.spectating[3]
            )
        ),
        "{}{}".format(
            runStatsGap(localPlayer),
            (
                ("{} {}/{}\n{}").format(
                    iconString(Icon.FLAG),
                    localPlayer.viewCp,
                    lastCp,
                    (
                        "\n"
                        if areHudLinesOff(localPlayer, HUD_TIME, 2)
                        and not localPlayer.spectating[3]
                        else ""
                    )
                )
                if isHudLineOn(localPlayer, HUD_CP)
                else ""
            )
        ),
        HudPosition.RIGHT,
        1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Debug mode turns off Update Run Format, so it shows the raw time
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and not localPlayer.spectating[3]
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_TIME)
        ),
        ("{}{} {}\n{}").format(
            hudLinesGap(localPlayer) if localPlayer.hudHidden[HUD_CP] else "",
            iconString(Icon.BOLT),
            (
                localPlayer.viewRunner.runTime
                if isDebugOn
                else localPlayer.viewRunner.runTimeFormatted
            ),
            "\n" if localPlayer.hudHidden[HUD_MISTAKES] else ""
        ),
        HudPosition.RIGHT,
        1.1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and not localPlayer.spectating[3]
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_MISTAKES)
        ),
        ("{}{} {}\n\n").format(
            (
                hudLinesGap(localPlayer)
                if areHudLinesOff(localPlayer, HUD_CP, 2)
                else ""
            ),
            iconString(Icon.SKULL),
            localPlayer.viewRunner.runMistakes
        ),
        HudPosition.RIGHT,
        1.2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # At the top left, under Hints and above Freemode On, with a blank line above it like
    # Freemode On. Freemode On drops its own blank line while it shows, so the two sit together.
    # The HUD page shows it either way, as it's one of the lines it turns off.
    counterHudText[3] = _("\nDisqualified")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: isDisqualifiedShown(localPlayer)
            and localPlayer.faqPage == 0
        ),
        _(counterHudText[3]),
        HudPosition.LEFT,
        0.9,
        rgb(255, 70, 70),
        HudReeval.VISIBILITY_AND_STRING
    )
    # The All-Time Top 3, then the Lobby Top 3, at the bottom of the right column, under the
    # splits, in one HUD text so they left-align. Hiding the scorecard leaves them up. The
    # splits end without blank lines, so they bring 2; without the splits, Mistakes above
    # already ends in blank lines, and the CP while spectating ends in 1.
    # In the lobby, with nothing above them, they start at the top.
    allTimeRunsHudText = _("All-Time Top 3")
    topRunsHudText = _("Lobby Top 3")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: (
                isAllTimeTopShown(localPlayer) or isLobbyTopShown(localPlayer)
            )
            and localPlayer.faqPage == 0
        ),
        "{}{}{}".format(
            (
                "\n\n"
                if isCourseHudShown(localPlayer)
                and not localPlayer.spectating[3]
                and areSplitsShown(localPlayer)
                else ("\n" if localPlayer.spectating[3] else "")
            ),
            (
                "{}{}".format(
                    _(allTimeRunsHudText),
                    (hudPageAllTimeText if isHudPage(localPlayer) else allTimeRunsText)
                )
                if isAllTimeTopShown(localPlayer)
                else ""
            ),
            # A blank line between it and the All-Time Top 3
            (
                "{}{}{}".format(
                    "\n\n" if isAllTimeTopShown(localPlayer) else "",
                    _(topRunsHudText),
                    hudPageTopRunsText if isHudPage(localPlayer) else topRunsText
                )
                if isLobbyTopShown(localPlayer)
                else ""
            )
        ),
        HudPosition.RIGHT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Under Hints, the scorecard and the HUD page's line, in one HUD text so they left-align.
    # The scorecard only shows while someone other than the viewer is on it, as their own run
    # is on the right, and the HUD line wherever the course's HUD shows. A blank line keeps
    # them off the player's name tag on the 4th line, so the HUD line alone starts on the 5th,
    # like Disqualified. The scorecard's icons stand taller than a line, so it brings a
    # second blank line and starts on the 6th.
    scorecardHudText[0] = _("HUD: <fgFFFFFFFF>@0 + @1</fg>")
    # The rows stay out of the String Replace, which cuts off long strings, and they're too long for it
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                localPlayer.faqPage == 0
                and (
                    isScorecardShown(localPlayer)
                    or isCourseHudShown(localPlayer)
                    and isHudLineOn(localPlayer, HUD_PAGE_KEY)
                )
            )
        ),
        "{}\n{}{}".format(
            # The lobby hides Controls, FAQ and Hints, so 3 blank lines stand in for them and
            # it starts on the 6th line there too, without moving when the player leaves
            ("" if isCourseHudShown(localPlayer) else "\n\n\n"),
            (
                "\n{}\n".format(
                    hudPageScorecard if isHudPage(localPlayer) else scorecard
                )
                if isScorecardShown(localPlayer)
                else ""
            ),
            (
                _(scorecardHudText[0])
                .replace("@0", inputBindingString(Button.ULTIMATE))
                .replace("@1", inputBindingString(Button.CROUCH))
                if isCourseHudShown(localPlayer)
                and isHudLineOn(localPlayer, HUD_PAGE_KEY)
                else ""
            )
        ),
        HudPosition.LEFT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Update Scorecard":
    scorecardDirty = false
    # Two sorts joined, instead of one with an offset that would cost the times' precision
    scorecardPlayers = sorted(
        getAllPlayers().filter(lambda p: isOnScorecard(p) and isRunningOnScorecard(p)),
        lambda p: scorecardOrder(p)
    ).concat(
        sorted(
            getAllPlayers().filter(
                lambda p: isOnScorecard(p) and not isRunningOnScorecard(p)
            ),
            lambda p: scorecardOrder(p)
        )
    )
    # One string rebuilt on each change and each runner's second, instead of a HUD text per runner:
    # Overwatch reprocesses every HUD text's definition every 5s (see Translated HUD Text).
    # A string only shows its first 4 icons, so they head the columns instead of filling each row.
    scorecard = "{}    {}       {}".format(
        iconString(Icon.FLAG), iconString(Icon.BOLT), iconString(Icon.SKULL)
    )
    scorecardRows = len(scorecardPlayers)
    for index in range(len(scorecardPlayers)):
        scorecardTime = scorecardPlayers[index].runTimeFormatted.split(".")[0]
        # The time's column fits h:mm:ss. Its padding is by length, since colons are narrower than digits.
        scorecardRow = "{}{}{}{}{}{}{}".format(
            scorecardPlayers[index].runCurrentCp,
            scorecardPad(scorecardPlayers[index].runCurrentCp),
            scorecardTime,
            "             ".substring(
                0, [0, 13, 11, 0, 7, 5, 0, 2][strLen(scorecardTime)]
            ),
            scorecardPlayers[index].runMistakes,
            scorecardPad(scorecardPlayers[index].runMistakes),
            scorecardPlayers[index]
        )
        # Players spectating are blue, like Spectating, and in freemode violet, like Freemode
        # On, disqualified or not. Disqualified runners are red, like Disqualified at the
        # top left. Disqualified runs also get a red × after the name, outside the row's color
        # so it's red on blue and violet rows too, and for anyone who can't tell red from orange.
        scorecard = "{}\n{}{}".format(
            scorecard,
            (
                "<fg00BEFFFF>{}</fg>".format(scorecardRow)
                if scorecardPlayers[index].spectating[0]
                else (
                    "<fgCB87FFFF>{}</fg>".format(scorecardRow)
                    if scorecardPlayers[index].isInFreemode
                    else (
                        scorecardRow
                        if scorecardPlayers[index].isRunLegit
                        else "<fgFF4646FF>{}</fg>".format(scorecardRow)
                    )
                )
            ),
            "" if scorecardPlayers[index].isRunLegit else " <fgFF4646FF>×</fg>"
        )
    # A change or a runner's next second (see Update Run Format) rebuilds it within 0.1s. Rebuilding
    # on the next tick added ~20% to peak server load while Next CP was held with 12 rows.
    wait(0.1)
    waitUntil(scorecardDirty == true, Math.INFINITY)
    loop()


rule "Refresh Scorecard On Change":
    @Event eachPlayer
    @Condition eventPlayer.scorecardKey != scorecardKey(eventPlayer)

    eventPlayer.scorecardKey = scorecardKey(eventPlayer)
    scorecardDirty = true
    # Rechecks a tick later, like Sync Viewed Checkpoint
    wait()
    if RULE_CONDITION:
        loop()


def newRun():
    @Name "Initialize New Run"

    eventPlayer.isLoading = true
    if eventPlayer.spectating[0]:
        disableSpectator()
    if eventPlayer.isInLobby:
        leaveLobby()
    # A run counts once it ends: here if it's restarted after leaving the first CP, or when it's finished
    if (
        eventPlayer.isRunLoaded
        and not eventPlayer.isRunFinished
        and eventPlayer.runTime > 0
    ):
        eventPlayer.runCount++
    resetRun()
    syncSpectatorCps()
    loadCpData()
    setCpAbilities()
    cpResetPlayer()
    faceNextCp()
    showCpNameplate()
    eventPlayer.isLoading = false


def resetRun():
    @Name "Reset"

    eventPlayer.isRunLoaded = false
    eventPlayer.isRunLoaded = true
    eventPlayer.isRunPaused = true
    eventPlayer.isInFreemode = false
    eventPlayer.isRunFinished = false
    eventPlayer.isRunLegit = true
    eventPlayer.runCurrentCp = 0
    eventPlayer.runFurthestCp = 0
    eventPlayer.runTime = 0
    eventPlayer.runTimeFormatted = "0.00"
    # A restart that leaves the row's CP and mistakes as they were still clears its time
    eventPlayer.scorecardSecond = 0
    scorecardDirty = true
    eventPlayer.runMistakes = 0
    # A delta still showing from the last run's clear would hide the new run's live times
    eventPlayer.isShowingSplitDelta = false
    # Pace projects each run from its own splits, unlike the per-CP Best and Avg
    eventPlayer.paceSplitTotal = 0
    eventPlayer.paceSplitClears = 0
    resetCpMistakes()


def pauseRun():
    @Name "Pause"

    # Pausing mid-attempt (outside the checkpoint ring) counts as a mistake
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            addMistake()
