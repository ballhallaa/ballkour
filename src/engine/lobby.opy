#!mainFile "../main.opy"
#!rulePrefix "Lobby"


def loadLobby():
    @Name "Load"

    eventPlayer.teleport(lobbyData[0])
    eventPlayer.applyImpulse(
        eventPlayer.getVelocity() * -0.001,
        0.001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.3)
    eventPlayer.isInLobby = true
    eventPlayer.setFacing(
        directionTowards(eventPlayer.getEyePosition(), lobbyData[1]),
        Relativity.TO_WORLD
    )
    eventPlayer.isInFreemode = false
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.nameplate = _("{}").format(eventPlayer)
    wait()


rule "Load Welcome Area":
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        _("Welcome to"),
        lobbyData[2],
        lobbyData[4],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        "Ballkour!",
        lobbyData[3],
        lobbyData[4],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(230, 151, 0)
    )


# The leaderboard row a player is looking at, from the height their aim reaches over the
# rows, or 0 if they aren't looking across the rows' text. Rows past the last run wrap to 0.
# While rolling it's off from the crosshair, as the camera isn't at the player's eyes.
macro lbAimRow(player):
    (
        max(
            0,
            min(
                round(
                    (
                        lbPos[1].y
                        - player.getEyePosition().y
                        + distance(
                            vect(
                                player.getEyePosition().x, 0, player.getEyePosition().z
                            ),
                            vect(lbPos[1].x, 0, lbPos[1].z)
                        )
                        * tanDeg(player.getVerticalFacingAngle())
                    )
                    / (lbPos[1].y - lbPos[2].y)
                )
                + 1,
                lbRunCount + 1
            )
        )
        % (lbRunCount + 1)
        if abs(horizontalAngleTowards(player, lbPos[1])) <= 12
        else 0
    )


rule "Load Leaderboard Area":
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        _("Leaderboard"),
        lobbyData[11],
        lobbyData[12],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    # lb[0] is unused, so this is -1 without runs
    lbRunCount = len(lb) - 1
    lbRunText = []
    # 1st-9th Position Placeholder"
    lb[11] = "---, -:--.--, -, '                                               '"
    # 10th Position Placeholder"
    lb[12] = "---, -:--.--, -, '                                              '"
    for index in range(1, 11):
        if lb[index] == null:
            if index <= 9:
                lbObj = lb[11]
            else:
                lbObj = lb[12]
        else:
            lbObj = lb[index]
        # lbObj[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator [4]rankColor
        lbObj = lbObj.split(",")
        lbObj[3] = lbObj[3].replace("'", "")
        # Gold, silver and bronze, then the rest
        lbObj[4] = ["<fgFFFF00FF>", "<fgB0C4DEFF>", "<fgC46A30FF>", "<fgFFFFFFFF>"][
            min(index, 4) - 1
        ]
        lbObjFormatted = "{}. {}{}</fg>{}{}{}{}   {}{}</fg>".format(
            index,
            lbObj[4],
            lbObj[0],
            lbObj[3],
            iconString(Icon.BOLT),
            lbObj[4],
            lbObj[1],
            iconString(Icon.SKULL),
            lbObj[2]
        )
        # The row without its alignment, for the run info (lbRunInfo)
        lbRunText[index] = "{}. {}{}</fg>   {}{}{}   {}{}</fg>".format(
            index,
            lbObj[4],
            lbObj[0],
            iconString(Icon.BOLT),
            lbObj[4],
            lbObj[1],
            iconString(Icon.SKULL),
            lbObj[2]
        )
        createInWorldText(
            getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
            lbObjFormatted,
            lbPos[index],
            lobbyData[13],
            Clip.SURFACES,
            WorldTextReeval.VISIBILITY,
            rgb(230, 151, 0)
        )
    # Courses without runs have no run info
    if lbRunCount <= 0:
        return
    # Arrows on either side of the row the player is looking at, so they can see which run
    # Interact opens. The 86 spaces between them clear the widest row. Only its position
    # changes (changing its text too flickered): looking at no run moves it to lbPos[0],
    # far below the floor.
    lbPos[0] = lbPos[1] + vect(0, -1000, 0)
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        (
            "{}                                           "
            "                                           {}"
        ).format(iconString(Icon.ARROW_RIGHT), iconString(Icon.ARROW_LEFT)),
        lbPos[lbAimRow(localPlayer)],
        lobbyData[13],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        rgb(230, 151, 0)
    )
    lobbyHudText[0] = _("Run Info: <fgFFFFFFFF>Look at a Run + @0</fg>")
    # Shown under an open run's info (lbRunInfo)
    lobbyHudText[1] = _("Hide: <fgFFFFFFFF>@0</fg>")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        _(lobbyHudText[0]).replace("@0", inputBindingString(Button.INTERACT)),
        lbPos[10] + (lbPos[10] - lbPos[9]) * 1.5,
        lobbyData[13],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )


