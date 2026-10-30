#!mainFile "../main.opy"
#!rulePrefix "Run"


# The player whose run a player's HUD follows: the one they're spectating, or themselves.
# Disconnected freecam (spectating[3]) doesn't follow anyone's run.
macro viewedRunner(player):
    (player.spectating[1] if player.spectating[0] else player)


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
