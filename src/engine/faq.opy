#!mainFile "../main.opy"
#!rulePrefix "FAQ"


# Each page is FAQ_PAGE_LENGTH answers, which all fit above the hero bar
macro FAQ_PAGE_LENGTH = 6


# The answer in a slot of the page the player is on, from faqHudText[1]
macro faqAnswer(faqSlot):
    faqHudText[(localPlayer.faqPage - 1) * FAQ_PAGE_LENGTH + faqSlot]


rule "Open":
    @Event eachPlayer
    @Condition eventPlayer.faqPage > 0

    # Controls: FAQ Input opens and closes it. Every eachPlayer rule adds to the server's
    # periodic load, and six of them for the FAQ were enough to close the server, so this one
    # rule does all of it: closing, turning pages, the sky camera, and locking the player in
    # place. Interact closes the FAQ and Jump turns its page, so it doesn't jump while it's
    # open, or once it closes until Jump is let go.
    eventPlayer.disallowButton(Button.JUMP)
    # Every HUD text but the FAQ's hides while it's open, and so does the hero's own HUD
    eventPlayer.disableHeroHud()
    # Looks up into the sky from high above the player, so the FAQ has a plain background.
    # Spectator mode leaves this camera alone until the FAQ closes.
    eventPlayer.startCamera(
        eventPlayer.getEyePosition() + vect(0, 100, 0),
        eventPlayer.getEyePosition()
        + vect(0, 100, 0)
        + directionFromAngles(eventPlayer.getHorizontalFacingAngle(), -45),
        50
    )
    # Each pass locks the player for the mode they're in, until the FAQ closes or they
    # switch between playing, watching someone and freecam
    while eventPlayer.faqPage > 0:
        if not eventPlayer.spectating[0]:
            # Without Rooted, which would stop mistakes and clears from counting, or
            # forcing their position, which would undo Reset CP's teleport. Momentum
            # carries on, so a jump lands as usual.
            eventPlayer.setMoveSpeed(0)
            eventPlayer.disallowButton(Button.PRIMARY_FIRE)
            eventPlayer.disallowButton(Button.SECONDARY_FIRE)
            eventPlayer.disallowButton(Button.ABILITY_1)
            eventPlayer.disallowButton(Button.ABILITY_2)
            waitUntil(
                eventPlayer.faqPage == 0
                or eventPlayer.isHoldingButton(Button.INTERACT)
                or eventPlayer.isHoldingButton(Button.JUMP)
                or eventPlayer.spectating[0],
                Math.INFINITY
            )
            # A page turn locks them again on the next pass
            if not eventPlayer.spectating[0] and (
                eventPlayer.isHoldingButton(Button.INTERACT)
                or not eventPlayer.isHoldingButton(Button.JUMP)
            ):
                # The lobby holds them still (Lobby: Load)
                eventPlayer.setMoveSpeed(0 if eventPlayer.isInLobby else 100)
                # Otherwise letting go of Ultimate gives them back in HUD Input, and the
                # lobby keeps them (Lobby: Leave)
                if (
                    not eventPlayer.isHoldingButton(Button.ULTIMATE)
                    and not eventPlayer.isInLobby
                ):
                    eventPlayer.allowButton(Button.PRIMARY_FIRE)
                    eventPlayer.allowButton(Button.SECONDARY_FIRE)
                    eventPlayer.allowButton(Button.ABILITY_1)
                    eventPlayer.allowButton(Button.ABILITY_2)
        elif eventPlayer.spectating[2]:
            # Freecam flies, so it holds still. Reattaching forces the position itself.
            eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
            waitUntil(
                eventPlayer.faqPage == 0
                or eventPlayer.isHoldingButton(Button.INTERACT)
                or eventPlayer.isHoldingButton(Button.JUMP)
                or not eventPlayer.spectating[0]
                or not eventPlayer.spectating[2],
                Math.INFINITY
            )
            # Jetpack Cat flies up with Jump, so a page turn keeps holding it
            if eventPlayer.spectating[2] and (
                eventPlayer.isHoldingButton(Button.INTERACT)
                or not eventPlayer.isHoldingButton(Button.JUMP)
            ):
                eventPlayer.stopForcingPosition()
        else:
            # Watching someone already holds them in place
            waitUntil(
                eventPlayer.faqPage == 0
                or eventPlayer.isHoldingButton(Button.INTERACT)
                or eventPlayer.isHoldingButton(Button.JUMP)
                or not eventPlayer.spectating[0]
                or eventPlayer.spectating[2],
                Math.INFINITY
            )
        if eventPlayer.isHoldingButton(Button.INTERACT):
            # Closing once Interact is let go, so it doesn't go on to press a lobby button
            waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), Math.INFINITY)
            eventPlayer.faqPage = 0
        elif eventPlayer.isHoldingButton(Button.JUMP):
            eventPlayer.faqPage = eventPlayer.faqPage % FAQ_PAGES + 1
            waitUntil(not eventPlayer.isHoldingButton(Button.JUMP), Math.INFINITY)
    if eventPlayer.spectating[0] and not eventPlayer.spectating[2]:
        # Without a target, Hold Queued Camera takes over
        if eventPlayer.spectating[1] != null:
            startSpectatorCamera()
        # A held page turn's Jump shouldn't go on to enable freecam
        eventPlayer.spectating[9] = true
        waitUntil(not eventPlayer.isHoldingButton(Button.JUMP), Math.INFINITY)
        eventPlayer.spectating[9] = false
    else:
        eventPlayer.stopCamera()
        waitUntil(not eventPlayer.isHoldingButton(Button.JUMP), Math.INFINITY)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.enableHeroHud()
    if RULE_CONDITION:
        loop()


