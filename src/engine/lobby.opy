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
# 5th row, from where all of it fits on screen between BALLKOUR.COM and their guns. The top
# button sits about a button's gap under BALLKOUR.COM, high enough that looking straight up
# from anywhere shows some of it (players can't look up past 89°), and the 5th is a
# button's spacing above the leaderboard's title.
macro BUTTON_ANGLE = -84.5
macro BUTTON_SPACING = 2.6
macro TITLE_ANGLE = -71.5
macro ROW_ANGLE = -67.3
macro ROW_SPACING = 3
macro LOOK_ANGLE = ROW_ANGLE + ROW_SPACING * 4
# The leaderboard's tabs, for its regular and assisted runs, take its first row's spot, and
# its rows start a row lower. Each tab is a text at the page's middle like the rows, so they
# stay lined up wherever a player looks (texts at other spots shift against them), pushed to
# its side by LB_TAB_PAD's spaces, which put its label about 115 px from the middle at 1080p.
# The soft hyphen at the pad's far end keeps its spaces from being dropped.
macro TAB_ANGLE = ROW_ANGLE
macro LB_ANGLE = ROW_ANGLE + ROW_SPACING
macro LB_TAB_PAD = "                                          "
# The languages, in a column this many degrees to the right of the leaderboard as seen
# from LOOK_ANGLE, a row every LANGUAGE_SPACING from ROW_ANGLE down
macro LANGUAGE_ACROSS = 30
macro LANGUAGE_SPACING = 2.3
# The HUD page (HUD_PAGE) has the main page's layout: its 3 buttons where the main page's
# first 3 are, and ballkour.com's row where the leaderboard's title is, with the course's
# credit under it. Under them, the HUD's lines are in boxes like the HUD's own, a box's lines
# HUD_LINE_GAP apart (an in-world text's own line height) and a line's gap between boxes,
# each column from ROW_ANGLE down (Load HUD Page). The right column's rows are this many
# degrees right of the page's middle, and the left column is about as far left. They stay
# inside the HUD's own columns at the screen's edges, which show on the page.
macro HUD_ACROSS = 18
macro HUD_LINE_GAP = 1.85
# The left column's boxes are one text each, which line up their lines at their widest one's
# left edge, so each box starts with the same invisible line, wider than any of its lines in
# any language: every box is that wide, and all their lines start at the same spot. A text
# sits on its last line, so the line on top moves nothing. Its middle is this far across, so
# the lines start about where the HUD's left column is, and where the page measures a look at
# them from (HUD_LEFT_AIM).
macro HUD_LEFT_PAD = "­                                                                                                                                            ­"
macro HUD_LEFT_ACROSS = -2
macro HUD_LEFT_AIM = -15
# The right column's boxes that are one text each on the HUD (Runs, the stats and the Top 3s)
# line up the same way, each row its own text with this invisible line on top. It only has to
# clear those rows, so it's narrower, and the rows' spot moves less from where they were.
macro HUD_RIGHT_PAD = (
    "­                                                                ­"
)
macro HUD_RIGHT_ACROSS = 21
# The room the hover arrows and their gaps take, kept on a box's lines that aren't looked at,
# so no line moves: spaces, behind a soft hyphen, as Overwatch drops a line's leading and
# trailing spaces
macro HUD_ARROW_ROOM_L = "­       "
macro HUD_ARROW_ROOM_R = "       ­"
# How far to either side of a button or row a player can look and still pick it, across
# the page as seen from LOOK_ANGLE (pageAcross)
macro BUTTON_WIDTH = 11
macro ROW_WIDTH = 18
macro LANGUAGE_WIDTH = 8
macro HUD_ROW_WIDTH = 12
# How far from LOOK_ANGLE a player can look before an arrow and an eye show them the way
# back to the page (Load Buttons). Past this, its middle is off-screen at the widest field
# of view. The arrow sits MARKER_OFFSET from their crosshair, close enough to stay above
# their guns.
macro MARKER_ANGLE = 55
macro MARKER_OFFSET = 15
# Past PULL_ANGLE from LOOK_ANGLE, a player is turned back toward the page at PULL_RATE
# degrees a second until they're within RELEASE_ANGLE, where they can look around again
# (Pull Back). It's just past MARKER_ANGLE, so the page's edge is still on their screen.
macro PULL_ANGLE = 60
macro RELEASE_ANGLE = 45
macro PULL_RATE = 180
# The texts' sizes, which the angles above are spaced for
macro TITLE_SIZE = 1.5
macro BUTTON_SIZE = 1.6
macro ROW_SIZE = 1.15
macro HINT_SIZE = 0.9
macro LANGUAGE_TITLE_SIZE = 1.5
macro LANGUAGE_SIZE = 1
macro HUD_ROW_SIZE = 1
macro MARKER_SIZE = 4


macro canResumeRun(player):
    (player.isRunLoaded and not player.isRunFinished)


macro lobbyAt(angle):
    lobbyCam + directionFromAngles(lobbyAngle, angle) * LOBBY_DISTANCE


# Left and up on a player's screen, wherever they look
macro screenLeft(player):
    worldVector(Vector.LEFT, player, Transform.ROTATION)


macro screenUp(player):
    directionFromAngles(
        player.getHorizontalFacingAngle(), player.getVerticalFacingAngle() - 90
    )


# How far the page is to the left of a player's view (negative is right), and above it
# (negative is below)
macro pageLeft(player):
    dotProduct(lobbyForward, screenLeft(player))


macro pageUp(player):
    dotProduct(lobbyForward, screenUp(player))


macro isPageSideways(player):
    abs(pageLeft(player)) > abs(pageUp(player))


# Whether a player is in the lobby looking at its pages, and how many degrees they're
# looking away from LOOK_ANGLE
macro isOnPage(player):
    (player.isInLobby and not player.isLoading and player.faqPage == 0)


macro angleFromPage(player):
    angleBetweenVectors(player.getFacingDirection(), lobbyForward)


# Whether a player in the lobby has looked far enough from the page to be shown the way
# back to it (Load Buttons)
macro isPageLost(player):
    (isOnPage(player) and angleFromPage(player) > MARKER_ANGLE)


# Whether a player is being turned back toward the page, or should start or stop being
# turned (Pull Back, Release)
macro isPullStarting(player):
    (
        not player.isPulledToPage
        and isOnPage(player)
        and angleFromPage(player) > PULL_ANGLE
    )


macro isPullEnding(player):
    (
        player.isPulledToPage
        and (not isOnPage(player) or angleFromPage(player) < RELEASE_ANGLE)
    )


# A spot in a column across degrees right of the page's middle (negative is left), like the
# languages'. A column at one horizontal angle would lean outward toward its bottom on
# screen, so its spots share a plane with the eyes instead, which shows as an upright line
# from LOOK_ANGLE.
macro columnAt(angle, across):
    (
        lobbyCam
        + normalize(
            directionFromAngles(lobbyAngle, angle)
            + lobbyRight * tanDeg(across) * cosDeg(angle - LOOK_ANGLE)
        )
        * LOBBY_DISTANCE
    )