rule "Run Info Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isInLobby == true
    @Condition lbRunCount > 0

    eventPlayer.lbAim = lbAimRow(eventPlayer)
    # Looking at the open run again hides it, like looking away from the runs
    if eventPlayer.lbAim == eventPlayer.lbInfoRow:
        eventPlayer.lbAim = 0
    if eventPlayer.lbAim != eventPlayer.lbInfoRow:
        eventPlayer.lbInfoRow = eventPlayer.lbAim
        showRunInfo()


rule "Hide Run Info":
    @Event eachPlayer
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.lbInfoRow != 0

    eventPlayer.lbInfoRow = 0
    showRunInfo()


def showRunInfo():
    @Name "Show Run Info"

    # Only open runs have a text (see lbRunInfo), so they're remade whenever that changes.
    # These are the only progress bar texts.
    destroyAllProgressBarInWorldTexts()
    loadRunInfo()


rule "Load Start Run Area":
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        _("New Run"),
        lobbyData[7],
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    createEffect(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        Effect.RING,
        Color.AQUA,
        lobbyData[5],
        1.6,
        EffectReeval.VISIBILITY
    )
    createIcon(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        lobbyData[6],
        Icon.FLAG,
        IconReeval.VISIBILITY,
        Color.GREEN,
        false
    )
    createEffect(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isInLobby),
        Effect.SPARKLES,
        rgb(230, 151, 0),
        lobbyData[5] + vect(0, -0.85, 0),
        1.6,
        EffectReeval.VISIBILITY
    )


rule "Start Run Circle Entry":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[5]) <= 2

    eventPlayer.isLoading = true
    newRun()
    eventPlayer.isLoading = false


rule "Load Resume Run Area":
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        _("Resume Run"),
        lobbyData[10],
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        Effect.RING,
        Color.GREEN,
        lobbyData[8],
        1.6,
        EffectReeval.VISIBILITY
    )
    createIcon(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        lobbyData[9],
        Icon.RECYCLE,
        IconReeval.VISIBILITY,
        Color.GREEN,
        false
    )
    createEffect(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and localPlayer.isRunLoaded
            and not localPlayer.isRunFinished
        ),
        Effect.SPARKLES,
        rgb(230, 151, 0),
        lobbyData[8] + vect(0, -0.85, 0),
        1.6,
        EffectReeval.VISIBILITY
    )


rule "Resume Run Circle Entry":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isInLobby == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isRunFinished == false
    @Condition distance(eventPlayer.getPosition(), lobbyData[8]) <= 2

    eventPlayer.isLoading = true
    eventPlayer.isInLobby = false
    cpResetPlayer()
    setCpAbilities()
    showCpNameplate()
    faceNextCp()
    eventPlayer.isLoading = false


rule "Boundary":
    @Event eachPlayer
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.isInLobby == true
    @Condition distance(eventPlayer.getPosition(), lobbyData[0]) > lobbyData[25]

    if eventPlayer.isFiringSecondaryFire():
        eventPlayer.setSecondaryFireEnabled(false)
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0.5)
    eventPlayer.applyImpulse(
        directionTowards(eventPlayer.getPosition(), lobbyData[0]),
        10,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )


rule "Load Stats":
    @Condition isLobbyStatsOn == true

    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Stats",
        lobbyData[14],
        lobbyData[15],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Elapsed Time: <fgFFFFFFFF>{}</fg>".format(
            elapsedTimeFormatted if not isDebugOn else elapsedTime
        ),
        lobbyData[17],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "New Players: <fgFFFFFFFF>{}</fg>".format(lobbyStats[0]),
        lobbyData[18],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Rejoins: <fgFFFFFFFF>{}</fg>".format(lobbyStats[1]),
        lobbyData[19],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Legit Runs: <fgFFFFFFFF>{}</fg>".format(lobbyStats[2]),
        lobbyData[20],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Total Run Time: <fgFFFFFFFF>{}</fg>".format(lobbyStats[4]),
        lobbyData[21],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Total Mistakes: <fgFFFFFFFF>{}</fg>".format(lobbyStats[5]),
        lobbyData[22],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Avg Run Time: <fgFFFFFFFF>{}</fg>".format(lobbyStats[7]),
        lobbyData[23],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInLobby
            and "{}".format(localPlayer) == hostPlayerName
        ),
        "Avg Mistakes: <fgFFFFFFFF>{}</fg>".format(lobbyStats[8]),
        lobbyData[24],
        lobbyData[16],
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )


rule "Clear Unused Variables":
    # lbPos stays for Run Info Input
    lb = null
    lbObj = null
    lbObjFormatted = null
