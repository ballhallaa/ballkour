#!mainFile "../main.opy"
#!rulePrefix "Run"


# The player whose run a player's HUD follows: the one they're spectating, or themselves.
# Disconnected freecam (spectating[3]) doesn't follow anyone's run.
macro viewedRunner(player):
    (player.spectating[1] if player.spectating[0] else player)


# A finished run stays listed, even though finishing turns on freemode
macro isOnScorecard(player):
    (
        not player.isDummy()
        and player.isRunLoaded
        and not player.isInLobby
        and not player.spectating[0]
        and (player.isRunFinished or not player.isInFreemode)
    )


# Everything a player's scorecard row shows but the time, so a change to it can refresh the
# scorecard at once. The CP stays under 1000, and the flags fit below 1.
macro scorecardKey(player):
    (
        player.runCurrentCp
        + player.runMistakes * 1000
        + player.isRunLegit * 0.5
        + isOnScorecard(player) * 0.25
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
    # A header, the biggest HUD text. The Q&A keeps the smaller one, as its own header goes
    # under it.
    hudHeader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.qaPage == 0),
        "ballkour.com",
        HudPosition.TOP,
        0,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY
    )
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: localPlayer.qaPage > 0),
        "ballkour.com",
        HudPosition.TOP,
        0,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY
    )
    runHudText = _("\n\n\n\nControls: <fgFFFFFFFF>@0 (Hold)</fg>")
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: localPlayer.qaPage == 0),
        _(runHudText).replace("@0", inputBindingString(Button.ULTIMATE)),
        HudPosition.LEFT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Runs counts the runs finished or restarted (see Initialize New Run). Attempts counts the
    # CP's mistakes and clears, over all the player's runs, like its Best and Avg.
    # Subheaders, the smallest HUD text, so they stay quieter than the run's own numbers.
    # Attempts follows the runner's own CP, not viewCp, which syncs a tick later: a clear would
    # show the cleared CP's new count for that tick.
    # They fill the 4 blank lines that were above the CP, which come back when they're hidden.
    # Below them the CP keeps 2 of its blank lines, which puts it 8px above Controls instead of
    # level with it: a subheader line is 24px and a text line 28px, and no mix of them makes up
    # the 40px between the counters and Controls.
    counterHudText[0] = _("Runs: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and localPlayer.qaPage == 0
        ),
        _(counterHudText[0]).replace("@0", localPlayer.viewRunner.runCount),
        HudPosition.RIGHT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    counterHudText[1] = _("Attempts: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and localPlayer.qaPage == 0
        ),
        _(counterHudText[1]).replace(
            "@0", localPlayer.viewRunner.cpAttempts[localPlayer.viewRunner.runCurrentCp]
        ),
        HudPosition.RIGHT,
        1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby and localPlayer.qaPage == 0
        ),
        ("{}{} {}/{}\n").format(
            "\n\n\n\n" if localPlayer.spectating[3] else "\n\n",
            iconString(Icon.FLAG),
            localPlayer.viewCp,
            lastCp
        ),
        HudPosition.RIGHT,
        2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Debug mode turns off Update Run Format, so it shows the raw time
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and localPlayer.qaPage == 0
        ),
        ("{} {}\n").format(
            iconString(Icon.BOLT),
            (
                localPlayer.viewRunner.runTime
                if isDebugOn
                else localPlayer.viewRunner.runTimeFormatted
            )
        ),
        HudPosition.RIGHT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
            and localPlayer.qaPage == 0
        ),
        ("{} {}\n\n").format(
            iconString(Icon.SKULL), localPlayer.viewRunner.runMistakes
        ),
        HudPosition.RIGHT,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Under Hints, which is under the Q&A line. Its rows are left out when the only runner
    # listed is the player, as their run is on the right, but its line stays while there's a
    # Top 3 for it to hide.
    # The Lobby Top 3 goes between the rows and the Hide Scores line, in the same HUD text so
    # they all left-align. With the Controls list open, only the top 5 rows show, to make room.
    scorecardHudText[0] = _("Hide Scores: <fgFFFFFFFF>@0 + @1</fg>")
    scorecardHudText[1] = _("\nScores: <fgFFFFFFFF>@0 + @1</fg>")
    topRunsHudText = _("Lobby Top 3")
    # TEST: a fake Lobby Top 3
    topRuns = [
        [234.23, "BallMyBloved", 5, "3:54.23"],
        [1245.81, "Coldskin", 12, "20:45.81"],
        [4521.96, "WWWWWWWWWWWW", 99, "1:15:21.96"]
    ]
    topRunsText = ""
    for index in range(len(topRuns)):
        topRunsText = "{}\n{}{}   {}{}{}{}{}</fg>".format(
            topRunsText,
            ["<fgFFFF00FF>", "<fgB0C4DEFF>", "<fgC46A30FF>"][index],
            index + 1,
            topRuns[index][3],
            "     " if strLen(topRuns[index][3]) < 8 else "   ",
            topRuns[index][2],
            "     " if topRuns[index][2] < 10 else "   ",
            topRuns[index][1]
        )
    # The rows stay out of the String Replace, which cuts off long strings, and they're too long for it
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                not localPlayer.isScorecardHidden
                and (true or len(topRuns) > 0)
                and localPlayer.qaPage == 0
            )
        ),
        "{}{}{}".format(
            (
                "{}\n".format(
                    scorecardShort if localPlayer.isViewingCtrlsHud else scorecard
                )
                if true
                else ""
            ),
            (
                "{}{}{}\n".format(
                    "\n" if true else "\n\n", _(topRunsHudText), topRunsText
                )
                if len(topRuns) > 0
                else ""
            ),
            _(scorecardHudText[0])
            .replace("@0", inputBindingString(Button.ULTIMATE))
            .replace("@1", inputBindingString(Button.CROUCH))
        ),
        HudPosition.LEFT,
        17,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # On its own under Hints, so it's the same size as it
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                localPlayer.isScorecardHidden
                and (true or len(topRuns) > 0)
                and localPlayer.qaPage == 0
            )
        ),
        _(scorecardHudText[1])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.CROUCH)),
        HudPosition.LEFT,
        17,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Update Scorecard":
    scorecardDirty = false
    scorecardRunners = sorted(
        getAllPlayers().filter(lambda p: isOnScorecard(p)),
        lambda p: p.runTime - p.runCurrentCp * 100000
    )
    # One string rebuilt on each change and each second, instead of a HUD text per runner: Overwatch reprocesses every
    # HUD text's definition every 5s (see Translated HUD Text). It starts with a gap above it.
    # A string only shows its first 4 icons, so they head the columns instead of filling each row.
    scorecard = "\n\n{}    {}       {}".format(
        iconString(Icon.FLAG), iconString(Icon.BOLT), iconString(Icon.SKULL)
    )
    for index in range(len(scorecardRunners)):
        scorecardTime = scorecardRunners[index].runTimeFormatted.split(".")[0]
        # The time's column fits h:mm:ss. Its padding is by length, since colons are narrower than digits.
        scorecardRow = "{}{}{}{}{}{}{}".format(
            scorecardRunners[index].runCurrentCp,
            scorecardPad(scorecardRunners[index].runCurrentCp),
            scorecardTime,
            "             ".substring(
                0, [0, 13, 11, 0, 7, 5, 0, 2][strLen(scorecardTime)]
            ),
            scorecardRunners[index].runMistakes,
            scorecardPad(scorecardRunners[index].runMistakes),
            scorecardRunners[index]
        )
        # Runs that skipped checkpoints are grayed out, as their CP wasn't earned
        scorecard = "{}\n{}".format(
            scorecard,
            (
                scorecardRow
                if scorecardRunners[index].isRunLegit
                else "<fg808080FF>{}</fg>".format(scorecardRow)
            )
        )
        # The top 5, for when the Controls list is open
        if index < 5:
            scorecardShort = scorecard
    # TEST: 12 fake runners in place of the real ones
    scorecard = "\n\n{}    {}       {}".format(
        iconString(Icon.FLAG), iconString(Icon.BOLT), iconString(Icon.SKULL)
    )
    for index in range(12):
        scorecardTime = [
            "1:23:45",
            "58:12",
            "42:07",
            "31:50",
            "12:03",
            "9:41",
            "7:15",
            "5:02",
            "3:33",
            "2:10",
            "1:05",
            "0:42"
        ][index]
        scorecardRow = "{}{}{}{}{}{}{}".format(
            [100, 97, 85, 64, 42, 38, 25, 19, 12, 7, 3, 1][index],
            scorecardPad([100, 97, 85, 64, 42, 38, 25, 19, 12, 7, 3, 1][index]),
            scorecardTime,
            "             ".substring(
                0, [0, 13, 11, 0, 7, 5, 0, 2][strLen(scorecardTime)]
            ),
            [312, 140, 99, 57, 23, 18, 9, 4, 2, 1, 0, 0][index],
            scorecardPad([312, 140, 99, 57, 23, 18, 9, 4, 2, 1, 0, 0][index]),
            [
                "WWWWWWWWWWWW",
                "Ballhallaa",
                "Kiriko",
                "xX_Slayer_Xx",
                "Mo",
                "Hammond",
                "Speedrunner",
                "Wreck",
                "Tracer",
                "ABCDEFGHIJKL",
                "Lúcio",
                "Zen"
            ][index]
        )
        scorecard = "{}\n{}".format(
            scorecard,
            (
                "<fg808080FF>{}</fg>".format(scorecardRow)
                if index in [3, 8]
                else scorecardRow
            )
        )
        if index < 5:
            scorecardShort = scorecard
    # The time column ticks each second, and a change rebuilds it within 0.1s. Rebuilding on
    # the next tick added ~20% to peak server load while Next CP was held with 12 rows.
    wait(0.1)
    waitUntil(scorecardDirty == true, 0.9)
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
    eventPlayer.runTime = 0
    eventPlayer.runTimeFormatted = "0.00"
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