macro languageAt(angle):
    columnAt(angle, LANGUAGE_ACROSS)


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
    # The main page, or the HUD page when HUD set -HUD_PAGE on the way in (Controls: HUD), so
    # the main page doesn't flash up first
    eventPlayer.lobbyPage = max(1, -eventPlayer.lobbyPage)
    eventPlayer.isInFreemode = false
    eventPlayer.isInPracticeMode = false
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
    # Looking around is all there is to do. Both fires pick a button and Melee closes a
    # run's info (Select Input), and their presses can still be read with them off, which
    # also keeps Melee from punching the others held here. Everything's disallowed rather
    # than disabled so all the icons look the same, as slam's and ball form's can't show as
    # off together, and a checkpoint's bans are lifted so they don't show here. The hero HUD
    # stays, as hiding it hides the crosshair too.
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.CROUCH)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setFacing(directionTowards(lobbyCam, lobbyPos[0]), Relativity.TO_WORLD)
    wait()


def leaveLobby():
    @Name "Leave"

    # Undoes Load. Each checkpoint sets the rest of the abilities (Checkpoint: Set Abilities).
    eventPlayer.isInLobby = false
    eventPlayer.lobbyPage = 0
    # Right away rather than in Release, so the pull can't turn them from their CP
    if eventPlayer.isPulledToPage:
        eventPlayer.stopFacing()
        eventPlayer.isPulledToPage = false
    eventPlayer.setGravity(100)
    eventPlayer.setMoveSpeed(100)
    eventPlayer.setJumpVerticalSpeed(100)
    eventPlayer.setInvisibility(Invis.NONE)
    # Back to ball form, which Load took them out of. Ability 1 is allowed for the press, as
    # it's disallowed here. Spectator has swapped them to Jetpack Cat by now, so it's left out.
    if eventPlayer.getHero() == Hero.WRECKING_BALL:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        waitUntil(eventPlayer.isUsingAbility1(), 1)
    # While Ultimate is held, letting go of it gives them back (Controls: HUD Input)
    if not eventPlayer.isHoldingButton(Button.ULTIMATE):
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.allowButton(Button.MELEE)
    else:
        eventPlayer.disallowButton(Button.ABILITY_1)


def resumeRun():
    @Name "Resume Run"

    # Back to the paused run's CP: Resume Run on the main page or the HUD page, or HUD
    # (Controls) on the HUD page
    eventPlayer.isLoading = true
    leaveLobby()
    cpResetPlayer()
    setCpAbilities()
    showCpNameplate()
    faceNextCp()
    eventPlayer.isLoading = false


# Where a player is looking on the page, as seen from LOOK_ANGLE, where their eyes are:
# the vertical angle it lines up with (negative is up), and how far right of the page's
# middle it is. Measured from the page, not the horizon, as near straight up a small turn
# is a big horizontal angle.
macro pageAngle(player):
    (
        LOOK_ANGLE
        - atan2Deg(
            dotProduct(player.getFacingDirection(), lobbyUp),
            dotProduct(player.getFacingDirection(), lobbyForward)
        )
    )


macro pageAcross(player):
    atan2Deg(
        dotProduct(player.getFacingDirection(), lobbyRight),
        dotProduct(player.getFacingDirection(), lobbyForward)
    )


# The row of a column of texts a player is looking at: 1 for its top one at the vertical
# angle top, counting down a row every spacing degrees, or 0 if they aren't looking across
# the column, which is across degrees right of the page's middle. Rows past the last wrap
# to 0.
macro lobbyAimRow(player, top, spacing, rows, across, width):
    (
        max(0, min(round((pageAngle(player) - top) / spacing) + 1, rows + 1))
        % (rows + 1)
        if abs(pageAcross(player) - across) <= width
        else 0
    )


# The button a player is looking at (lobbyPos[1] to [5]), or 0
macro buttonAimRow(player):
    lobbyAimRow(player, BUTTON_ANGLE, BUTTON_SPACING, 5, 0, BUTTON_WIDTH)


macro isAimingAtBack(player):
    (
        lobbyAimRow(
            player, ROW_ANGLE + ROW_SPACING * 9, BUTTON_SPACING, 1, 0, BUTTON_WIDTH
        )
        == 1
    )


# The leaderboard's row a player is looking at, on the leaderboard they picked (lbBoard),
# which has no rows to pick without runs
macro lbAimRow(player):
    lobbyAimRow(
        player,
        LB_ANGLE,
        ROW_SPACING,
        max(0, assistedRunCount if player.lbBoard else lbRunCount),
        0,
        ROW_WIDTH
    )


# Whether a player is looking at the leaderboard's tab on a side (-1 left, 1 right): the half
# of its first row's spot on that side
macro isAimingAtTab(player, side):
    (
        abs(pageAngle(player) - TAB_ANGLE) <= ROW_SPACING / 2
        and abs(pageAcross(player) - side * ROW_WIDTH / 2) <= ROW_WIDTH / 2
    )


# The languages' column, which is upright as seen from LOOK_ANGLE (languageAt)
macro langAimRow(player):
    lobbyAimRow(
        player, ROW_ANGLE, LANGUAGE_SPACING, LANGUAGES, LANGUAGE_ACROSS, LANGUAGE_WIDTH
    )


# The main page's Lobby Stats button, across from the languages' title
macro isAimingAtLobbyStats(player):
    (
        lobbyAimRow(
            player, TITLE_ANGLE, BUTTON_SPACING, 1, -LANGUAGE_ACROSS, LANGUAGE_WIDTH
        )
        == 1
    )


# Whether a player is looking at a HUD page line: the one at the page angle angle
# (pageAngle), in the column across degrees right of the page's middle
macro isAimingAtHudLine(player, angle, across):
    (
        abs(pageAngle(player) - (angle)) <= HUD_LINE_GAP / 2
        and abs(pageAcross(player) - (across)) <= HUD_ROW_WIDTH
    )


# The k-th line (from 0) of a HUD page box (hudBoxTop), in the column across
macro isAimingAtBoxLine(box, k, across):
    isAimingAtHudLine(localPlayer, hudBoxTop[box] + HUD_LINE_GAP * k, across)


# Where a player is looking on the page (pageAngle, pageAcross), worked out once for a whole
# box: a box's text maps over a one-item array holding it and its lines' texts, so its lines
# share them instead of each working them out again
macro hudLook():
    vect(pageAngle(localPlayer), pageAcross(localPlayer), 0)


# Whether that look (v[0]) is at the k-th line (from 0) of a box (hudBoxTop), in the column
# across
macro isLookAtBoxLine(v, box, k, across):
    (
        abs(v[0].x - (hudBoxTop[box] + HUD_LINE_GAP * k)) <= HUD_LINE_GAP / 2
        and abs(v[0].y - (across)) <= HUD_ROW_WIDTH
    )


# A HUD page line's text with its white values and keys back in its row's color
macro hudStrip(text):
    text.replace("<fgFFFFFFFF>", "").replace("</fg>", "")


