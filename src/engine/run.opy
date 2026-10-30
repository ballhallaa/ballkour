#!mainFile "../main.opy"
#!rulePrefix "Run"


# The player whose run a player's HUD follows: the one they're spectating, or themselves.
# Disconnected freecam (spectating[3]) doesn't follow anyone's run.
macro viewedRunner(player):
    (player.spectating[1] if player.spectating[0] else player)


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
    hudSubtext(
        getAllPlayers(),
        "ballkour.com",
        HudPosition.TOP,
        0,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY
    )
    runHudText = _("\n\n\n\nControls: <fgFFFFFFFF>@0 (Hold)</fg>")
    hudSubtext(
        getAllPlayers(),
        _(runHudText).replace("@0", inputBindingString(Button.ULTIMATE)),
        HudPosition.LEFT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby),
        ("\n\n\n\n{} {}/{}\n").format(
            iconString(Icon.FLAG), localPlayer.viewCp, lastCp
        ),
        HudPosition.RIGHT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Debug mode turns off Update Run Format, so it shows the raw time
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
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
        1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[3]
        ),
        ("{} {}\n\n\n").format(
            iconString(Icon.SKULL), localPlayer.viewRunner.runMistakes
        ),
        HudPosition.RIGHT,
        2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Under the Hints HUD, which is LEFT's last. Its rows are left out when the only runner
    # listed is the player, as their run is on the right, but its line stays while there's a
    # Top 3 for it to hide.
    scorecardHudText[0] = _("Hide Scores: <fgFFFFFFFF>@0 + @1</fg>")
    scorecardHudText[1] = _("\n\nScores: <fgFFFFFFFF>@0 + @1</fg>")
    # The rows stay out of the String Replace, which cuts off long strings, and they're too long for it
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: len(scorecardRunners.exclude(localPlayer)) > 0
            or len(topRuns) > 0
        ),
        "{}{}".format(
            (
                "{}\n".format(
                    scorecardShort
                    if localPlayer.spectating[0] and localPlayer.isViewingCtrlsHud
                    else scorecard
                )
                if not localPlayer.isScorecardHidden
                and len(scorecardRunners.exclude(localPlayer)) > 0
                else ""
            ),
            (
                _(scorecardHudText[1])
                if localPlayer.isScorecardHidden
                else _(scorecardHudText[0])
            )
            .replace("@0", inputBindingString(Button.ULTIMATE))
            .replace("@1", inputBindingString(Button.CROUCH))
        ),
        HudPosition.LEFT,
        16,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Update Scorecard":
    # A finished run stays listed, even though finishing turns on freemode
    scorecardRunners = sorted(
        getAllPlayers().filter(
            lambda p: not p.isDummy()
            and p.isRunLoaded
            and not p.isInLobby
            and not p.spectating[0]
            and (p.isRunFinished or not p.isInFreemode)
        ),
        lambda p: p.runTime - p.runCurrentCp * 100000
    )
    # One string rebuilt each second, instead of a HUD text per runner: Overwatch reprocesses every
    # HUD text's definition every 5s (see Translated HUD Text). It starts with a gap above it.
    # A string only shows its first 4 icons, so they head the columns instead of filling each row.
    scorecard = "\n\n{}    {}          {}".format(
        iconString(Icon.FLAG), iconString(Icon.BOLT), iconString(Icon.SKULL)
    )
    for index in range(len(scorecardRunners)):
        scorecardTime = scorecardRunners[index].runTimeFormatted.split(".")[0]
        # The time's column fits h:mm:ss. Its padding is by length, since colons are narrower than digits.
        scorecardRow = "{}{}{}{}{}{}{}".format(
            scorecardRunners[index].runCurrentCp,
            scorecardPad(scorecardRunners[index].runCurrentCp),
            scorecardTime,
            "            ".substring(
                0, [0, 12, 11, 0, 7, 5, 0, 3][strLen(scorecardTime)]
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
        # Spectator's Controls list is the longest, and leaves room for 5 rows above the hero portrait
        if index < 5:
            scorecardShort = scorecard
    wait(1)
    loop()


def newRun():
    @Name "Initialize New Run"

    eventPlayer.isLoading = true
    if eventPlayer.spectating[0]:
        disableSpectator()
    eventPlayer.isInLobby = false
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
            eventPlayer.runMistakes++
