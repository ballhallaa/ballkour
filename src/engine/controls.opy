#!mainFile "../main.opy"
#!rulePrefix "Controls"


rule "HUD Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.spectating[5] == false

    eventPlayer.isViewingCtrlsHud = true
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)
    eventPlayer.disallowButton(Button.MELEE)
    # Stays open through Lobby/Pause, since the lobby has controls too. Meanwhile Jump and
    # either fire turn the language back or forward (Prev./Next Language), so its controls
    # can be read in each one. Jump comes first, as Prev./Next CP leave it alone.
    while eventPlayer.isHoldingButton(Button.ULTIMATE):
        waitUntil(
            not eventPlayer.isHoldingButton(Button.ULTIMATE)
            or (
                eventPlayer.isHoldingButton(Button.JUMP)
                and (
                    eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                    or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
                )
            ),
            Math.INFINITY
        )
        # The whole combo, as a hero swap can let go of Ultimate for a moment, which ends
        # the wait too (seen entering spectator)
        if (
            eventPlayer.isHoldingButton(Button.ULTIMATE)
            and eventPlayer.isHoldingButton(Button.JUMP)
            and (
                eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
            )
        ):
            eventPlayer.__languageIndex__ = (
                eventPlayer.__languageIndex__
                + (
                    1
                    if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
                    else LANGUAGES - 1
                )
            ) % LANGUAGES
            waitUntil(
                not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                and not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
                Math.INFINITY
            )
    eventPlayer.isViewingCtrlsHud = false
    # The FAQ keeps them until it closes (FAQ: Open), and the lobby until it's left
    # (Lobby: Leave), Melee too as it's their close key
    if eventPlayer.faqPage > 0 or eventPlayer.isInLobby:
        return
    eventPlayer.allowButton(Button.MELEE)
    if not eventPlayer.spectating[0] or eventPlayer.spectating[2]:
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
    if not eventPlayer.spectating[0]:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)


# Whether Reset CP and Freemode work: on the course, before the last CP. Their lines are
# grayed out otherwise.
macro canUseCpControls(player):
    (not player.spectating[0] and player.runCurrentCp < lastCp)


# Whether the hint toggle works: before the last CP, on a course with hints. Its lines are
# grayed out otherwise.
macro canToggleHints(player):
    (player.viewCp < lastCp and len(hintRoutes) > 0)