# A line of a HUD page box: onText while it's on (its text, in its own color if it isn't the
# box's), all gray while it's off, with the buttons' arrows around it while it's looked at
macro hudBoxLine(line, text, onText, isAimedAt):
    "{}{}{}".format(
        "{}  ".format(iconString(Icon.ARROW_RIGHT)) if isAimedAt else HUD_ARROW_ROOM_L,
        (
            "<fg808080FF>{}</fg>".format(hudStrip(text))
            if localPlayer.hudHidden[line]
            else onText
        ),
        "  {}".format(iconString(Icon.ARROW_LEFT)) if isAimedAt else HUD_ARROW_ROOM_R
    )


# A button's text: its label, with arrows on either side while it's looked at, like the
# leaderboard's row. Only its text changes, so nothing moves. The label goes into one of two
# stored templates (lobbyArrows) instead of being written out with and without the arrows, as
# every copy of it costs elements.
macro lobbyButton(label, isAimedAt):
    lobbyArrows[isAimedAt].replace("@", label)


rule "Load Buttons":
    # Checkpoint: Expand Data has unpacked cps by now, as its file is included first
    lobbyCam = cps[0][0] + vect(0, LOBBY_HEIGHT, 0)
    # lobbyArrows[i]: [0]notAimedAt [1]aimedAt, for lobbyButton
    lobbyArrows = [
        "@",
        "{}  @  {}".format(iconString(Icon.ARROW_RIGHT), iconString(Icon.ARROW_LEFT))
    ]
    # The view from LOOK_ANGLE: ahead, up and to the right. Every look at the page measures
    # from them, so they're worked out once here instead of in each text.
    lobbyForward = directionFromAngles(lobbyAngle, LOOK_ANGLE)
    lobbyUp = directionFromAngles(lobbyAngle, LOOK_ANGLE - 90)
    lobbyRight = directionFromAngles(lobbyAngle - 90, 0)
    # lobbyPos[i]: [0]lookAt [1]newRun [2]resumeRun [3]spectate [4]faq [5]hud [6]back
    lobbyPos = [lobbyAt(LOOK_ANGLE)]
    for index in range(1, 6):
        lobbyPos[index] = lobbyAt(BUTTON_ANGLE + BUTTON_SPACING * (index - 1))
    # Lobby Stats' Back, where the 10th row is
    lobbyPos[6] = lobbyAt(ROW_ANGLE + ROW_SPACING * 9)
    # An arrow by the crosshair pointing back to the page, for players who looked away and
    # only see sky. It shows once the page's middle is off their screen, so it never covers
    # the page, and points left, right, up or down, whichever way the page is furthest.
    # Icons can't be resized, so it's text.
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isPageLost(localPlayer)),
        (
            (
                iconString(Icon.ARROW_LEFT)
                if pageLeft(localPlayer) > 0
                else iconString(Icon.ARROW_RIGHT)
            )
            if isPageSideways(localPlayer)
            else (
                iconString(Icon.ARROW_UP)
                if pageUp(localPlayer) > 0
                else iconString(Icon.ARROW_DOWN)
            )
        ),
        updateEveryFrame(
            lobbyCam
            + normalize(
                localPlayer.getFacingDirection()
                + normalize(
                    screenLeft(localPlayer) * pageLeft(localPlayer)
                    if isPageSideways(localPlayer)
                    else screenUp(localPlayer) * pageUp(localPlayer)
                )
                * tanDeg(MARKER_OFFSET)
            )
            * LOBBY_DISTANCE
        ),
        MARKER_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        rgb(230, 151, 0)
    )
    # With an eye on the page's middle, which clings to the edge of their screen on the
    # page's side, as close to the page as the screen goes
    createIcon(
        getAllPlayers().filter(lambda localPlayer: isPageLost(localPlayer)),
        lobbyPos[0],
        Icon.EYE,
        IconReeval.VISIBILITY,
        rgb(230, 151, 0),
        true
    )
    # The first 3 buttons are also the HUD page's (Resume Run, Hide All, Back), which sit in
    # the same spots, so the page needs no texts of its own for them: texts are capped at 128
    # per server, HUD texts included, and a full lobby nearly fills that.
    lobbyHudText[0] = _("New Run")
    lobbyHudText[2] = _("Resume Run")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isLobbyPageShown(localPlayer)),
        (
            (
                lobbyButton(_(lobbyHudText[2]), buttonAimRow(localPlayer) == 1)
                if canResumeRun(localPlayer)
                else "<fg808080FF>{}</fg>".format(_(lobbyHudText[2]))
            )
            if isHudPage(localPlayer)
            else lobbyButton(_(lobbyHudText[0]), buttonAimRow(localPlayer) == 1)
        ),
        lobbyPos[1],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    # Grayed out, with no arrows, without a run to resume. On the HUD page, Hide All, which
    # turns to Show All once every line is off.
    lobbyHudText[11] = _("Hide All")
    lobbyHudText[12] = _("Show All")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isLobbyPageShown(localPlayer)),
        (
            lobbyButton(
                (
                    _(lobbyHudText[12])
                    if areHudLinesAllOff(localPlayer)
                    else _(lobbyHudText[11])
                ),
                buttonAimRow(localPlayer) == 2
            )
            if isHudPage(localPlayer)
            else (
                lobbyButton(_(lobbyHudText[2]), buttonAimRow(localPlayer) == 2)
                if canResumeRun(localPlayer)
                else "<fg808080FF>{}</fg>".format(_(lobbyHudText[2]))
            )
        ),
        lobbyPos[2],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    # The same as the Spectate and FAQ controls, which the lobby's HUD leaves out. On the
    # HUD page, Back (Load Leaderboard).
    lobbyHudText[7] = _("Spectate")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isLobbyPageShown(localPlayer)),
        lobbyButton(
            _(lobbyHudText[4]) if isHudPage(localPlayer) else _(lobbyHudText[7]),
            buttonAimRow(localPlayer) == 3
        ),
        lobbyPos[3],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    lobbyHudText[8] = _("FAQ")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        lobbyButton(_(lobbyHudText[8]), buttonAimRow(localPlayer) == 4),
        lobbyPos[4],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    # Opens the HUD page
    lobbyHudText[9] = _("Customize HUD")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        lobbyButton(_(lobbyHudText[9]), buttonAimRow(localPlayer) == 5),
        lobbyPos[5],
        BUTTON_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(0, 224, 146)
    )
    # The column of buttons is full, so the host's Lobby Stats is on the page's empty left
    # side, across from the languages' title
    if isLobbyStatsOn:
        createInWorldText(
            getAllPlayers().filter(
                lambda localPlayer: localPlayer.lobbyPage == 1
                and "{}".format(localPlayer) == hostPlayerName
            ),
            lobbyButton("Lobby Stats", isAimingAtLobbyStats(localPlayer)),
            columnAt(TITLE_ANGLE, -LANGUAGE_ACROSS),
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
    # lbPos[i]: [0] where the rows' arrows wait (below), [1] to [10] the rows, [11] the tabs
    lbPos = []
    for index in range(1, 11):
        lbPos[index] = lobbyAt(LB_ANGLE + ROW_SPACING * (index - 1))
    lbPos[11] = lobbyAt(TAB_ANGLE)
    # lb[0] and assistedLb[0] are unused, so these are -1 without runs
    lbRunCount = len(lb) - 1
    assistedRunCount = len(assistedLb) - 1
    # The assisted leaderboard's runs follow the regular one's, from lb[11], so both are laid
    # out in one go, and lbRowText and lbRunText keep them the same way
    for index in range(1, 11):
        lb[10 + index] = assistedLb[index]
    lbRowText = []
    lbRunText = []
    allTimeRunsText = ""
    allTimeAssistedText = ""
    for index in range(1, 21):
        # The row's place on its own leaderboard
        lbRank = (index - 1) % 10 + 1
        # Rows without a run have a placeholder, as wide as a run's, a space narrower for
        # the 10th's 2-digit rank
        if lb[index] == null:
            if lbRank <= 9:
                lbObj = (
                    "---, -:--.--, -, '                                               '"
                )
            else:
                lbObj = (
                    "---, -:--.--, -, '                                              '"
                )
        else:
            lbObj = lb[index]
        # lbObj[i]: [0]name [1]time [2]mistakes, or an assisted run's ground time
        # [3]alignmentSeparator [4]rankColor [5]Top 3 row
        lbObj = lbObj.split(",")
        lbObj[3] = lbObj[3].replace("'", "")
        # The assisted board's empty rows get a ground time placeholder like the time's
        if index > 10 and lb[index] == null:
            lbObj[2] = " -:--.--"
        # Gold, silver and bronze, then the rest
        lbObj[4] = ["<fgFFFF00FF>", "<fgB0C4DEFF>", "<fgC46A30FF>", "<fgFFFFFFFF>"][
            min(lbRank, 4) - 1
        ]
        lbRowText[index] = "{}. {}{}</fg>{}{}{}{}   {}{}</fg>".format(
            lbRank,
            lbObj[4],
            lbObj[0],
            lbObj[3],
            iconString(Icon.BOLT),
            lbObj[4],
            lbObj[1],
            (
                abilityIconString(Hero.WRECKING_BALL, Button.CROUCH)
                if index > 10
                else iconString(Icon.SKULL)
            ),
            lbObj[2]
        )
        # The row without its alignment, for the run info (lbRunInfo)
        lbRunText[index] = "{}. {}{}</fg>   {}{}{}   {}{}</fg>".format(
            lbRank,
            lbObj[4],
            lbObj[0],
            iconString(Icon.BOLT),
            lbObj[4],
            lbObj[1],
            (
                abilityIconString(Hero.WRECKING_BALL, Button.CROUCH)
                if index > 10
                else iconString(Icon.SKULL)
            ),
            lbObj[2]
        )
        # Each leaderboard's first 3 rows, placeholders and all, are its All-Time Top 3 on
        # the HUD (Run: Load HUD), laid out like the Lobby Top 3 (Completion: Record Top Run)
        if lbRank <= 3:
            lbObj[1] = lbObj[1].replace(" ", "")
            lbObj[2] = lbObj[2].replace(" ", "")
            # The assisted one's scores are ground times, with a " _" instead of the ×. One row
            # is laid out for either, so topRunRow is only spelled out once.
            lbObj[5] = topRunRow(
                "",
                lbRank - 1,
                lbObj[0],
                (lbObj[2] if index > 10 else "{}×".format(lbObj[2])),
                index > 10,
                lbObj[1],
                false,
                index > 10
            )
            if index <= 10:
                allTimeRunsText = "{}{}".format(allTimeRunsText, lbObj[5])
            else:
                allTimeAssistedText = "{}{}".format(allTimeAssistedText, lbObj[5])
    # The rows, which show the runs of the leaderboard each player picked (lbBoard)
    for index in range(1, 11):
        createInWorldText(
            getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
            lbRowText[evalOnce(index) + localPlayer.lbBoard],
            lbPos[index],
            ROW_SIZE,
            Clip.NONE,
            WorldTextReeval.VISIBILITY_AND_STRING,
            rgb(230, 151, 0)
        )
    # The tabs that pick it (Select Input). The picked one is green, like the language a
    # player is reading, and the other orange, like the other languages, and either gets the
    # buttons' arrows while it's looked at. The arrows don't move its label, as they sit on
    # both sides of it, inside its pad.
    # On the HUD page, the first is its ballkour.com row, at the top like on the HUD: texts are
    # capped at 128 per server (Load Buttons).
    lobbyHudText[13] = _("Unassisted")
    lobbyHudText[14] = _("Assisted")
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isLobbyPageShown(localPlayer)),
        (
            # ballkour.com with the course's credit under it, one line each
            [[hudLook(), _(creditHudText).replace("@0", COURSE_AUTHOR)]].map(
                lambda v: (
                    "{}"
                    "\n{}"
                ).format(
                    hudBoxLine(
                        HUD_SITE,
                        "ballkour.com",
                        "ballkour.com",
                        isLookAtBoxLine(v, 0, 0, 0)
                    ),
                    hudBoxLine(
                        HUD_CREDIT,
                        v[1],
                        "<fgB4B4B4FF>{}</fg>".format(v[1]),
                        isLookAtBoxLine(v, 0, 1, 0)
                    )
                )
            )[0]
            if isHudPage(localPlayer)
            else "{}{}­".format(
                lobbyButton(_(lobbyHudText[13]), isAimingAtTab(localPlayer, -1)),
                LB_TAB_PAD
            )
        ),
        hudBoxPos[0] if isHudPage(localPlayer) else lbPos[11],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        (
            rgb(230, 151, 0)
            if localPlayer.lbBoard and not isHudPage(localPlayer)
            else rgb(0, 224, 146)
        )
    )
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 1),
        "­{}{}".format(
            LB_TAB_PAD, lobbyButton(_(lobbyHudText[14]), isAimingAtTab(localPlayer, 1))
        ),
        lbPos[11],
        ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_STRING_AND_COLOR,
        rgb(0, 224, 146) if localPlayer.lbBoard else rgb(230, 151, 0)
    )
    # Lobby Stats' way back to the buttons and leaderboard, only made where Lobby Stats is,
    # as every text counts toward the cap (Load Buttons). The HUD page's Back uses its label.
    lobbyHudText[4] = _("Back")
    if isLobbyStatsOn:
        createInWorldText(
            getAllPlayers().filter(lambda localPlayer: localPlayer.lobbyPage == 2),
            lobbyButton(_(lobbyHudText[4]), isAimingAtBack(localPlayer)),
            lobbyPos[6],
            BUTTON_SIZE,
            Clip.NONE,
            WorldTextReeval.VISIBILITY_AND_STRING,
            rgb(0, 224, 146)
        )
    # The rows are made, and lbRowText and lbRunText keep what they need
    lb = null
    assistedLb = null
    lbObj = null
    # Courses without runs on either leaderboard have no run info
    if lbRunCount <= 0 and assistedRunCount <= 0:
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
    # Under the rows, while the picked leaderboard has runs to click on
    lobbyHudText[5] = _("Click on a Run to View More Info")
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.lobbyPage == 1
            and (assistedRunCount if localPlayer.lbBoard else lbRunCount) > 0
        ),
        _(lobbyHudText[5]),
        lobbyAt(LB_ANGLE + ROW_SPACING * 10),
        HINT_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        rgb(230, 151, 0)
    )


