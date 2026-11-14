#!mainFile "../main.opy"
#!rulePrefix "FAQ"


# Each page is FAQ_PAGE_LENGTH answers, which all fit above the hero bar
macro FAQ_PAGE_LENGTH = 5


# The answer in a slot of the page the player is on, from faqHudText[1]
macro faqAnswer(faqSlot):
    faqHudText[(localPlayer.faqPage - 1) * FAQ_PAGE_LENGTH + faqSlot]


# Either fire, which turn the pages back and forward
macro isTurningFaqPage(player):
    (
        player.isHoldingButton(Button.PRIMARY_FIRE)
        or player.isHoldingButton(Button.SECONDARY_FIRE)
    )


rule "Open":
    @Event eachPlayer
    @Condition eventPlayer.faqPage > 0

    # Controls: Ultimate Input opens and closes it. Every eachPlayer rule adds to the
    # server's periodic load, and six of them for the FAQ were enough to close the server, so
    # this one rule does all of it: closing, turning pages, the sky camera, and locking the
    # player in place. Melee closes the FAQ and Primary/Secondary Fire turn its pages, and
    # Melee is off while it's open so it doesn't punch. Jump stays off too, so the player
    # stays put, and once it closes until Jump is let go.
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.MELEE)
    # Every HUD text but the FAQ's hides while it's open, and so does the hero's own HUD
    eventPlayer.disableHeroHud()
    # Looks out from high above the player, wherever they look, so looking up shows the sky as
    # a plain background. Spectator mode leaves this camera alone until the FAQ closes.
    eventPlayer.startCamera(
        eventPlayer.getEyePosition() + vect(0, 100, 0),
        eventPlayer.getEyePosition()
        + vect(0, 100, 0)
        + eventPlayer.getFacingDirection(),
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
                or eventPlayer.isHoldingButton(Button.MELEE)
                or isTurningFaqPage(eventPlayer)
                or eventPlayer.spectating[0],
                Math.INFINITY
            )
            # A page turn locks them again on the next pass
            if not eventPlayer.spectating[0] and (
                eventPlayer.isHoldingButton(Button.MELEE)
                or not isTurningFaqPage(eventPlayer)
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
            # Freecam flies, so it holds still, and Jetpack Cat's fires are off so they only
            # turn pages. Reattaching forces the position itself.
            eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
            eventPlayer.disallowButton(Button.PRIMARY_FIRE)
            eventPlayer.disallowButton(Button.SECONDARY_FIRE)
            waitUntil(
                eventPlayer.faqPage == 0
                or eventPlayer.isHoldingButton(Button.MELEE)
                or isTurningFaqPage(eventPlayer)
                or not eventPlayer.spectating[0]
                or not eventPlayer.spectating[2],
                Math.INFINITY
            )
            # A page turn keeps holding it, with its fires off
            if eventPlayer.spectating[2] and (
                eventPlayer.isHoldingButton(Button.MELEE)
                or not isTurningFaqPage(eventPlayer)
            ):
                eventPlayer.stopForcingPosition()
                # Like playing, letting go of Ultimate gives them back in HUD Input
                if not eventPlayer.isHoldingButton(Button.ULTIMATE):
                    eventPlayer.allowButton(Button.PRIMARY_FIRE)
                    eventPlayer.allowButton(Button.SECONDARY_FIRE)
        else:
            # Watching someone already holds them in place
            waitUntil(
                eventPlayer.faqPage == 0
                or eventPlayer.isHoldingButton(Button.MELEE)
                or isTurningFaqPage(eventPlayer)
                or not eventPlayer.spectating[0]
                or eventPlayer.spectating[2],
                Math.INFINITY
            )
        if eventPlayer.isHoldingButton(Button.MELEE):
            # Closing once Melee is let go, so with Ultimate held it doesn't open again
            # (Controls: Ultimate Input)
            waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), Math.INFINITY)
            eventPlayer.faqPage = 0
        elif isTurningFaqPage(eventPlayer):
            # Secondary Fire goes forward and Primary Fire back, both going around between
            # the last page and page 1
            if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
                eventPlayer.faqPage = eventPlayer.faqPage % FAQ_PAGES + 1
            else:
                eventPlayer.faqPage = (
                    eventPlayer.faqPage + FAQ_PAGES - 2
                ) % FAQ_PAGES + 1
            waitUntil(not isTurningFaqPage(eventPlayer), Math.INFINITY)
    if eventPlayer.spectating[0] and not eventPlayer.spectating[2]:
        # Without a target, Hold Queued Camera takes over
        if eventPlayer.spectating[1] != null:
            startSpectatorCamera()
        # A Jump held while it was open shouldn't go on to enable freecam
        eventPlayer.spectating[9] = true
        waitUntil(not eventPlayer.isHoldingButton(Button.JUMP), Math.INFINITY)
        eventPlayer.spectating[9] = false
    else:
        eventPlayer.stopCamera()
        waitUntil(not eventPlayer.isHoldingButton(Button.JUMP), Math.INFINITY)
    eventPlayer.allowButton(Button.JUMP)
    # While Ultimate is held, letting go of it gives Melee back (Controls: HUD Input), and
    # the lobby keeps it until it's left (Lobby: Leave)
    if not eventPlayer.isHoldingButton(Button.ULTIMATE) and not eventPlayer.isInLobby:
        eventPlayer.allowButton(Button.MELEE)
    eventPlayer.enableHeroHud()
    if RULE_CONDITION:
        loop()


