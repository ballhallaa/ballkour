#!mainFile "../main.opy"
#!rulePrefix "Run"


# The player whose run a player's HUD follows: the one they're spectating, or themselves.
# Disconnected freecam (spectating[3]) doesn't follow anyone's run.
macro viewedRunner(player):
    (player.spectating[1] if player.spectating[0] else player)


# Every player in the game, bots aside
macro isOnScorecard(player):
    (not player.isDummy())


# Whether the player is on a CP skipped to, past the furthest one cleared. A skip only
# disqualifies the run once the player leaves that CP, so it can be looked at and skipped
# back from (Timer: Start/Resume Run, Mistake: Missed Checkpoint). A skip onto the last CP
# disqualifies it at once, as reaching it finishes the run.
macro isOnSkippedCp(player):
    (player.runCurrentCp > player.runFurthestCp)


# The scorecard's sections, top to bottom: runners, disqualified runners, players in Assist
# Mode, players in freemode, which finishing turns on, or Practice Mode, players spectating,
# and players in the lobby, along with new players on their way there, who have no run yet
macro SCORECARD_SECTIONS = 6


macro scorecardSectionOf(player):
    (
        5
        if player.isInLobby or not player.isRunLoaded
        else (
            4
            if player.spectating[0]
            else (
                3
                if player.isInFreemode or player.isInPracticeMode
                else (2 if player.isInAssistMode else (0 if player.isRunLegit else 1))
            )
        )
    )


# The scorecard's order within each section: furthest, then fastest. A spectator's CP is the
# one they're watching, as on their HUD (viewCp).
macro scorecardOrder(player):
    (player.runTime - player.viewCp * 100000)


# Everything a player's scorecard row shows but the time, and its section, so a change to
# them can refresh the scorecard at once. The CP stays under 1000, and the flags fit below 1.
macro scorecardKey(player):
    (
        player.viewCp
        + player.runMistakes * 1000
        + player.isRunLegit * 0.5
        + scorecardSectionOf(player) * 0.0625
    )


# A Top 3 row (Lobby: Load Leaderboard, Completion: Record Top Run) added to topText: rank,
# time, mistakes and name, in the rank's color, with a pink • after it if topMarked. Padded
# like the scorecard's columns, but for 2-digit mistakes, and times of 7+ characters.
macro topRunRow(topText, topRank, topName, topMistakes, topTime, topMarked):
    "{}\n{}{}   {}{}{}×{}{}</fg>{}".format(
        topText,
        ["<fgFFFF00FF>", "<fgB0C4DEFF>", "<fgC46A30FF>"][topRank],
        topRank + 1,
        topTime,
        "     " if strLen(topTime) < 8 else "   ",
        topMistakes,
        "     " if strLen("{}".format(topMistakes)) < 2 else "   ",
        topName,
        "<fgFF80C0FF>•</fg>" if topMarked else ""
    )


# A Lobby Top 3 row for a rank no run holds yet, with the leaderboard's placeholders,
# laid out like topRunRow
macro topRunPlaceholderRow(topText, topRank):
    "{}\n{}{}   -:--.--     -×     ---</fg>".format(
        topText, ["<fgFFFF00FF>", "<fgB0C4DEFF>", "<fgC46A30FF>"][topRank], topRank + 1
    )


# Whether the scorecard lists its rows: not when the only player listed is the viewer
macro scorecardHasRows(player):
    len(scorecardPlayers.exclude(player)) > 0


# Whether the scorecard and the Top 3s list rows: with players or runs to list, or on the
# HUD page, which lists made-up ones (Lobby: Load HUD Page), unless they're turned off.
macro isScorecardShown(player):
    (
        (scorecardHasRows(player) or isHudPage(player))
        and isHudLineOn(player, HUD_SCORECARD)
    )


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


