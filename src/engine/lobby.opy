#!mainFile "../main.opy"
#!rulePrefix "Lobby"


# The lobby floats in the sky this far above CP 0, the same on every course. Its players are
# held there in first person (Load), so they look around as usual and their crosshair picks
# a button. Its texts are LOBBY_DISTANCE from their eyes, toward the horizontal angle
# lobbyAngle (0 unless a course turns it away from its sun), each at its own vertical angle
# (negative is up). In-world text stays about the same size on screen at
# any distance, so the angles alone space the texts out, and every page is high enough above
# the horizon to only have sky behind it.
macro LOBBY_HEIGHT = 100
macro LOBBY_DISTANCE = 10
# The buttons, with the leaderboard under them. Players arrive looking at LOOK_ANGLE, the
# 5th row, from where all of it fits on screen above their guns.
macro BUTTON_ANGLE = -56
macro BUTTON_SPACING = 4.5
macro TITLE_ANGLE = -45.5
macro ROW_ANGLE = -40.5
macro ROW_SPACING = 3.3
macro LOOK_ANGLE = ROW_ANGLE + ROW_SPACING * 4
# The languages, in a column this many degrees to the right of the leaderboard as seen
# from LOOK_ANGLE, a row every LANGUAGE_SPACING from ROW_ANGLE down
macro LANGUAGE_ACROSS = 30
macro LANGUAGE_SPACING = 2.4
# How far to either side of a button or row a player can look and still pick it
macro BUTTON_WIDTH = 18
macro ROW_WIDTH = 21
macro LANGUAGE_WIDTH = 8
# The texts' sizes, which the angles above are spaced for
macro TITLE_SIZE = 2
macro BUTTON_SIZE = 2.1
macro ROW_SIZE = 1.3
macro HINT_SIZE = 1
macro LANGUAGE_TITLE_SIZE = 1.5
macro LANGUAGE_SIZE = 1


macro lobbyAt(angle):
    lobbyCam + directionFromAngles(lobbyAngle, angle) * LOBBY_DISTANCE


# The view from LOOK_ANGLE: ahead, up and to the right
macro lobbyForward = directionFromAngles(lobbyAngle, LOOK_ANGLE)
macro lobbyUp = directionFromAngles(lobbyAngle, LOOK_ANGLE - 90)
macro lobbyRight = directionFromAngles(lobbyAngle - 90, 0)


# A spot in the languages' column. A column at one horizontal angle would lean outward
# toward its bottom on screen, so its spots share a plane with the eyes instead, which
# shows as an upright line from LOOK_ANGLE.
macro languageAt(angle):
    (
        lobbyCam
        + normalize(
            directionFromAngles(lobbyAngle, angle)
            + lobbyRight * tanDeg(LANGUAGE_ACROSS) * cosDeg(angle - LOOK_ANGLE)
        )
        * LOBBY_DISTANCE
    )


def loadLobby():
    @Name "Load"

    # Anyone watching them drops into freecam, as a player in the lobby has nothing to watch
    enableFreecamForSpectators()
    # Back to mech form: the ball's camera is behind it, so its crosshair wouldn't point
    # where the lobby measures from. Lobby/Pause is held with Ultimate, which disallows
    # Ability 1 (Controls: HUD Input), so it's allowed again for the press.
    if eventPlayer.isUsingAbility1():
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        waitUntil(not eventPlayer.isUsingAbility1(), 1)
        # Until the mech stands up, as its eyes are measured below
        wait(0.5)
    eventPlayer.isInLobby = true
    eventPlayer.lobbyPage = 1
    eventPlayer.isInFreemode = false
    # Held in the sky with their eyes at lobbyCam, by stopping them there with no gravity and
    # nothing to move or jump with: forcing their position made their camera feel sluggish.
    # Everyone in the lobby is held at the same spot, so they're invisible and nameless there.
    eventPlayer.setGravity(0)
    eventPlayer.setMoveSpeed(0)
    eventPlayer.setJumpVerticalSpeed(0)
    eventPlayer.teleport(
        lobbyCam - (eventPlayer.getEyePosition() - eventPlayer.getPosition())
    )
    eventPlayer.applyImpulse(
        eventPlayer.getVelocity() * -0.001,
        0.001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.nameplate = _("{}").format("")
    # Looking around is all there is to do. Both fires pick a button (Select Input), so
    # they're disallowed rather than disabled, which still lets the presses be read. The
    # hero HUD stays, as hiding it hides the crosshair too.
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.setFacing(directionTowards(lobbyCam, lobbyPos[0]), Relativity.TO_WORLD)
    wait()


def leaveLobby():
    @Name "Leave"

    # Undoes Load. Each checkpoint sets the rest of the abilities (Checkpoint: Set Abilities).
    eventPlayer.isInLobby = false
    eventPlayer.lobbyPage = 0
    eventPlayer.setGravity(100)
    eventPlayer.setMoveSpeed(100)
    eventPlayer.setJumpVerticalSpeed(100)
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.setAbility1Enabled(true)
    # While Ultimate is held, letting go of it gives them back (Controls: HUD Input)
    if not eventPlayer.isHoldingButton(Button.ULTIMATE):
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)