# The white of a HUD page row's values and keys, as the HUD has them, gray with the rest of
# the row while its line is off, as a row's color can't reach the colors inside its text
macro hudPageWhite(hudLine):
    ("<fg808080FF>" if localPlayer.hudHidden[hudLine] else "<fgFFFFFFFF>")


# A line's own text, its white values and keys gray while the line is off
macro hudPageText(text, hudLine):
    text.replace("<fgFFFFFFFF>", hudPageWhite(hudLine))


# A value in white, like the HUD's numbers, gray while the line is off
macro hudPageValue(hudLine, value):
    "{}{}</fg>".format(hudPageWhite(hudLine), value)


# Best and Avg, which the HUD stacks, side by side to fit a row
macro hudPageStats(text, hudLine):
    (
        hudPageText(text, hudLine)
        .replace("\n", "   ")
        .replace("@0", "--")
        .replace("@1", "--")
    )


# A language's row, which is also the HUD page's right column's row at the same place in
# its column (hudRightPos), showing the HUD line it turns on and off. One text for both, as
# texts are capped at 128 per server (Load Buttons). Each language is in its own language,
# in the order of #!translations (ballkour.opy), and the one a player is reading is green.
# The HUD line gets the buttons' arrows while it's looked at, as its width differs by
# language, so no one gap clears it everywhere.
# gaps is how many box gaps are above the row (Load HUD Page).
macro languageRow(row, line, gaps, hudText):
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isLobbyPageShown(localPlayer)),
        (
            lobbyButton(
                hudText,
                isAimingAtHudLine(
                    localPlayer, ROW_ANGLE + HUD_LINE_GAP * (row - 1 + gaps), HUD_ACROSS
                )
            )
            if isHudPage(localPlayer)
            else (
                "<fg00E092FF>{}</fg>".format(evalOnce(langNames[row - 1]))
                if localPlayer.__languageIndex__ == row - 1
                else evalOnce(langNames[row - 1])
            )
        ),
        hudRightPos[row] if isHudPage(localPlayer) else langPos[row],
        LANGUAGE_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        (
            rgb(128, 128, 128)
            if isHudPage(localPlayer) and localPlayer.hudHidden[line]
            else rgb(230, 151, 0)
        )
    )


