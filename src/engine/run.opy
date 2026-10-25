#!mainFile "../main.opy"
#!rulePrefix "Run"


rule "Load HUD":
    hudSubtext(
        getAllPlayers(),
        "ballkour.com",
        HudPosition.TOP,
        0,
        rgb(
            127.5 + 127.5 * cosDeg(getTotalTimeElapsed() * 15),
            127.5 + 127.5 * cosDeg(getTotalTimeElapsed() * 15 + 120),
            127.5 + 127.5 * cosDeg(getTotalTimeElapsed() * 15 + 240)
        ),
        HudReeval.VISIBILITY_AND_COLOR
    )
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: not localPlayer.isInLobby),
        ("\n\n\n\nControls: {}").format(inputBindingString(Button.ULTIMATE)),
        HudPosition.LEFT,
        0,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
        ),
        ("{}/{}").format(localPlayer.runCurrentCp, len(cps) - 1),
        HudPosition.TOP,
        1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    if not settings_[0]:
        hudSubtext(
            getAllPlayers().filter(
                lambda localPlayer: not localPlayer.isInLobby
                and not localPlayer.spectating[0]
            ),
            ("\n\n\n\n{} {}\n").format(
                iconString(Icon.BOLT), localPlayer.runTimeFormatted
            ),
            HudPosition.RIGHT,
            1,
            rgb(230, 151, 0),
            HudReeval.VISIBILITY_AND_STRING
        )
    else:
        hudSubtext(
            getAllPlayers().filter(
                lambda localPlayer: not localPlayer.isInLobby
                and not localPlayer.spectating[0]
            ),
            ("\n\n\n\n{} {}\n").format(iconString(Icon.BOLT), localPlayer.runTime),
            HudPosition.RIGHT,
            1,
            rgb(230, 151, 0),
            HudReeval.VISIBILITY_AND_STRING
        )
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and not localPlayer.spectating[0]
        ),
        ("{} {}").format(iconString(Icon.SKULL), localPlayer.runMistakes),
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
    for eventPlayer.index in range(len(getAllPlayers())):
        if (
            getAllPlayers()[eventPlayer.index].spectating[1] == eventPlayer
            and getAllPlayers()[eventPlayer.index].spectating[3] == false
        ):
            getAllPlayers()[eventPlayer.index].spectating[4] = 0
    loadCpData()
    setCpAbilities()
    cpResetPlayer()
    eventPlayer.setFacing(
        directionTowards(eventPlayer.getEyePosition(), eventPlayer.cpData[7]),
        Relativity.TO_WORLD
    )
    eventPlayer.isLoading = false