# The row of a column of texts a player is looking at: 1 for its top one, counting down a
# row every spacing degrees, or 0 if they aren't looking across the column. Rows past the
# last wrap to 0. It compares how far up they're aiming with how far up the top row is from
# their eyes, which their crosshair looks out from. Vertical Angle Towards picked no row
# in-game, so it isn't used.
macro lobbyAimRow(player, top, spacing, rows, width):
    (
        max(
            0,
            min(
                round(
                    (
                        player.getVerticalFacingAngle()
                        - verticalAngleOfDirection(
                            directionTowards(player.getEyePosition(), top)
                        )
                    )
                    / spacing
                )
                + 1,
                rows + 1
            )
        )
        % (rows + 1)
        if abs(horizontalAngleTowards(player, top)) <= width
        else 0
    )


# The button a player is looking at (lobbyPos[1] to [3]), or 0
macro buttonAimRow(player):
    lobbyAimRow(
        player, lobbyPos[1], BUTTON_SPACING, (3 if isLobbyStatsOn else 2), BUTTON_WIDTH
    )


macro isAimingAtBack(player):
    lobbyAimRow(player, lobbyPos[4], BUTTON_SPACING, 1, BUTTON_WIDTH) == 1


macro lbAimRow(player):
    lobbyAimRow(player, lbPos[1], ROW_SPACING, lbRunCount, ROW_WIDTH)


# Like lobbyAimRow, but for the languages' column, measured against the view from
# LOOK_ANGLE that its plane is upright in (languageAt)
macro langAimRow(player):
    (
        max(
            0,
            min(
                round(
                    (
                        LOOK_ANGLE
                        - atan2Deg(
                            dotProduct(player.getFacingDirection(), lobbyUp),
                            dotProduct(player.getFacingDirection(), lobbyForward)
                        )
                        - ROW_ANGLE
                    )
                    / LANGUAGE_SPACING
                )
                + 1,
                LANGUAGES + 1
            )
        )
        % (LANGUAGES + 1)
        if abs(
            atan2Deg(
                dotProduct(player.getFacingDirection(), lobbyRight),
                dotProduct(player.getFacingDirection(), lobbyForward)
            )
            - LANGUAGE_ACROSS
        )
        <= LANGUAGE_WIDTH
        else 0
    )


# A button's text: its label, with arrows on either side while it's looked at, like the
# leaderboard's row. Only its text changes, so nothing moves.
macro lobbyButton(label, isAimedAt):
    (
        "{}  {}  {}".format(
            iconString(Icon.ARROW_RIGHT), label, iconString(Icon.ARROW_LEFT)
        )
        if isAimedAt
        else label
    )


rule "Load Buttons":
    # Checkpoint: Expand Data has unpacked cps by now, as its file is included first
    lobbyCam = cps[0][0] + vect(0, LOBBY_HEIGHT, 0)
    # lobbyPos[i]: [0]lookAt [1]newRun [2]resumeRun [3]lobbyStats [4]back
    lobbyPos = [lobbyAt(LOOK_ANGLE)]
    # Lobby Stats goes under Resume Run with its Workshop Setting on, so the buttons move up
    # one to make room
    for index in range(1, 4):
        lobbyPos[index] = lobbyAt(
            BUTTON_ANGLE + BUTTON_SPACING * (index - (2 if isLobbyStatsOn else 1))
        )
    # Lobby Stats' Back, where the 10th row is
    lobbyPos[4] = lobbyAt(ROW_ANGLE + ROW_SPACING * 9)
    lobbyHudText[0] = _("New Run")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        lobbyButton(_(lobbyHudText[0]), buttonAimRow(localPlayer) == 1),
        lobbyPos[1],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    lobbyHudText[2] = _("Resume Run")
    # Grayed out, with no arrows, without a run to resume
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        (
            lobbyButton(_(lobbyHudText[2]), buttonAimRow(localPlayer) == 2)
            if localPlayer.isRunLoaded and not localPlayer.isRunFinished
            else "<fg808080FF>{}</fg>".format(_(lobbyHudText[2]))
        ),
        lobbyPos[2],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    if isLobbyStatsOn:
        createInWorldText(
            getAllPlayers().filter(
                lambda localPlayer: localPlayer.lobbyPage == 1
                and "{}".format(localPlayer) == hostPlayerName
            ),
            lobbyButton("Lobby Stats", buttonAimRow(localPlayer) == 3),
            lobbyPos[3],
            BUTTON_SIZE,
            Clip.NONE,
            WorldTextReeval.VISIBILITY_AND_STRING,
            rgb(0, 224, 146)
        )