# A right column row that lines up with the rows of its box at one left edge (HUD_RIGHT_PAD),
# with the arrows' room kept on its line while it isn't looked at, like the left column's
macro languageBoxRow(row, line, gaps, hudText):
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isLobbyPageShown(localPlayer)),
        (
            # Whether it's looked at, worked out once for both arrows
            [
                isAimingAtHudLine(
                    localPlayer, ROW_ANGLE + HUD_LINE_GAP * (row - 1 + gaps), HUD_ACROSS
                )
            ].map(
                lambda a: (
                    "{}"
                    "\n{}{}{}"
                ).format(
                    HUD_RIGHT_PAD,
                    (
                        "{}  ".format(iconString(Icon.ARROW_RIGHT))
                        if a
                        else HUD_ARROW_ROOM_L
                    ),
                    hudText,
                    (
                        "  {}".format(iconString(Icon.ARROW_LEFT))
                        if a
                        else HUD_ARROW_ROOM_R
                    )
                )
            )[
                0
            ]
            if isHudPage(localPlayer)
            else (
                "<fg00E092FF>{}</fg>".format(evalOnce(langNames[row - 1]))
                if localPlayer.__languageIndex__ == row - 1
                else evalOnce(langNames[row - 1])
            )
        ),
        hudRightPos[row] if isHudPage(localPlayer) else langPos[row],
        LANGUAGE_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        (
            rgb(128, 128, 128)
            if isHudPage(localPlayer) and localPlayer.hudHidden[line]
            else rgb(230, 151, 0)
        )
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
    # Arrows around the language being looked at, like the leaderboard's, parked far below
    # the lobby at langPos[0] otherwise
    langPos[0] = langPos[1] + vect(0, -1000, 0)
    # The languages are also the HUD page's right column, which has as many rows (see
    # languageRow)
    languageBoxRow(
        1,
        HUD_RUNS,
        0,
        _(counterHudText[0]).replace(
            "@0", hudPageValue(HUD_RUNS, localPlayer.runCount)
        )
    )
    languageBoxRow(
        2,
        HUD_ATTEMPTS,
        0,
        _(counterHudText[1]).replace(
            "@0",
            hudPageValue(
                HUD_ATTEMPTS, localPlayer.cpAttempts[localPlayer.runCurrentCp]
            )
        )
    )
    languageBoxRow(
        3,
        HUD_CP_MISTAKES,
        0,
        _(counterHudText[6]).replace(
            "@0",
            hudPageValue(
                HUD_CP_MISTAKES, localPlayer.cpMistakes[localPlayer.runCurrentCp]
            )
        )
    )
    languageBoxRow(
        4,
        HUD_CP,
        1,
        "{} {}/{}".format(iconString(Icon.FLAG), localPlayer.viewCp, lastCp)
    )
    languageBoxRow(
        5,
        HUD_TIME,
        1,
        "{} {}".format(iconString(Icon.BOLT), localPlayer.runTimeFormatted)
    )
    languageBoxRow(
        6,
        HUD_MISTAKES,
        1,
        (
            "{} {}".format(
                abilityIconString(Hero.WRECKING_BALL, Button.CROUCH),
                localPlayer.runGroundTimeFormatted
            )
            if localPlayer.isInAssistMode
            else "{} {}".format(iconString(Icon.SKULL), localPlayer.runMistakes)
        )
    )
    languageRow(
        7, HUD_SPLIT_CP, 2, "{} {}".format(iconString(Icon.FLAG), localPlayer.viewCp)
    )
    languageRow(
        8,
        HUD_ATTEMPT,
        2,
        _(splitsHudText[0]).replace(
            "@0", hudPageValue(HUD_ATTEMPT, localPlayer.cpTimeFormatted)
        )
    )
    languageRow(
        9, HUD_ATTEMPT_STATS, 2, hudPageStats(_(splitsHudText[1]), HUD_ATTEMPT_STATS)
    )
    languageRow(
        10,
        HUD_SPLIT,
        2,
        _(splitsHudText[2]).replace(
            "@0", hudPageValue(HUD_SPLIT, localPlayer.splitTimeFormatted)
        )
    )
    languageRow(
        11, HUD_SPLIT_STATS, 2, hudPageStats(_(splitsHudText[3]), HUD_SPLIT_STATS)
    )
    languageRow(
        12,
        HUD_PACE,
        2,
        _(splitsHudText[4])
        .replace("\n", "")
        .replace("@0", hudPageValue(HUD_PACE, localPlayer.paceEtaFormatted))
    )
    languageBoxRow(13, HUD_ALL_TIME_TOP, 4, _(allTimeRunsHudText))
    languageBoxRow(14, HUD_LOBBY_TOP, 4, _(topRunsHudText))
    # The languages' arrows, one text that moves to the language looked at. The names are
    # short, so one width clears them all. The HUD page's rows are wider and differ by
    # language, so they carry their own arrows, like the buttons (languageRow).
    createInWorldText(
        getAllPlayers().filter(
            lambda localPlayer: isLobbyPageShown(localPlayer)
            and not isHudPage(localPlayer)
        ),
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


# A strike over a text: a line of em dashes, dashes[language] long (en, de, es, fr, it, ja, ko,
# pl, pt, ru, th, tr, zh_cn, zh_tw), as the Workshop has no strikethrough. Up to 50 fit.
macro strikeDashes(dashes):
    "——————————————————————————————————————————————————".substring(
        0, dashes[localPlayer.__languageIndex__]
    )


# A box's text, on its last line (Load HUD Page)
macro hudBoxText(box, text, color):
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isHudPage(localPlayer)),
        text,
        hudBoxPos[box],
        HUD_ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_STRING,
        color
    )
    hudPageTexts.append(getLastCreatedText())