rule "Load HUD":
    # Under Controls at the top left, and left out of the lobby like it, with the Hints line
    # under it. Turned off, Hints moves up and ends in a blank line in its place, like for
    # Controls (Run: Load HUD).
    faqHudText[0] = _("FAQ: <fgFFFFFFFF>@0 + @1</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: isCourseHudShown(localPlayer)
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_FAQ)
        ),
        _(faqHudText[0])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.MELEE)),
        HudPosition.LEFT,
        0.1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Each answer is its own string in white, with its question in light blue and the game's own
    # labels (controls, HUD and lobby names) in orange, in questions too, the ones
    # ballkour.com/faq marks. A mode or HUD text keeps its own HUD's color instead (Freemode
    # violet, Assist Mode pink, Spectator blue, (DISCONNECTED) white, disqualified red). Color tags can't nest, so a label in a
    # question closes the light blue and opens it again after. The answers are English only, with the translated ones at ballkour.com/faq: in all 14
    # languages they made pasting the script take several seconds longer.
    # Page 1
    faqHudText[1] = (
        "\n<fgE69700FF>Website:</fg> ballkour.com"
        "\n<fgE69700FF>Discord:</fg> ballkour.com/discord"
        "\n<fgE69700FF>Report Issues:</fg> ballkour.com/issues"
        "\n<fgE69700FF>Version:</fg> {}"
    ).format(VERSION)
    faqHudText[2] = (
        "\n\n<fg80D0FFFF>What counts as a valid run?</fg>"
        "\nYour run is only <fgFF4646FF>disqualified</fg> if you skip to a checkpoint you haven't reached yet this run"
        "\nand leave it, or skip to the last one, which finishes your run. Skipping ahead to look,"
        "\ngoing back or restarting checkpoints, <fgCB87FFFF>Freemode</fg>, and <fg00BEFFFF>spectating</fg> are fine."
        "\n<fgFF4646FF>Disqualified</fg> runs don't count toward the top-10 leaderboard, <fgE69700FF>Lobby Top 3</fg>, or <fgE69700FF>Lobby Stats</fg>."
        "\nRuns that use <fgFF80C0FF>Assist Mode</fg> go on their own <fgFF80C0FF>assisted</fg> leaderboard at ballkour.com instead."
    )
    faqHudText[3] = (
        "\n\n<fg80D0FFFF>How do I get on the leaderboard?</fg>"
        "\nFinish a valid run and submit it at ballkour.com. Only top-10 runs need a video for proof."
        "\n<fgE69700FF>All-Time Top 3</fg> shows the leaderboard's 3 fastest runs, or the <fgFF80C0FF>assisted</fg> one's in <fgFF80C0FF>Assist Mode</fg>."
        "\n<fgE69700FF>Lobby Top 3</fg> lists the fastest valid runs finished in this lobby, <fgFF80C0FF>assisted</fg> ones marked with <fgFF80C0FF>•</fg>."
    )
    faqHudText[4] = (
        "\n\n<fg80D0FFFF>When does my run's timer start?</fg>"
        "\nWhen you leave the first checkpoint, not when you spawn."
    )
    faqHudText[5] = (
        "\n\n<fg80D0FFFF>What counts as a mistake?</fg>"
        "\nLanding anywhere but the next checkpoint, bhopping twice, missing a checkpoint's orb,"
        "\nfalling off the map, or leaving mid-attempt with <fgE69700FF>Prev.</fg>/<fgE69700FF>Next CP</fg>, <fgE69700FF>Reset CP</fg>, <fgE69700FF>Freemode</fg>,"
        "\n<fgE69700FF>Assist Mode</fg>, <fgE69700FF>Spectate</fg>, or <fgE69700FF>Lobby/Pause</fg>."
    )
    # Page 2
    faqHudText[6] = (
        "\n<fg80D0FFFF>Can I pause my run?</fg>"
        "\n<fgE69700FF>Lobby/Pause</fg> and <fgE69700FF>Spectate</fg> pause your timer. <fgE69700FF>Resume Run</fg> in the lobby carries on from"
        "\nyour checkpoint. Pausing outside your checkpoint counts as a mistake."
    )
    faqHudText[7] = (
        "\n\n<fg80D0FFFF>What do </fg><fgE69700FF>Runs</fg><fg80D0FFFF> and </fg><fgE69700FF>Attempts</fg><fg80D0FFFF> count?</fg>"
        "\n<fgE69700FF>Runs</fg> counts the runs you've finished or restarted. <fgE69700FF>Attempts</fg> counts your mistakes"
        "\n(<fgE69700FF>Redos</fg> in <fgFF80C0FF>Assist Mode</fg>) and clears on this checkpoint, over all your runs."
    )
    faqHudText[8] = (
        "\n\n<fg80D0FFFF>What do </fg><fgE69700FF>Attempt</fg><fg80D0FFFF> and </fg><fgE69700FF>Split</fg><fg80D0FFFF> mean?</fg>"
        "\n<fgE69700FF>Attempt</fg> is timed from leaving the checkpoint. <fgE69700FF>Split</fg> is timed from reaching it, so the time"
        "\nyou were inside the checkpoint counts, as well as mistakes."
        "\nEach turns red once it's slower than your best."
        "\nAfter a clear, they show your times for 2 seconds: <fgFFFF00FF>yellow</fg> on your first clear, then"
        "\n<fg00E092FF>green</fg> if faster or <fgFF4646FF>red</fg> if slower than your average. A new best is compared with your old best."
    )
    faqHudText[9] = (
        "\n\n<fg80D0FFFF>What are </fg><fgE69700FF>Best</fg><fg80D0FFFF> and </fg><fgE69700FF>Avg</fg><fg80D0FFFF>?</fg>"
        "\nThey are your own times on that checkpoint, over all your runs."
        "\nThey reset when you leave or when the server restarts."
    )
    faqHudText[10] = (
        "\n\n<fg80D0FFFF>What is </fg><fgE69700FF>Pace</fg><fg80D0FFFF>?</fg>"
        "\nYour estimated finish time, from this run's average split so far. Once your current"
        "\nsplit is slower than that average, it turns <fgFF4646FF>red</fg> and counts up with your time."
    )
    # Page 3
    faqHudText[11] = (
        "\n<fg80D0FFFF>Why are some controls </fg><fg808080FF>grayed out</fg><fg80D0FFFF>?</fg>"
        "\nThey can't be used right now: <fgE69700FF>Prev. CP</fg> on the first checkpoint, <fgE69700FF>Next CP</fg> on the last,"
        "\nand the <fg00BEFFFF>spectator</fg> controls while there's nobody to <fg00BEFFFF>spectate</fg>."
        "\n<fgE69700FF>Reattach</fg> needs <fgE69700FF>Freecam</fg> while watching a player. <fgE69700FF>X-Hair Player</fg> needs <fgE69700FF>Freecam</fg>."
    )
    faqHudText[12] = (
        "\n\n<fg80D0FFFF>What's on the scorecard?</fg>"
        "\nEach player's checkpoint, time, and mistakes (ground time for <fgFF80C0FF>assisted</fg> runs), sorted by furthest and then fastest."
        "\nRunners come first, then <fgFF4646FF>disqualified</fg> runners in <fgFF4646FF>red</fg>, players in <fgFF80C0FF>Assist Mode</fg> in <fgFF80C0FF>pink</fg>,"
        "\nplayers in <fgCB87FFFF>Freemode</fg> in <fgCB87FFFF>purple</fg>, players in <fg00BEFFFF>Spectate</fg> in <fg00BEFFFF>blue</fg>, and players in the lobby in <fg808080FF>gray</fg>."
        "\n<fgFF4646FF>Disqualified</fg> runs are marked <fgFF4646FF>×</fg>, runs that were in <fgFF80C0FF>Assist Mode</fg> <fgFF80C0FF>•</fg>, and players"
        "\non a checkpoint they skipped to <fgFF4646FF>»</fg>, which turns into <fgFF4646FF>×</fg> once they leave it."
    )
    faqHudText[13] = (
        "\n\n<fg80D0FFFF>What is a </fg><fg00BEFFFF>shield bounce</fg><fg80D0FFFF>?</fg>"
        "\nAdaptive Shield (Button: @0) bounces you up and forward. The faster you're going,"
        "\nthe less it lifts you. You get one each time you leave the checkpoint, on checkpoints"
        "\nthat allow it, and as many as you like in <fgCB87FFFF>Freemode</fg>."
    )
    faqHudText[14] = (
        "\n\n<fg80D0FFFF>What do the hint colors mean?</fg>"
        "\n<fgCB87FFFF>Movement</fg>   <fgFFFFFFFF>Jump</fg>   <fgFFD200FF>Grapple</fg>   <fgFF4646FF>Piledrive</fg>   <fg00BEFFFF>Shield Bounce</fg>"
        "\nHints turn on by themselves after 10 mistakes on one checkpoint,"
        "\nand off again when you move on to another, until you turn them off yourself."
    )
    faqHudText[15] = (
        "\n\n<fg80D0FFFF>What are </fg><fgCB87FFFF>Freemode</fg><fg80D0FFFF> and </fg><fgFF80C0FF>Assist Mode</fg><fg80D0FFFF> for?</fg>"
        "\n<fgCB87FFFF>Freemode</fg> is practice, with no timer and all your abilities. You can't clear checkpoints in it,"
        "\nso it doesn't <fgFF4646FF>disqualify</fg> your run. <fgFF80C0FF>Assist Mode</fg> gives you every ability, as often as you like,"
        "\nand landing isn't a mistake, while checkpoints still clear. Its runs have their own leaderboard."
        "\nInstead of mistakes, it times how long you're on the ground where landing would be one."
    )
    # Page 4
    faqHudText[16] = (
        "\n<fg80D0FFFF>What does </fg><fgFFFFFFFF>(DISCONNECTED)</fg><fg80D0FFFF> mean in </fg><fg00BEFFFF>Spectator</fg><fg80D0FFFF> mode?</fg>"
        "\nYou aren't following anyone's run, so the HUD only shows the checkpoint you'll return to"
        "\nwhen you leave <fg00BEFFFF>Spectate</fg>. You disconnect when you enter <fg00BEFFFF>Spectate</fg> or use <fgE69700FF>Prev.</fg>/<fgE69700FF>Next CP</fg>,"
        "\nor when the player you're watching enters <fg00BEFFFF>Spectate</fg>, goes to the lobby, or leaves the game."
        "\nUse <fgE69700FF>Reattach</fg>, <fgE69700FF>Prev.</fg>/<fgE69700FF>Next Player</fg>, or <fgE69700FF>X-Hair Player</fg> to follow someone again."
    )
    faqHudText[17] = (
        "\n\n<fg80D0FFFF>Why are some players tiny?</fg>"
        "\nPlayers who haven't moved for 60 seconds shrink, so they're not in anyone's way."
        "\nThey grow back as soon as they move."
    )
    faqHudText[18] = (
        "\n\n<fg80D0FFFF>Does the server restart?</fg>"
        "\nYes, about every 4 hours, with warnings from 30 minutes before."
        "\n<fgE69700FF>Runs</fg>, <fgE69700FF>Attempts</fg>, <fgE69700FF>Mistakes</fg>, <fgE69700FF>Best</fg>, <fgE69700FF>Avg</fg>, the scorecard, and <fgE69700FF>Lobby Top 3</fg> reset, so nothing"
        "\ncarries over into a new match (a Workshop limitation)."
    )
    faqHudText[19] = (
        "\n\n<fg80D0FFFF>Why does it take so long to load a Ballkour game?</fg>"
        "\nIts Workshop script is big, mostly from its translations into 13 languages,"
        "\nand Overwatch takes a while to load it before the match starts."
    )
    faqHudText[20] = (
        "\n\n<fg80D0FFFF>Is something wrong in my language?</fg>"
        "\nThe translations are drafts, so please report mistakes at ballkour.com/issues."
    )
    faqHudText[25] = _("Next Page: <fgFFFFFFFF>@0</fg>")
    faqHudText[26] = _("Close: <fgFFFFFFFF>@0</fg>")
    # Instead of Next Page on the last page, as the same key goes back around
    faqHudText[22] = _("First Page: <fgFFFFFFFF>@0</fg>")
    faqHudText[23] = _("Prev. Page: <fgFFFFFFFF>@0</fg>")
    # Instead of Prev. Page on page 1, as it goes back around too
    faqHudText[24] = _("Last Page: <fgFFFFFFFF>@0</fg>")
    # Each language names itself, e.g. "FAQ auf Deutsch"
    faqHudText[21] = _("FAQ in English: <fgFFFFFFFF>ballkour.com/faq</fg>")
    # A blank line above the title, under BALLKOUR.COM or the run completion text: a blank
    # line in the header itself would grow its box. The line is an invisible soft hyphen
    # (U+00AD), like the lobby's padding lines.
    hudSubheader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "\u00ad",
        HudPosition.TOP,
        3,
        Color.WHITE,
        HudReeval.VISIBILITY
    )
    # A header, the biggest HUD text, so the page number reads as the title. Its own HUD
    # text, so it centers above the page.
    hudHeader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "FAQ {}/{}".format(localPlayer.faqPage, FAQ_PAGES),
        HudPosition.TOP,
        3.1,
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
        3.2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # A page is one HUD text, as separate HUD texts center against each other while the
    # lines of one left-align. The shield bounce answer (faqHudText[13], page 3's third)
    # names the player's Adaptive Shield key, which only a HUD can read, in place of its
    # @0. String Replace cuts off long strings, so it only runs on that answer.
    hudSubheader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "{}{}{}{}{}".format(
            faqAnswer(1),
            faqAnswer(2),
            (
                faqAnswer(3).replace("@0", inputBindingString(Button.ABILITY_2))
                if localPlayer.faqPage == 3
                else faqAnswer(3)
            ),
            faqAnswer(4),
            faqAnswer(5)
        ),
        HudPosition.TOP,
        3.3,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING
    )
    # The keys are a size bigger than the page, so they're its own HUD text, centered under
    # it. Only this one uses String Replace, which cuts off long strings.
    hudSubtext(
        getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage > 0),
        "\n{}\n{}\n{}".format(
            (
                _(faqHudText[23]) if localPlayer.faqPage > 1 else _(faqHudText[24])
            ).replace("@0", inputBindingString(Button.PRIMARY_FIRE)),
            (
                _(faqHudText[25])
                if localPlayer.faqPage < FAQ_PAGES
                else _(faqHudText[22])
            ).replace("@0", inputBindingString(Button.SECONDARY_FIRE)),
            _(faqHudText[26]).replace("@0", inputBindingString(Button.MELEE))
        ),
        HudPosition.TOP,
        3.4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