rule "Load HUD":
    # At the top, under a blank line of its own. Each line is its own HUD text, centered on
    # its own, which the padding keeps lined up.
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        "\n",
        HudPosition.TOP,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Each line is one translated string with its padding inside, so a translation can
    # pad its own label. Grayed-out lines take their colors as arguments for the same reason.
    ctrlsHudText[0] = _("@0Prev. CP:                                  @1@2 + @3</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[0])
        .replace("@0", "" if localPlayer.viewCp > 0 else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if localPlayer.viewCp > 0 else "")
        .replace("@2", inputBindingString(Button.ULTIMATE))
        .replace("@3", inputBindingString(Button.PRIMARY_FIRE)),
        HudPosition.TOP,
        4.01,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[1] = _("@0Next CP:                                   @1@2 + @3</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[1])
        .replace("@0", "" if localPlayer.viewCp < lastCp else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if localPlayer.viewCp < lastCp else "")
        .replace("@2", inputBindingString(Button.ULTIMATE))
        .replace("@3", inputBindingString(Button.SECONDARY_FIRE)),
        HudPosition.TOP,
        4.02,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[2] = _("@0Reset CP:                               @1@2 (Hold)</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[2])
        .replace("@0", "" if canUseCpControls(localPlayer) else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if canUseCpControls(localPlayer) else "")
        .replace("@2", inputBindingString(Button.RELOAD)),
        HudPosition.TOP,
        4.03,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[3] = _("New Run:                     <fgFFFFFFFF>@0 + @1 (Hold)</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[3])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.RELOAD)),
        HudPosition.TOP,
        4.04,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[4] = _("@0Freemode:                                @1@2 + @3</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[4])
        .replace("@0", "" if canUseCpControls(localPlayer) else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if canUseCpControls(localPlayer) else "")
        .replace("@2", inputBindingString(Button.ULTIMATE))
        .replace("@3", inputBindingString(Button.INTERACT)),
        HudPosition.TOP,
        4.05,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Toggles them either way, so it's one line whether they're on or off
    ctrlsHudText[5] = _(
        "@0Hints:                                         @1@2 + @3</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[5])
        .replace("@0", "" if canToggleHints(localPlayer) else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if canToggleHints(localPlayer) else "")
        .replace("@2", inputBindingString(Button.ULTIMATE))
        .replace("@3", inputBindingString(Button.ABILITY_2)),
        HudPosition.TOP,
        4.06,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[7] = _("Spectate:                           <fgFFFFFFFF>@0 + @1</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and not localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[7])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.ABILITY_1)),
        HudPosition.TOP,
        4.08,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Lobby/Pause, or just Lobby while spectating. One text for both, as texts are capped at
    # 128 per server, HUD texts included (Lobby: Load Buttons).
    ctrlsHudText[8] = _("Lobby/Pause:             <fgFFFFFFFF>@0 + @1 (Hold)</fg>")
    ctrlsHudText[9] = _(
        "Lobby:                          <fgFFFFFFFF>@0 + @1 (Hold)</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        (_(ctrlsHudText[9]) if localPlayer.spectating[0] else _(ctrlsHudText[8]))
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.ABILITY_2)),
        HudPosition.TOP,
        4.09,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Under Lobby/Pause (or Lobby), for everyone, as it works anywhere but first person,
    # where the list doesn't show (HUD Input)
    ctrlsHudText[6] = _(
        "FAQ:                                     <fgFFFFFFFF>@0 + @1</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[6])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.MELEE)),
        HudPosition.TOP,
        4.11,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Under FAQ, for everyone, as it works wherever FAQ does (Controls: HUD)
    ctrlsHudText[17] = _("Customize HUD:      <fgFFFFFFFF>@0 + @1</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[17])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.CROUCH)),
        HudPosition.TOP,
        4.115,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Under Customize HUD, for everyone, as it works anywhere (HUD Input)
    ctrlsHudText[16] = _(
        "Prev. Language:   <fgFFFFFFFF>@0 + @1 + @2</fg>"
        "\nNext Language:   <fgFFFFFFFF>@0 + @1 + @3</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[16])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.JUMP))
        .replace("@2", inputBindingString(Button.PRIMARY_FIRE))
        .replace("@3", inputBindingString(Button.SECONDARY_FIRE)),
        HudPosition.TOP,
        4.12,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[10] = _(
        "<fg808080FF>- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -</fg>\n"
        "<fgEC9900FF>        Spectator Controls</fg>\n"
        "Disable:                             <fgFFFFFFFF>@0 + @1</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[10])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.ABILITY_1)),
        HudPosition.TOP,
        4.13,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[11] = _("@0Reattach:                          @1@2 + @3</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[11])
        .replace(
            "@0",
            (
                ""
                if localPlayer.spectating[1] != null and localPlayer.spectating[2]
                else "<fg808080FF>"
            )
        )
        .replace(
            "@1",
            (
                "<fgFFFFFFFF>"
                if localPlayer.spectating[1] != null and localPlayer.spectating[2]
                else ""
            )
        )
        .replace("@2", inputBindingString(Button.ABILITY_1))
        .replace("@3", inputBindingString(Button.RELOAD)),
        HudPosition.TOP,
        4.14,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[12] = _("@0First Person:                   @1@2 + @3</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[12])
        .replace("@0", "" if localPlayer.spectating[1] != null else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if localPlayer.spectating[1] != null else "")
        .replace("@2", inputBindingString(Button.ABILITY_1))
        .replace("@3", inputBindingString(Button.INTERACT)),
        HudPosition.TOP,
        4.15,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[13] = _(
        "@0Prev. Player:                  @1@2 + @3</fg>"
        "\n@0Next Player:                   @1@2 + @4</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[13])
        .replace("@0", "" if localPlayer.spectating[7] else "<fg808080FF>")
        .replace("@1", "<fgFFFFFFFF>" if localPlayer.spectating[7] else "")
        .replace("@2", inputBindingString(Button.ABILITY_1))
        .replace("@3", inputBindingString(Button.PRIMARY_FIRE))
        .replace("@4", inputBindingString(Button.SECONDARY_FIRE)),
        HudPosition.TOP,
        4.16,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[14] = _("@0X-Hair Player:         @1@2 + @3</fg>@4")
    ctrlsHudText[15] = _("\nFreecam:                             <fgFFFFFFFF>Move</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        # Freecam shares X-Hair Player's text
        _(ctrlsHudText[14])
        .replace(
            "@0",
            (
                ""
                if localPlayer.spectating[2] and localPlayer.spectating[7]
                else "<fg808080FF>"
            )
        )
        .replace(
            "@1",
            (
                "<fgFFFFFFFF>"
                if localPlayer.spectating[2] and localPlayer.spectating[7]
                else ""
            )
        )
        .replace("@2", inputBindingString(Button.ABILITY_1))
        .replace("@3", inputBindingString(Button.JUMP))
        .replace(
            "@4",
            (
                _(ctrlsHudText[15])
                if allControlsOr(not localPlayer.spectating[2])
                else ""
            )
        ),
        HudPosition.TOP,
        4.17,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


# The buttons held besides Ultimate, one bit each, so each input's combination of buttons is
# one number
macro heldButtons(player):
    (
        player.isHoldingButton(Button.PRIMARY_FIRE)
        + player.isHoldingButton(Button.SECONDARY_FIRE) * 2
        + player.isHoldingButton(Button.JUMP) * 4
        + player.isHoldingButton(Button.RELOAD) * 8
        + player.isHoldingButton(Button.INTERACT) * 16
        + player.isHoldingButton(Button.CROUCH) * 32
        + player.isHoldingButton(Button.ABILITY_1) * 64
        + player.isHoldingButton(Button.ABILITY_2) * 128
    )


# Ultimate + each one, alone. Melee gets its own bit (256) above them in ultInputKey, as
# only the FAQ needs it, while the others don't mind it being held.
macro ULT_PREV_CP = 1
macro ULT_NEXT_CP = 2
macro ULT_NEW_RUN = 8
macro ULT_FREEMODE = 16
macro ULT_HUD = 32
macro ULT_SPECTATE = 64
macro ULT_LOBBY = 128
macro ULT_FAQ = 256


macro ultInputKeyNow():
    (heldButtons(eventPlayer) + eventPlayer.isHoldingButton(Button.MELEE) * 256)


# Whether ultInputKey is Ultimate + this button alone, with or without Melee
macro ultInputIs(ultCombo):
    (eventPlayer.ultInputKey % 256 == ultCombo)


# Prev./Next CP: not already on the first or last CP, theirs on the course or the one being
# spectated
macro canGoToPrevCp(player):
    (
        (player.runCurrentCp > 0 and not player.spectating[0])
        or (player.spectating[4] > 0 and player.spectating[0])
    )


macro canGoToNextCp(player):
    (
        (player.runCurrentCp < lastCp and not player.spectating[0])
        or (player.spectating[4] < lastCp and player.spectating[0])
    )


# The inputs that need the player out of the lobby: Freemode, Prev. and Next CP
macro ultCourseInputReady():
    (
        not eventPlayer.isInLobby
        and (
            (
                ultInputIs(ULT_FREEMODE)
                and not eventPlayer.spectating[0]
                and eventPlayer.runCurrentCp < lastCp
            )
            or (
                eventPlayer.hasSpawned()
                and not eventPlayer.isLoading
                and (
                    (ultInputIs(ULT_PREV_CP) and canGoToPrevCp(eventPlayer))
                    or (ultInputIs(ULT_NEXT_CP) and canGoToNextCp(eventPlayer))
                )
            )
        )
    )


# Whether the input for the buttons in ultInputKey can run now, and hasn't yet for this
# press. Each input's checks are the ones its own rule had, with the shared ones pulled out:
# New Run works anywhere but the FAQ, Lobby/Pause anywhere but first person, and the rest
# need the FAQ closed too, and HUD waits for loading to finish.
macro ultInputReady():
    (
        not eventPlayer.ultInputDone
        and (
            (ultInputIs(ULT_NEW_RUN) and eventPlayer.faqPage == 0)
            or (
                not eventPlayer.spectating[5]
                and (
                    ultInputIs(ULT_LOBBY)
                    or (
                        eventPlayer.faqPage == 0
                        and (
                            eventPlayer.ultInputKey == ULT_FAQ
                            or ultInputIs(ULT_SPECTATE)
                            or ultInputIs(ULT_HUD)
                            and not eventPlayer.isLoading
                            or ultCourseInputReady()
                        )
                    )
                )
            )
        )
    )


rule "Ultimate Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    # Every Ultimate + button input, in one rule instead of one each, since every eachPlayer
    # rule and condition adds to the per-player load that closes the server. An input runs
    # once per press, like a rule of its own would: when its buttons are held, or later
    # while they still are, once it can (say, after loading).
    eventPlayer.ultInputKey = -1
    while eventPlayer.isHoldingButton(Button.ULTIMATE):
        waitUntil(
            not eventPlayer.isHoldingButton(Button.ULTIMATE)
            or ultInputKeyNow() != eventPlayer.ultInputKey
            or ultInputReady(),
            Math.INFINITY
        )
        eventPlayer.ultInputLastKey = eventPlayer.ultInputKey
        eventPlayer.ultInputKey = ultInputKeyNow()
        if eventPlayer.ultInputKey != eventPlayer.ultInputLastKey:
            # A new press, so its input can run, at once if it's ready (the wait passes)
            eventPlayer.ultInputDone = false
        elif eventPlayer.isHoldingButton(Button.ULTIMATE):
            # With the same buttons still held, the wait only passed because the input can
            # run. The code after a wait runs in the tick it passes (tested), so that still
            # holds.
            eventPlayer.ultInputDone = true
            if eventPlayer.ultInputKey == ULT_FAQ:
                # Opens the FAQ, where either fire turns its pages, once Melee is let go, so
                # the same press doesn't close it again at once
                waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), Math.INFINITY)
                eventPlayer.faqPage = 1
            elif ultInputIs(ULT_PREV_CP):
                prevCpInput()
            elif ultInputIs(ULT_NEXT_CP):
                nextCpInput()
            elif ultInputIs(ULT_NEW_RUN):
                newRunInput()
            elif ultInputIs(ULT_FREEMODE):
                freemodeInput()
            elif ultInputIs(ULT_HUD):
                hudInput()
            elif ultInputIs(ULT_SPECTATE):
                toggleSpectator()
            elif ultInputIs(ULT_LOBBY):
                lobbyInput()


def prevCpInput():
    @Name "Prev. Checkpoint"

    eventPlayer.isLoading = true
    # Watching someone, this switches to freecam, whose swap to Jetpack Cat finishes first
    if eventPlayer.spectating[0] and not eventPlayer.spectating[2]:
        swapToJetpackCat()
    eventPlayer.setPrimaryFireEnabled(false)
    pauseRun()
    if not eventPlayer.spectating[0]:
        eventPlayer.runCurrentCp--
        syncSpectatorCps()
        showCpNameplate()
        resetCpMistakes()
    else:
        if not eventPlayer.spectating[2]:
            enableFreecam()
        eventPlayer.spectating[3] = true
        eventPlayer.spectating[4]--
    loadCpData()
    cpResetPlayer()
    setCpAbilities()
    faceNextCp()
    waitUntil(
        not eventPlayer.isHoldingButton(Button.ULTIMATE)
        or not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE),
        0.25
    )
    if (
        eventPlayer.isHoldingButton(Button.ULTIMATE)
        and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
        and (
            (eventPlayer.runCurrentCp > 0 and not eventPlayer.spectating[0])
            or (eventPlayer.spectating[4] > 0 and eventPlayer.spectating[0])
        )
    ):
        while (
            eventPlayer.isHoldingButton(Button.ULTIMATE)
            and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
            and (
                (eventPlayer.runCurrentCp > 0 and not eventPlayer.spectating[0])
                or (eventPlayer.spectating[4] > 0 and eventPlayer.spectating[0])
            )
        ):
            if not eventPlayer.spectating[0]:
                eventPlayer.runCurrentCp--
                syncSpectatorCps()
                eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
                showCpNameplate()
            else:
                eventPlayer.spectating[4]--
                eventPlayer.teleport(cps[eventPlayer.spectating[4]][0])
            wait(0.02)
        loadCpData()
        cpResetPlayer()
        setCpAbilities()
        faceNextCp()
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.isLoading = false


def nextCpInput():
    @Name "Next Checkpoint"

    eventPlayer.isLoading = true
    # Like Prev. Checkpoint
    if eventPlayer.spectating[0] and not eventPlayer.spectating[2]:
        swapToJetpackCat()
    eventPlayer.setSecondaryFireEnabled(false)
    pauseRun()
    if not eventPlayer.spectating[0]:
        # Skipping past the furthest CP cleared only disqualifies the run once the player
        # leaves the CP (Run: isOnSkippedCp), or at once onto the last CP, which finishes it
        if (
            eventPlayer.runCurrentCp + 1 == lastCp
            and eventPlayer.runFurthestCp < lastCp
        ):
            eventPlayer.isRunLegit = false
        eventPlayer.runCurrentCp++
        syncSpectatorCps()
        showCpNameplate()
        resetCpMistakes()
    else:
        if not eventPlayer.spectating[2]:
            enableFreecam()
        eventPlayer.spectating[3] = true
        eventPlayer.spectating[4]++
    loadCpData()
    cpResetPlayer()
    setCpAbilities()
    faceNextCp()
    waitUntil(
        not eventPlayer.isHoldingButton(Button.ULTIMATE)
        or not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
        0.25
    )
    if (
        eventPlayer.isHoldingButton(Button.ULTIMATE)
        and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        and (
            (eventPlayer.runCurrentCp < lastCp and not eventPlayer.spectating[0])
            or (eventPlayer.spectating[4] < lastCp and eventPlayer.spectating[0])
        )
    ):
        while (
            eventPlayer.isHoldingButton(Button.ULTIMATE)
            and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
            and (
                (eventPlayer.runCurrentCp < lastCp and not eventPlayer.spectating[0])
                or (eventPlayer.spectating[4] < lastCp and eventPlayer.spectating[0])
            )
        ):
            if not eventPlayer.spectating[0]:
                if (
                    eventPlayer.runCurrentCp + 1 == lastCp
                    and eventPlayer.runFurthestCp < lastCp
                ):
                    eventPlayer.isRunLegit = false
                eventPlayer.runCurrentCp++
                eventPlayer.teleport(cps[eventPlayer.runCurrentCp][0])
                showCpNameplate()
            else:
                eventPlayer.spectating[4]++
                eventPlayer.teleport(cps[eventPlayer.spectating[4]][0])
            syncSpectatorCps()
            wait(0.02)
        loadCpData()
        cpResetPlayer()
        setCpAbilities()
        faceNextCp()
    if eventPlayer.spectating[0]:
        eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.isLoading = false


rule "Reset Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.spectating[5] == false
    @Condition eventPlayer.runCurrentCp < lastCp
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.faqPage == 0

    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.15)
    if (
        not eventPlayer.isHoldingButton(Button.RELOAD)
        and eventPlayer.runCurrentCp < lastCp
    ):
        return
    eventPlayer.isLoading = true
    if not eventPlayer.isRunPaused:
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            addMistake()
    cpResetPlayer()
    eventPlayer.isLoading = false


def newRunInput():
    @Name "New Run"

    waitUntil(
        not (
            eventPlayer.isHoldingButton(Button.ULTIMATE)
            and eventPlayer.isHoldingButton(Button.RELOAD)
        ),
        0.35
    )
    if (
        not (
            eventPlayer.isHoldingButton(Button.ULTIMATE)
            and eventPlayer.isHoldingButton(Button.RELOAD)
        )
        and eventPlayer.runCurrentCp < lastCp
    ):
        return
    eventPlayer.isLoading = true
    stopChasingVariable(eventPlayer.runTime)
    eventPlayer.isViewingRunCompletionText = false
    newRun()
    eventPlayer.isLoading = false


def freemodeInput():
    @Name "Freemode"

    eventPlayer.disallowButton(Button.MELEE)
    if not eventPlayer.isInFreemode:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            addMistake()
        eventPlayer.setSecondaryFireEnabled(true)
        eventPlayer.setAbility2Enabled(true)
        eventPlayer.allowButton(Button.CROUCH)
        eventPlayer.nameplate = _("{} | FREEMODE").format(eventPlayer)
        eventPlayer.isInFreemode = true
    else:
        eventPlayer.isLoading = true
        # Freemode can't clear CPs, and turning it off away from the CP puts the player back
        # on it, so it doesn't disqualify the run
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            cpResetPlayer()
        eventPlayer.isInFreemode = false
        setCpAbilities()
        showCpNameplate()
        eventPlayer.isLoading = false
    eventPlayer.allowButton(Button.MELEE)


rule "Load Freemode HUD":
    # Under Disqualified (0.9), with a blank line above it unless Disqualified, which brings
    # its own, is showing. The HUD page shows it either way, so it can be turned off ahead of
    # time.
    freemodeHudText = _("Freemode On")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: (
                localPlayer.isInFreemode
                and not localPlayer.spectating[0]
                or isHudPage(localPlayer)
            )
            and localPlayer.faqPage == 0
            and isHudLineOn(localPlayer, HUD_FREEMODE)
        ),
        "{}{}".format(
            "" if isDisqualifiedShown(localPlayer) else "\n", _(freemodeHudText)
        ),
        HudPosition.LEFT,
        1,
        rgb(203, 135, 255),
        HudReeval.VISIBILITY_AND_STRING
    )


# Spectator controls have their own file. It's included here, not at the end,
# because the Workshop runs rules in file order.
#!include "spectator.opy"


def lobbyInput():
    @Name "Lobby"

    # A tap turns hints on or off, sharing Ultimate + Ability 2 with Lobby/Pause
    waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_2), 0.35)
    if not eventPlayer.isHoldingButton(Button.ABILITY_2):
        if (
            not eventPlayer.isInLobby
            and eventPlayer.viewCp < lastCp
            and eventPlayer.faqPage == 0
        ):
            eventPlayer.isHintOn = not eventPlayer.isHintOn
            # Toggled by hand, so moving to another CP doesn't turn them off, and turning them
            # off stops mistakes from turning them on again
            eventPlayer.isHintAutoOn = false
            if not eventPlayer.isHintOn:
                eventPlayer.isHintAutoOff = true
        return
    # Holding goes to Lobby/Pause, unless another button joined in or the FAQ is open
    if (
        eventPlayer.isInLobby
        or eventPlayer.faqPage > 0
        or not (
            eventPlayer.isHoldingButton(Button.ULTIMATE)
            and heldButtons(eventPlayer) == ULT_LOBBY
            and not eventPlayer.spectating[5]
        )
    ):
        return
    goToLobby()


def goToLobby():
    @Name "Go To Lobby"

    # Lobby/Pause, and HUD from the course, which sets lobbyPage to open the HUD page
    eventPlayer.isLoading = true
    if eventPlayer.spectating[0]:
        disableSpectator()
    eventPlayer.setAbility2Enabled(false)
    pauseRun()
    eventPlayer.isViewingRunCompletionText = false
    loadLobby()
    eventPlayer.isLoading = false


def hudInput():
    @Name "HUD"

    # Opens the HUD page, pausing the run to go to the lobby like Lobby/Pause. In the lobby
    # it turns to it from the other pages, and on it goes back the way its buttons do: to the
    # course if the run can be resumed, otherwise to the main page.
    if eventPlayer.isInLobby:
        if eventPlayer.lobbyPage != HUD_PAGE:
            eventPlayer.lobbyPage = HUD_PAGE
        elif canResumeRun(eventPlayer):
            resumeRun()
        else:
            eventPlayer.lobbyPage = 1
        return
    eventPlayer.lobbyPage = -HUD_PAGE
    goToLobby()


rule "Load Hints HUD":
    # Under FAQ at the top left, grayed out when hints can't be turned on or off. While hints
    # are on at a CP without one, the same spot says so instead
    hintsHudText[0] = _("@0Hints: @1@2 + @3</fg>")
    hintsHudText[1] = _("No Hint For This CP")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isCourseHudShown(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        # The 3 lines at the top left keep their height, so the lines under them stay clear of
        # the player's name tag on the 4th line: a blank line for itself while it's turned
        # off, and one at the end for each of Controls and FAQ turned off, which move up
        "{}{}{}".format(
            (
                " "
                if localPlayer.hudHidden[HUD_HINTS]
                else (
                    _(hintsHudText[0])
                    .replace(
                        "@0", "" if canToggleHints(localPlayer) else "<fg808080FF>"
                    )
                    .replace(
                        "@1", "<fgFFFFFFFF>" if canToggleHints(localPlayer) else ""
                    )
                    .replace("@2", inputBindingString(Button.ULTIMATE))
                    .replace("@3", inputBindingString(Button.ABILITY_2))
                    if allControlsOr(
                        not localPlayer.isHintOn
                        or not canToggleHints(localPlayer)
                        or len(hintRoutes[localPlayer.viewCp]) > 1
                    )
                    else _(hintsHudText[1])
                )
            ),
            "\n" if localPlayer.hudHidden[HUD_CONTROLS] else "",
            "\n" if localPlayer.hudHidden[HUD_FAQ] else ""
        ),
        HudPosition.LEFT,
        0.2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