rule "Load HUD Page":
    # hudBoxLines[i]: the HUD_ numbers of box i's lines. [0] ballkour.com and the credit,
    # [1] to [5] the left column's, [6] to [9] the right column's.
    hudBoxLines = [
        [HUD_SITE, HUD_CREDIT],
        [HUD_CONTROLS, HUD_FAQ, HUD_HINTS],
        [HUD_DISQUALIFIED, HUD_ASSIST, HUD_FREEMODE],
        [HUD_SPECTATORS, HUD_SPECTATING],
        [HUD_FREECAM, HUD_DISCONNECTED],
        [HUD_SCORECARD],
        [HUD_RUNS, HUD_ATTEMPTS, HUD_CP_MISTAKES],
        [HUD_CP, HUD_TIME, HUD_MISTAKES],
        [
            HUD_SPLIT_CP,
            HUD_ATTEMPT,
            HUD_ATTEMPT_STATS,
            HUD_SPLIT,
            HUD_SPLIT_STATS,
            HUD_PACE,
            HUD_SPEED
        ],
        [HUD_ALL_TIME_TOP, HUD_LOBBY_TOP]
    ]
    # Where a look at each box is measured from (Select Input)
    hudBoxAcross = [
        0,
        HUD_LEFT_AIM,
        HUD_LEFT_AIM,
        HUD_LEFT_AIM,
        HUD_LEFT_AIM,
        HUD_LEFT_AIM,
        HUD_ACROSS,
        HUD_ACROSS,
        HUD_ACROSS,
        HUD_ACROSS
    ]
    # hudBoxTop[i]: the page angle of box i's first line. ballkour.com stays at TITLE_ANGLE,
    # with the credit under it. The left column's boxes start on its 1st, 4th, 7th, 9th and
    # 11th lines, and the right column's on its 1st, 4th, 7th and 13th, each a line's gap
    # further down than the one above.
    hudBoxTop = [
        TITLE_ANGLE,
        ROW_ANGLE,
        ROW_ANGLE + HUD_LINE_GAP * 4,
        ROW_ANGLE + HUD_LINE_GAP * 8,
        ROW_ANGLE + HUD_LINE_GAP * 11,
        ROW_ANGLE + HUD_LINE_GAP * 14,
        ROW_ANGLE,
        ROW_ANGLE + HUD_LINE_GAP * 4,
        ROW_ANGLE + HUD_LINE_GAP * 8,
        ROW_ANGLE + HUD_LINE_GAP * 16
    ]
    # Each box's text sits on its last line: ballkour.com's in the page's middle and the
    # left column's at HUD_LEFT_ACROSS. The right column's rows are a text each
    # (languageRow).
    hudBoxPos = [lobbyAt(TITLE_ANGLE + HUD_LINE_GAP)]
    for index in range(1, 6):
        hudBoxPos[index] = columnAt(
            hudBoxTop[index] + HUD_LINE_GAP * (len(hudBoxLines[index]) - 1),
            HUD_LEFT_ACROSS
        )
    # The right column's rows, by language row: Speed is under the 12th, its own text (Show
    # HUD Page), so the Top 3s are a line lower. Its 3 boxes that are one text on the HUD sit
    # at HUD_RIGHT_ACROSS, so they line up (languageBoxRow).
    hudRightPos = []
    for index in range(1, 15):
        hudRightPos[index] = columnAt(
            ROW_ANGLE
            + HUD_LINE_GAP
            * (index - 1 + [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4][index]),
            [0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1][index]
            * (HUD_RIGHT_ACROSS - HUD_ACROSS)
            + HUD_ACROSS
        )
    # The scorecard and the Top 3s show full on the page, with made-up players, so turning
    # them off shows the room they can take: 12 players, each section of the scorecard
    # (disqualified, Assist Mode, freemode, spectating, lobby) and mark (skipped CP, assisted
    # run), and runs that aren't anyone's real ones. Laid out like the real ones (Update
    # Scorecard, Load Leaderboard, Record Top Run).
    hudPageScorecard = "{}    {}       {}{}".format(
        iconString(Icon.FLAG),
        iconString(Icon.BOLT),
        iconString(Icon.SKULL),
        (
            "\n87     6:41       12     GrappleGod <fgFF4646FF>»</fg>"
            "\n64     5:02       8       HammondFan<fgFF80C0FF>•</fg>"
            "\n41     3:57       6       Minefield"
            "\n30     2:48       21     RollOut"
            "\n22     2:05       3       SpinnyBoi"
            "\n9       58           30     BallPit"
            "\n<fgFF4646FF>52     4:20       15     PileDriver</fg> <fgFF4646FF>×</fg>"
            "\n<fgFF80C0FF>46     4:48       2       WreckingCrew</fg>"
            "\n<fgCB87FFFF>70     9:15       40     ShieldSurfer</fg> <fgFF4646FF>×</fg>"
            "\n<fgCB87FFFF>15     1:30       2       Hamsterdam</fg>"
            "\n<fg00BEFFFF>33     3:10       9       MechaMouse</fg>"
            "\n<fg808080FF>0       0             0       QuickSilver</fg>"
        )
    )
    hudPageAllTimeText = (
        "\n<fgFFFF00FF>1   3:41.07     4×     TurboHamster</fg>"
        "\n<fgB0C4DEFF>2   3:48.52     9×     OrbWeaver</fg>"
        "\n<fgC46A30FF>3   4:02.19     11×   BoopMachine</fg>"
    )
    hudPageTopRunsText = (
        "\n<fgFFFF00FF>1   4:15.66     7×     DizzyDrifter</fg>"
        "\n<fgB0C4DEFF>2   4:31.40     13×   SlamJam</fg><fgFF80C0FF>•</fg>"
        "\n<fgC46A30FF>3   5:07.93     18×   LooseCannon</fg>"
    )