rule "Load Leaderboard":
    lobbyHudText[3] = _("Leaderboard")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        _(lobbyHudText[3]),
        lobbyAt(TITLE_ANGLE),
        TITLE_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    lbPos = []
    for index in range(1, 11):
        lbPos[index] = lobbyAt(ROW_ANGLE + ROW_SPACING * (index - 1))
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
            getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
            lbObjFormatted,
            lbPos[index],
            ROW_SIZE,
            Clip.NONE,
            WorldTextReeval.VISIBILITY,
            rgb(230, 151, 0)
        )
    # Lobby Stats' way back to the buttons and leaderboard
    lobbyHudText[4] = _("Back")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        lobbyButton(_(lobbyHudText[4]), isAimingAtBack(localPlayer)),
        lobbyPos[4],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    # The rows are made, and lbRunText keeps what the run info needs
    lb = null
    lbObj = null
    lbObjFormatted = null
    # Courses without runs have no run info
    if lbRunCount <= 0:
        return
    # Arrows on either side of the row the player is looking at, so they can see which run
    # Interact opens. The 86 spaces between them clear the widest row. Only its position
    # changes (changing its text too flickered): looking at no run moves it to lbPos[0],
    # far below the lobby.
    lbPos[0] = lbPos[1] + vect(0, -1000, 0)
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        (
            "{}                                           "
            "                                           {}"
        ).format(iconString(Icon.ARROW_RIGHT), iconString(Icon.ARROW_LEFT)),
        lbPos[lbAimRow(localPlayer)],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        rgb(230, 151, 0)
    )
    # The blank lines around a run's info (lbRunInfo): [0] above its row and [1] below its
    # link, and [2] above the close line, which is its 14th of 21 lines, and [3] below the
    # [4] line under it. Each is a soft hyphen, as Overwatch drops empty lines. [4] is as
    # wide as the longest link: a text's lines start at the left edge of its widest line, so
    # with this in them the overlaid texts, the row and the close line all start at the same
    # spot, whatever their link.
    lbRunPad = [
        "­\n­\n­\n­\n­\n­\n­\n­\n­\n",
        "\n­\n­\n­\n­\n­\n­\n­\n­\n­",
        "­\n­\n­\n­\n­\n­\n­\n­\n­\n­\n­\n­\n­\n",
        "\n­\n­\n­\n­\n­\n­",
        "                                                                                                              ­"
    ]
    # Shown under an open run's info (lbRunInfo)
    lobbyHudText[1] = _("Close: <fgFFFFFFFF>@0</fg>")
    lobbyHudText[5] = _("Click on a Run to View More Info")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        _(lobbyHudText[5]),
        lobbyAt(ROW_ANGLE + ROW_SPACING * 10),
        HINT_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )


rule "Load Languages":
    lobbyHudText[6] = _("Language")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        _(lobbyHudText[6]),
        languageAt(TITLE_ANGLE),
        LANGUAGE_TITLE_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    # Each in its own language, in the order of #!translations (ballkour.opy). The one a
    # player is reading is green.
    langNames = [
        "English",
        "Deutsch",
        "Español",
        "Français",
        "Italiano",
        "日本語",
        "한국어",
        "Polski",
        "Português",
        "Русский",
        "ไทย",
        "Türkçe",
        "简体中文",
        "繁體中文"
    ]
    langPos = []
    for index in range(1, LANGUAGES + 1):
        langPos[index] = languageAt(ROW_ANGLE + LANGUAGE_SPACING * (index - 1))
        createInWorldText(
            getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
            (
                "<fg00E092FF>{}</fg>".format(evalOnce(langNames[index - 1]))
                if localPlayer.__languageIndex__ == evalOnce(index - 1)
                else evalOnce(langNames[index - 1])
            ),
            langPos[index],
            LANGUAGE_SIZE,
            Clip.NONE,
            WorldTextReeval.VISIBILITY_AND_STRING,
            rgb(230, 151, 0)
        )
    # Arrows around the language being looked at, like the leaderboard's, parked far below
    # the lobby at langPos[0] otherwise
    langPos[0] = langPos[1] + vect(0, -1000, 0)
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        "{}                          {}".format(
            iconString(Icon.ARROW_RIGHT), iconString(Icon.ARROW_LEFT)
        ),
        langPos[langAimRow(localPlayer)],
        LANGUAGE_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        rgb(230, 151, 0)
    )