rule "Load HUD":
    # Under Controls at the top left, and left out of the lobby like it. Without the Hints
    # line under it, it takes a blank line in its place, so the next line doesn't land on
    # the player's name.
    faqHudText[0] = _("FAQ: <fgFFFFFFFF>@0 + @1</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby and localPlayer.faqPage == 0
        ),
        "{}{}".format(
            _(faqHudText[0])
            .replace("@0", inputBindingString(Button.ULTIMATE))
            .replace("@1", inputBindingString(Button.MELEE)),
            (
                ""
                if controlsVisible(
                    not localPlayer.isInLobby
                    and localPlayer.viewCp < lastCp
                    and len(hintRoutes) > 0
                )
                else "\n"
            )
        ),
        HudPosition.LEFT,
        0.1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Each answer is its own string, with its question in the BALLKOUR.COM green. The
    # answers are English only, with the translated ones at ballkour.com/faq: in all 14
    # languages they made pasting the script take several seconds longer.
    # Page 1
    faqHudText[1] = (
        "\nWebsite: <fgFFFFFFFF>ballkour.com</fg>"
        "\nDiscord: <fgFFFFFFFF>ballkour.com/discord</fg>"
        "\nReport Issues: <fgFFFFFFFF>ballkour.com/issues</fg>"
        "\nVersion: <fgFFFFFFFF>{}</fg>"
    ).format(VERSION)
    faqHudText[2] = (
        "\n\n<fg00E092FF>What counts as a valid run?</fg>"
        "\nYour run is only disqualified if you skip a checkpoint you haven't cleared yet this run."
        "\nGoing back or restarting checkpoints, skipping ahead to cleared checkpoints, and"
        "\nspectating are fine. Leaving an uncleared checkpoint in freemode counts as skipping it."
        "\nDisqualified runs don't count toward Lobby Top 3 or Lobby Stats."
    )
    faqHudText[3] = (
        "\n\n<fg00E092FF>What counts as a mistake?</fg>"
        "\nLanding anywhere but the next checkpoint, bhopping twice, missing a bounce checkpoint's"
        "\nbounce, dying, or leaving mid-attempt with Reset CP, Prev./Next CP, Lobby, Freemode"
        "\nor Spectate."
    )
    faqHudText[4] = (
        "\n\n<fg00E092FF>When does my run's timer start?</fg>"
        "\nWhen you leave the first checkpoint, not when you spawn."
    )
    faqHudText[5] = (
        "\n\n<fg00E092FF>What pauses my run?</fg>"
        "\nLobby/Pause and Spectate stop your timer, and Resume Run in the lobby carries on from"
        "\nyour checkpoint. Pausing away from your checkpoint counts as a mistake."
    )
    faqHudText[6] = (
        "\n\n<fg00E092FF>What is freemode for?</fg>"
        "\nPractice, with no timer and all your abilities. You can't clear checkpoints in it,"
        "\nand leaving your checkpoint with it on disqualifies your run."
    )
    # Page 2
    faqHudText[7] = (
        "\n<fg00E092FF>What do Runs and Attempts count?</fg>"
        "\nRuns counts the runs you've finished or restarted. Attempts counts your mistakes"
        "\nand clears on this checkpoint, over all your runs."
    )
    faqHudText[8] = (
        "\n\n<fg00E092FF>What do Attempt and Split mean?</fg>"
        "\nAttempt is timed from leaving the checkpoint, and Split from reaching it, so it"
        "\nincludes your mistakes. Each turns red once it's slower than your best."
        "\nAfter a clear they show your times for 2 seconds: <fgFFFF00FF>yellow</fg> on your first clear, then"
        "\n<fg00E092FF>green</fg> if faster or <fgFF4646FF>red</fg> if slower than your average. A new best is compared with your old best."
    )
    faqHudText[9] = (
        "\n\n<fg00E092FF>Are Best and Avg server records?</fg>"
        "\nNo, they're only your own times on that checkpoint, over all your runs."
        "\nThey reset when you leave or the server restarts."
    )
    faqHudText[10] = (
        "\n\n<fg00E092FF>What is Pace?</fg>"
        "\nYour estimated finish time, from this run's average split so far. Once your current"
        "\nsplit is slower than that average, it turns <fgFF4646FF>red</fg> and counts up with your time."
    )
    faqHudText[11] = (
        "\n\n<fg00E092FF>Why are some controls </fg><fg808080FF>grayed out</fg><fg00E092FF>?</fg>"
        "\nThey can't be used right now: Prev. CP on the first checkpoint, Next CP on the last,"
        "\nand the player controls while there's nobody to spectate. X-Hair Player also needs freecam."
    )
    faqHudText[12] = (
        "\n\n<fg00E092FF>What's on the scorecard?</fg>"
        "\nEach runner's checkpoint, time and mistakes, furthest first, then fastest."
        "\n<fgFF4646FF>Red</fg> runs, marked <fgFF4646FF>×</fg>, are disqualified."
    )
    # Page 3
    faqHudText[13] = (
        "\n<fg00E092FF>What do the hint colors mean?</fg>"
        "\n<fgCB87FFFF>Movement</fg>   <fgFFFFFFFF>Jump</fg>   <fgFFD200FF>Grapple</fg>   <fgFF4646FF>Piledrive</fg>   <fg00BEFFFF>Shield Bounce</fg>"
        "\nHints turn on by themselves after 10 mistakes on one checkpoint,"
        "\nand off again when you move on to another."
    )
    faqHudText[14] = (
        "\n\n<fg00E092FF>How do I get on the leaderboard?</fg>"
        "\nFinish a valid run and submit a video of it at ballkour.com."
        "\nLobby Top 3 only lists the fastest valid runs finished in this lobby."
    )
    faqHudText[15] = (
        "\n\n<fg00E092FF>Why are some players tiny?</fg>"
        "\nPlayers who haven't moved for 60 seconds shrink, so they're not in anyone's way."
        "\nThey grow back as soon as they move."
    )
    faqHudText[16] = (
        "\n\n<fg00E092FF>Does the server restart?</fg>"
        "\nYes, about every 4 hours, with warnings from 30 minutes before."
        "\nBest, Avg, Runs and Attempts start over."
    )
    faqHudText[17] = (
        "\n\n<fg00E092FF>Why does it take so long to load a Ballkour game?</fg>"
        "\nIts Workshop script is big, mostly from its translations into 13 languages,"
        "\nand Overwatch takes a while to load it before the match starts."
    )
    faqHudText[18] = (
        "\n\n<fg00E092FF>Is something wrong in my language?</fg>"
        "\nThe translations are drafts, so please report mistakes at ballkour.com/issues."
    )
    faqHudText[19] = _("Next Page: <fgFFFFFFFF>@0</fg>")
    faqHudText[20] = _("Close: <fgFFFFFFFF>@0</fg>")
    # Instead of Next Page on the last page, as the same key goes back around
    faqHudText[22] = _("Back to Page 1: <fgFFFFFFFF>@0</fg>")
    # Each language names itself, e.g. "FAQ auf Deutsch"
    faqHudText[21] = _("FAQ in English: <fgFFFFFFFF>ballkour.com/faq</fg>")
    # A blank line above the title, under BALLKOUR.COM or the run completion text: a blank
    # line in the header itself would grow its box. The line is an invisible soft hyphen
    # (U+00AD), like the lobby's padding lines.
    hudSubheader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "\u00ad",
        HudPosition.TOP,
        7,
        Color.WHITE,
        HudReeval.VISIBILITY
    )
    # A header, the biggest HUD text, so the page number reads as the title. Its own HUD
    # text, so it centers above the page.
    hudHeader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "FAQ {}/{}".format(localPlayer.faqPage, FAQ_PAGES),
        HudPosition.TOP,
        8,
        rgb(0, 224, 146),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Its own HUD text too, so it centers under the title. Blank in English, where the
    # answers already are: _() picks the language on each player's screen, which visibility
    # can't check, so this removes the English text ([0] of the stored translations).
    hudSubheader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        _(faqHudText[21]).replace(faqHudText[21][0], ""),
        HudPosition.TOP,
        9,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # A page is one HUD text, as separate HUD texts center against each other while the
    # lines of one left-align
    hudSubheader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "{}{}{}{}{}{}".format(
            faqAnswer(1),
            faqAnswer(2),
            faqAnswer(3),
            faqAnswer(4),
            faqAnswer(5),
            faqAnswer(6)
        ),
        HudPosition.TOP,
        10,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # The keys are a size bigger than the page, so they're its own HUD text, centered under
    # it. Only this one uses String Replace, which cuts off long strings.
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "\n{}\n{}".format(
            (
                _(faqHudText[19])
                if localPlayer.faqPage < FAQ_PAGES
                else _(faqHudText[22])
            ).replace("@0", inputBindingString(Button.JUMP)),
            _(faqHudText[20]).replace("@0", inputBindingString(Button.INTERACT))
        ),
        HudPosition.TOP,
        11,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