rule "Show HUD Page":
    @Condition getAllPlayers().any(lambda p: isHudPage(p)) == true

    # Its texts only exist while someone's on it, as every text's definition adds to the
    # server's load, like an open run's info (lbRunInfo). The HUD itself shows around the
    # page (isCourseHudShown), lines that only show sometimes too, so turning a row off shows
    # what goes and what moves up. Its own texts are all made in one tick (7 of them), as
    # the main page's texts it borrows wait for them (isLobbyPageShown). Its ballkour.com row
    # is the leaderboard's first tab (Load Leaderboard).
    hudPageTexts = []
    # The left column, a text per box, each line's color in the text. Each starts with
    # HUD_LEFT_PAD, so they all line up.
    hudBoxText(
        1,
        [
            [
                hudLook(),
                _(runHudText).replace("@0", inputBindingString(Button.ULTIMATE)),
                _(faqHudText[0])
                .replace("@0", inputBindingString(Button.ULTIMATE))
                .replace("@1", inputBindingString(Button.MELEE)),
                _(hintsHudText[0])
                .replace("@0", "")
                .replace("@1", "<fgFFFFFFFF>")
                .replace("@2", inputBindingString(Button.ULTIMATE))
                .replace("@3", inputBindingString(Button.ABILITY_2))
            ]
        ].map(
            lambda v: (
                "{}"
                "\n{}"
                "\n{}"
                "\n{}"
            ).format(
                HUD_LEFT_PAD,
                hudBoxLine(
                    HUD_CONTROLS, v[1], v[1], isLookAtBoxLine(v, 1, 0, HUD_LEFT_AIM)
                ),
                hudBoxLine(HUD_FAQ, v[2], v[2], isLookAtBoxLine(v, 1, 1, HUD_LEFT_AIM)),
                hudBoxLine(
                    HUD_HINTS, v[3], v[3], isLookAtBoxLine(v, 1, 2, HUD_LEFT_AIM)
                )
            )
        )[
            0
        ],
        rgb(230, 151, 0)
    )
    # Disqualified can't be turned off (Run: isDisqualifiedLineShown), so it never grays out
    # or gets arrows, and a second text strikes it through (below). The box's color is
    # Freemode On's, so its arrows are too.
    hudBoxText(
        2,
        [
            [
                hudLook(),
                _(counterHudText[4]).replace("\n", ""),
                "{} / {}".format(_(freemodeHudText), _(practiceModeHudText))
            ]
        ].map(
            lambda v: (
                "{}"
                "\n{}<fgFF4646FF>{}</fg>{}"
                "\n{}"
                "\n{}"
            ).format(
                HUD_LEFT_PAD,
                HUD_ARROW_ROOM_L,
                _(counterHudText[3]).replace("\n", ""),
                HUD_ARROW_ROOM_R,
                hudBoxLine(
                    HUD_ASSIST,
                    v[1],
                    "<fgFF80C0FF>{}</fg>".format(v[1]),
                    isLookAtBoxLine(v, 2, 1, HUD_LEFT_AIM)
                ),
                hudBoxLine(
                    HUD_FREEMODE, v[2], v[2], isLookAtBoxLine(v, 2, 2, HUD_LEFT_AIM)
                )
            )
        )[
            0
        ],
        rgb(203, 135, 255)
    )
    # The strike: the box's lines, so it lines up with it, Disqualified's an em dash line
    # (strikeDashes) and the others soft hyphens, which show nothing. The dashes are counted per
    # language to cover each translation (an em dash is about 12 px wide at 1080p).
    hudBoxText(
        2,
        (
            "{}"
            "\n{}{}"
            "\n­"
            "\n­"
        ).format(
            HUD_LEFT_PAD,
            HUD_ARROW_ROOM_L,
            strikeDashes([9, 11, 10, 8, 9, 3, 3, 15, 12, 15, 7, 8, 8, 8])
        ),
        rgb(255, 70, 70)
    )
    hudBoxText(
        3,
        [
            [
                hudLook(),
                _(spectatorHudText[4])
                .replace("\n", "")
                .replace("@0", "<fgFFFFFFFF>{}</fg>".format(HUD_PAGE_SPECTATORS)),
                _(spectatorHudText[0]).replace("\n", "")
            ]
        ].map(
            lambda v: (
                "{}"
                "\n{}"
                "\n{}"
            ).format(
                HUD_LEFT_PAD,
                hudBoxLine(
                    HUD_SPECTATORS, v[1], v[1], isLookAtBoxLine(v, 3, 0, HUD_LEFT_AIM)
                ),
                hudBoxLine(
                    HUD_SPECTATING, v[2], v[2], isLookAtBoxLine(v, 3, 1, HUD_LEFT_AIM)
                )
            )
        )[
            0
        ],
        rgb(0, 190, 255)
    )
    hudBoxText(
        4,
        [[hudLook(), _(spectatorHudText[2]), _(spectatorHudText[3])]].map(
            lambda v: (
                "{}"
                "\n{}"
                "\n{}"
            ).format(
                HUD_LEFT_PAD,
                hudBoxLine(
                    HUD_FREECAM, v[1], v[1], isLookAtBoxLine(v, 4, 0, HUD_LEFT_AIM)
                ),
                hudBoxLine(
                    HUD_DISCONNECTED,
                    v[2],
                    "<fgFFFFFFFF>{}</fg>".format(v[2]),
                    isLookAtBoxLine(v, 4, 1, HUD_LEFT_AIM)
                )
            )
        )[0],
        rgb(230, 151, 0)
    )
    # The scorecard's rows are other players, so it gets a name
    lobbyHudText[10] = _("Scores")
    hudBoxText(
        5,
        [[hudLook(), _(lobbyHudText[10])]].map(
            lambda v: (
                "{}"
                "\n{}"
            ).format(
                HUD_LEFT_PAD,
                hudBoxLine(
                    HUD_SCORECARD, v[1], v[1], isLookAtBoxLine(v, 5, 0, HUD_LEFT_AIM)
                )
            )
        )[0],
        rgb(230, 151, 0)
    )
    # Speed, under Pace, the one right column row that isn't a language's
    createInWorldText(
        getAllPlayers().filter(lambda localPlayer: isHudPage(localPlayer)),
        lobbyButton(
            hudPageText(_(splitsHudText[5]).replace("@0", "0.0"), HUD_SPEED),
            isAimingAtHudLine(localPlayer, ROW_ANGLE + HUD_LINE_GAP * 14, HUD_ACROSS)
        ),
        columnAt(ROW_ANGLE + HUD_LINE_GAP * 14, HUD_ACROSS),
        HUD_ROW_SIZE,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_STRING_AND_COLOR,
        rgb(128, 128, 128) if localPlayer.hudHidden[HUD_SPEED] else rgb(230, 151, 0)
    )
    hudPageTexts.append(getLastCreatedText())
    # The borrowed texts show in the same tick, so both sides show up together
    isHudPageReady = true
    waitUntil(not getAllPlayers().any(lambda p: isHudPage(p)), Math.INFINITY)
    isHudPageReady = false
    for index in range(len(hudPageTexts)):
        destroyInWorldText(hudPageTexts[index])
    # Rechecks a tick later, like the sync rules, in case someone opened it in the same tick
    wait()
    if RULE_CONDITION:
        loop()