# Whether Disqualified shows: while the viewed run doesn't count, or the viewed runner is in
# Assist Mode (see isAssistModeShown), outside disconnected freecam. It can't be turned off, as
# it says the run won't count, or which leaderboard it's for, and the HUD page shows both on its
# row, struck through, so it's clear they stay. (Freemode On can show with Assist Mode On, so it
# has a row of its own.)
macro isDisqualifiedShown(player):
    (
        isCourseHudShown(player)
        and not player.spectating[3]
        and (
            not player.viewRunner.isRunLegit
            or player.viewRunner.isInAssistMode
            or isHudPage(player)
        )
    )


# Whether Disqualified says Assist Mode instead: while the viewed runner is in it, unless the
# run is disqualified, which counts for neither leaderboard then (Disqualified shows Assist
# Mode On under it then), and apart from on the HUD page, whose row for the line says
# Disqualified
macro isAssistModeShown(player):
    (
        player.viewRunner.isInAssistMode
        and player.viewRunner.isRunLegit
        and not isHudPage(player)
    )


# Whether the All-Time Top 3 lists rows: with runs to list, or on the HUD page, unless it's
# turned off. It stays off in the lobby, where the leaderboard already lists those runs.
macro isAllTimeTopShown(player):
    (
        (
            (lbRunCount > 0 or assistedRunCount > 0)
            and not player.isInLobby
            or isHudPage(player)
        )
        and isHudLineOn(player, HUD_ALL_TIME_TOP)
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
    # In Assist Mode it says Assist Mode On instead, in pink, as the run is for the assisted
    # leaderboard. One text for both, as texts are capped at 128 per server (Lobby: Load
    # Buttons), and neither can be turned off (isDisqualifiedShown). A disqualified run in
    # Assist Mode shows both, Disqualified with Assist Mode On under it in pink, so the mode
    # still shows. The HUD page shows both, Assist Mode On / Disqualified, like its row.
    counterHudText[3] = _("\nDisqualified")
    counterHudText[4] = _("\nAssist Mode On")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: isDisqualifiedShown(localPlayer)
            and localPlayer.faqPage == 0
        ),
        (
            _(counterHudText[4])
            if isAssistModeShown(localPlayer)
            else (
                "\n<fgFF80C0FF>{}</fg> / {}".format(
                    _(counterHudText[4]).replace("\n", ""),
                    _(counterHudText[3]).replace("\n", "")
                )
                if isHudPage(localPlayer)
                else (
                    "{}\n<fgFF80C0FF>{}</fg>".format(
                        _(counterHudText[3]), _(counterHudText[4]).replace("\n", "")
                    )
                    if localPlayer.viewRunner.isInAssistMode
                    else _(counterHudText[3])
                )
            )
        ),
        HudPosition.LEFT,
        0.9,
        rgb(255, 128, 192) if isAssistModeShown(localPlayer) else rgb(255, 70, 70),
        HudReeval.VISIBILITY_STRING_AND_COLOR
    )
    # The All-Time Top 3, then the Lobby Top 3, at the bottom of the right column, under the
    # splits, in one HUD text so they left-align. Hiding the scorecard leaves them up. The
    # splits end without blank lines, so they bring 2; without the splits, Mistakes above
    # already ends in blank lines, and the CP while spectating ends in 1.
    # In the lobby, with nothing above it, the Lobby Top 3 starts at the top.
    # The All-Time Top 3 lists the leaderboard's runs, with (Unassisted) after its title, or
    # in Assist Mode the assisted one's, with a pink (Assisted). The Lobby Top 3 lists the
    # lobby's assisted runs with the rest, marked with a pink •.
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
                "{}{}{}".format(
                    _(allTimeRunsHudText),
                    (
                        " <fgFF80C0FF>({})</fg>".format(_(lobbyHudText[14]))
                        if isAssistModeShown(localPlayer)
                        else " ({})".format(_(lobbyHudText[13]))
                    ),
                    (
                        hudPageAllTimeText
                        if isHudPage(localPlayer)
                        else (
                            allTimeAssistedText
                            if isAssistModeShown(localPlayer)
                            else allTimeRunsText
                        )
                    )
                )
                if isAllTimeTopShown(localPlayer)
                else ""
            ),
            # A blank line between it and the All-Time Top 3
            (
                "{}{}{}".format(
                    "\n\n" if isAllTimeTopShown(localPlayer) else "",
                    _(topRunsHudText),
                    (hudPageTopRunsText if isHudPage(localPlayer) else topRunsText)
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
    # Under Hints, the scorecard, which only shows while someone other than the viewer is on
    # it, as their own run is on the right. Its icons stand taller than a line, so two blank
    # lines keep it off the player's name tag on the 4th line, and it starts on the 6th.
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                localPlayer.faqPage == 0 and isScorecardShown(localPlayer)
            )
        ),
        "{}\n\n{}".format(
            # The lobby hides Controls, FAQ and Hints, so 3 blank lines stand in for them and
            # it starts on the 6th line there too, without moving when the player leaves
            ("" if isCourseHudShown(localPlayer) else "\n\n\n"),
            hudPageScorecard if isHudPage(localPlayer) else scorecard
        ),
        HudPosition.LEFT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Update Scorecard":
    scorecardDirty = false
    # One sort split into its sections in order, instead of a sort with an offset per section
    # that would cost the times' precision
    scorecardSorted = sorted(
        getAllPlayers().filter(lambda p: isOnScorecard(p)), lambda p: scorecardOrder(p)
    )
    scorecardPlayers = []
    for index in range(SCORECARD_SECTIONS):
        scorecardPlayers = scorecardPlayers.concat(
            scorecardSorted.filter(lambda p: p.scorecardSection == index)
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
            scorecardPlayers[index].viewCp,
            scorecardPad(scorecardPlayers[index].viewCp),
            scorecardTime,
            "             ".substring(
                0, [0, 13, 11, 0, 7, 5, 0, 2][strLen(scorecardTime)]
            ),
            scorecardPlayers[index].runMistakes,
            scorecardPad(scorecardPlayers[index].runMistakes),
            scorecardPlayers[index]
        )
        # Each section in its own color, disqualified or not: runners in the HUD's orange,
        # disqualified runners red, like Disqualified at the top left, Assist Mode pink, like
        # its own line there, freemode violet, like Freemode On, spectating blue, like
        # Spectating, and the lobby gray, like the lobby's grayed-out buttons. Disqualified
        # runs also get a red × after the name, outside the row's color so it's red on every
        # row, and for anyone who can't tell red from orange.
        # Runs still assisted after their player left Assist Mode get a pink • after the
        # name, like the Lobby Top 3's assisted runs. Runs that still count on a CP skipped
        # to (isOnSkippedCp) get a red •, as their CP wasn't reached by clearing, until
        # leaving it turns it into the ×, also in the lobby, which keeps the run paused on
        # that CP. Spectators' rows show the CP they watch, not theirs, so they don't get it.
        # A change to either mark changes the CP or the section too, which refreshes the
        # scorecard (scorecardKey).
        scorecard = "{}\n{}{}{}{}{}{}".format(
            scorecard,
            [
                "",
                "<fgFF4646FF>",
                "<fgFF80C0FF>",
                "<fgCB87FFFF>",
                "<fg00BEFFFF>",
                "<fg808080FF>"
            ][scorecardPlayers[index].scorecardSection],
            scorecardRow,
            "</fg>" if scorecardPlayers[index].scorecardSection else "",
            (
                "<fgFF80C0FF>•</fg>"
                if scorecardPlayers[index].isRunAssisted
                and not scorecardPlayers[index].isInAssistMode
                else ""
            ),
            (
                "<fgFF4646FF>•</fg>"
                if scorecardPlayers[index].isRunLegit
                and isOnSkippedCp(scorecardPlayers[index])
                and scorecardPlayers[index].scorecardSection != 4
                else ""
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
    # Kept for Update Scorecard, so its rebuilds read each player's section instead of
    # working it out again
    eventPlayer.scorecardSection = scorecardSectionOf(eventPlayer)
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
    eventPlayer.isInPracticeMode = false
    eventPlayer.isRunFinished = false
    eventPlayer.isRunLegit = true
    # Assist Mode stays on through New Run, so the new run is an assisted one too
    eventPlayer.isRunAssisted = eventPlayer.isInAssistMode
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