rule "Load Stats Page":
    @Condition isLobbyStatsOn == true

    # Only the host can open it. Its rows line up with the leaderboard's.
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Lobby Stats",
        lobbyAt(TITLE_ANGLE),
        TITLE_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Elapsed Time: <fgFFFFFFFF>{}</fg>".format(
            elapsedTimeFormatted if not isDebugOn else elapsedTime
        ),
        lbPos[1],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "New Players: <fgFFFFFFFF>{}</fg>".format(lobbyStats[0]),
        lbPos[2],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Rejoins: <fgFFFFFFFF>{}</fg>".format(lobbyStats[1]),
        lbPos[3],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Legit Runs: <fgFFFFFFFF>{}</fg>".format(lobbyStats[2]),
        lbPos[4],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Total Run Time: <fgFFFFFFFF>{}</fg>".format(lobbyStats[4]),
        lbPos[5],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Total Mistakes: <fgFFFFFFFF>{}</fg>".format(lobbyStats[5]),
        lbPos[6],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Avg Run Time: <fgFFFFFFFF>{}</fg>".format(lobbyStats[7]),
        lbPos[7],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
        "Avg Mistakes: <fgFFFFFFFF>{}</fg>".format(lobbyStats[8]),
        lbPos[8],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )


# Interact picks a button, and so does either fire, which don't shoot in the lobby (Load)
rule "Select Input":
    @Event eachPlayer
    @Condition (
        eventPlayer.isHoldingButton(Button.INTERACT)
        or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
        or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    ) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isInLobby == true
    @Condition eventPlayer.isLoading == false
    # Interact closes the Q&A
    @Condition eventPlayer.qaPage == 0

    if eventPlayer.lobbyPage == 1:
        eventPlayer.lobbyAim = buttonAimRow(eventPlayer)
        if eventPlayer.lobbyAim == 1:
            newRun()
        elif eventPlayer.lobbyAim == 2:
            if eventPlayer.isRunLoaded and not eventPlayer.isRunFinished:
                eventPlayer.isLoading = true
                leaveLobby()
                cpResetPlayer()
                setCpAbilities()
                showCpNameplate()
                faceNextCp()
                eventPlayer.isLoading = false
        elif eventPlayer.lobbyAim == 3:
            if isLobbyStatsOn and "{}".format(eventPlayer) == hostPlayerName:
                eventPlayer.lobbyPage = 2
        else:
            eventPlayer.lobbyAim = langAimRow(eventPlayer)
            if eventPlayer.lobbyAim > 0:
                eventPlayer.__languageIndex__ = eventPlayer.lobbyAim - 1
            elif lbRunCount > 0:
                eventPlayer.lobbyAim = lbAimRow(eventPlayer)
                # Looking at the open run again hides it, like looking away from the runs
                if eventPlayer.lobbyAim == eventPlayer.lbInfoRow:
                    eventPlayer.lobbyAim = 0
                if eventPlayer.lobbyAim != eventPlayer.lbInfoRow:
                    eventPlayer.lbInfoRow = eventPlayer.lobbyAim
                    showRunInfo()
    elif isAimingAtBack(eventPlayer):
        eventPlayer.lobbyPage = 1


rule "Hide Run Info":
    @Event eachPlayer
    # Opening Lobby Stats, or leaving the lobby
    @Condition eventPlayer.lobbyPage != 1
    @Condition eventPlayer.lbInfoRow != 0

    eventPlayer.lbInfoRow = 0
    showRunInfo()


def showRunInfo():
    @Name "Show Run Info"

    # Only open runs have a text (see lbRunInfo), so they're remade whenever that changes.
    # These are the only progress bar texts.
    destroyAllProgressBarInWorldTexts()
    # The row and close line of every open run's info. They're the same kind of text with
    # the same number of lines, with only their own line filled in, so they land above and
    # below the date and link. Each viewer's row and key name need the text reevaluated, and
    # so does who sees it: the row would show "0" for a frame on closing before going.
    createProgressBarInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lbInfoRow != 0),
        0,
        "{}{}\n{}\n­{}".format(
            lbRunPad[0], lbRunText[localPlayer.lbInfoRow], lbRunPad[4], lbRunPad[1]
        ),
        updateEveryFrame(
            localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 10
        ),
        1,
        Clip.NONE,
        Color.WHITE,
        rgb(230, 151, 0),
        ProgressWorldTextReeval.VISIBILITY_POSITION_AND_VALUES
    )
    createProgressBarInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lbInfoRow != 0),
        0,
        "{}{}\n{}{}".format(
            lbRunPad[2],
            _(lobbyHudText[1]).replace("@0", inputBindingString(Button.INTERACT)),
            lbRunPad[4],
            lbRunPad[3]
        ),
        updateEveryFrame(
            localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 10
        ),
        1,
        Clip.NONE,
        Color.WHITE,
        rgb(230, 151, 0),
        ProgressWorldTextReeval.VISIBILITY_POSITION_AND_VALUES
    )
    loadRunInfo()