# Players who look too far from the page are turned back toward it, so it never leaves
# their screen. These are global rules rather than eachPlayer ones, as every eachPlayer rule
# adds to the server's load, and everyone in the lobby turns toward the same direction, as
# their eyes are all at lobbyCam. The turn runs on the server, so it starts a round trip after
# they look past PULL_ANGLE.
rule "Pull Back":
    @Condition getAllPlayers().any(lambda p: isPullStarting(p)) == true

    lobbyPulled = getAllPlayers().filter(lambda p: isPullStarting(p))
    lobbyPulled.startFacing(
        lobbyForward, PULL_RATE, Relativity.TO_WORLD, FacingReeval.NONE
    )
    lobbyPulled.isPulledToPage = true
    # Rechecks a tick later, like the sync rules, in case someone else looked away in the
    # same tick
    wait()
    if RULE_CONDITION:
        loop()


rule "Release":
    @Condition getAllPlayers().any(lambda p: isPullEnding(p)) == true

    lobbyPulled = getAllPlayers().filter(lambda p: isPullEnding(p))
    lobbyPulled.stopFacing()
    lobbyPulled.isPulledToPage = false
    wait()
    if RULE_CONDITION:
        loop()


# Interact picks a button, and so does either fire, which don't shoot in the lobby (Load).
# Melee closes an open run's info, like the FAQ.
rule "Select Input":
    @Event eachPlayer
    @Condition (
        eventPlayer.isHoldingButton(Button.INTERACT)
        or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
        or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.isHoldingButton(Button.MELEE)
    ) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isInLobby == true
    @Condition eventPlayer.isLoading == false
    # Either fire turns the FAQ's pages
    @Condition eventPlayer.faqPage == 0

    if eventPlayer.isHoldingButton(Button.MELEE):
        # Wherever they're looking
        if eventPlayer.lbInfoRow != 0:
            eventPlayer.lbInfoRow = 0
            showRunInfo()
    elif eventPlayer.lobbyPage == 1:
        eventPlayer.lobbyAim = buttonAimRow(eventPlayer)
        if eventPlayer.lobbyAim == 1:
            newRun()
        elif eventPlayer.lobbyAim == 2:
            if canResumeRun(eventPlayer):
                resumeRun()
        elif eventPlayer.lobbyAim == 3:
            toggleSpectator()
        elif eventPlayer.lobbyAim == 4:
            # Once a fire is let go, as either fire turns the FAQ's pages (FAQ: Open)
            waitUntil(
                not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                and not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
                Math.INFINITY
            )
            eventPlayer.faqPage = 1
        elif eventPlayer.lobbyAim == 5:
            eventPlayer.lobbyPage = HUD_PAGE
        elif (
            isLobbyStatsOn
            and isAimingAtLobbyStats(eventPlayer)
            and "{}".format(eventPlayer) == hostPlayerName
        ):
            eventPlayer.lobbyPage = 2
        else:
            eventPlayer.lobbyAim = langAimRow(eventPlayer)
            if eventPlayer.lobbyAim > 0:
                eventPlayer.__languageIndex__ = eventPlayer.lobbyAim - 1
            else:
                # A tab picks its leaderboard (lbBoard): 0 for the regular one's on the left,
                # 10 for the assisted one's on the right. Picking the other closes its open run.
                if isAimingAtTab(eventPlayer, -1):
                    eventPlayer.lobbyAim = 0
                elif isAimingAtTab(eventPlayer, 1):
                    eventPlayer.lobbyAim = 10
                else:
                    eventPlayer.lobbyAim = -1
                if eventPlayer.lobbyAim >= 0:
                    if eventPlayer.lobbyAim != eventPlayer.lbBoard:
                        eventPlayer.lbBoard = eventPlayer.lobbyAim
                        if eventPlayer.lbInfoRow != 0:
                            eventPlayer.lbInfoRow = 0
                            showRunInfo()
                elif lbRunCount > 0 or assistedRunCount > 0:
                    # A row's run, on the picked leaderboard: lbInfoRow 1 to 10 for the
                    # regular one's, 11 to 20 for the assisted one's (lbRunText)
                    eventPlayer.lobbyAim = lbAimRow(eventPlayer)
                    if eventPlayer.lobbyAim > 0:
                        eventPlayer.lobbyAim += eventPlayer.lbBoard
                    # Looking at the open run again hides it, like looking away from the runs
                    if eventPlayer.lobbyAim == eventPlayer.lbInfoRow:
                        eventPlayer.lobbyAim = 0
                    if eventPlayer.lobbyAim != eventPlayer.lbInfoRow:
                        eventPlayer.lbInfoRow = eventPlayer.lobbyAim
                        showRunInfo()
    elif isHudPage(eventPlayer):
        eventPlayer.lobbyAim = buttonAimRow(eventPlayer)
        if eventPlayer.lobbyAim == 1:
            if canResumeRun(eventPlayer):
                resumeRun()
        elif eventPlayer.lobbyAim == 2:
            # Hide All, which leaves Disqualified on, or Show All once every other line is off
            if areHudLinesAllOff(eventPlayer):
                eventPlayer.hudHidden = eventPlayer.hudHidden.map(lambda line: false)
            else:
                eventPlayer.hudHidden = eventPlayer.hudHidden.map(
                    lambda line, i: i != HUD_DISQUALIFIED
                )
        elif eventPlayer.lobbyAim == 3:
            eventPlayer.lobbyPage = 1
        else:
            # The line looked at, as its HUD_ number: the box line nearest the aim, if it's
            # within half a line (Load HUD Page)
            for eventPlayer.index in range(len(hudBoxLines)):
                eventPlayer.lobbyAim = round(
                    (pageAngle(eventPlayer) - hudBoxTop[eventPlayer.index])
                    / HUD_LINE_GAP
                )
                if (
                    eventPlayer.lobbyAim >= 0
                    and eventPlayer.lobbyAim < len(hudBoxLines[eventPlayer.index])
                    and abs(pageAcross(eventPlayer) - hudBoxAcross[eventPlayer.index])
                    <= HUD_ROW_WIDTH
                ):
                    eventPlayer.lobbyAim = hudBoxLines[eventPlayer.index][
                        eventPlayer.lobbyAim
                    ]
                    # Disqualified can't be turned off (Run: isDisqualifiedLineShown)
                    if eventPlayer.lobbyAim != HUD_DISQUALIFIED:
                        eventPlayer.hudHidden[eventPlayer.lobbyAim] = (
                            not eventPlayer.hudHidden[eventPlayer.lobbyAim]
                        )
                    return
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
    # These are the only progress bar texts, and with no run open there are none, as they
    # count toward the server's 128 texts (Load Buttons).
    destroyAllProgressBarInWorldTexts()
    if not getAllPlayers().any(lambda p: p.lbInfoRow != 0):
        return
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
            _(lobbyHudText[1]).replace("@0", inputBindingString(Button.MELEE)),
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
