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
    ctrlsHudText[5] = _("@0Disable Hints:                          @1@2 + @3</fg>")
    ctrlsHudText[6] = _("@0Enable Hints:                           @1@2 + @3</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer) and localPlayer.faqPage == 0
            )
        ),
        (
            _(ctrlsHudText[5])
            .replace("@0", "" if canToggleHints(localPlayer) else "<fg808080FF>")
            .replace("@1", "<fgFFFFFFFF>" if canToggleHints(localPlayer) else "")
            .replace("@2", inputBindingString(Button.ULTIMATE))
            .replace("@3", inputBindingString(Button.ABILITY_2))
            if allControlsOr(localPlayer.isHintOn)
            else _(ctrlsHudText[6])
            .replace("@0", "" if canToggleHints(localPlayer) else "<fg808080FF>")
            .replace("@1", "<fgFFFFFFFF>" if canToggleHints(localPlayer) else "")
            .replace("@2", inputBindingString(Button.ULTIMATE))
            .replace("@3", inputBindingString(Button.ABILITY_2))
        ),
        HudPosition.TOP,
        4.06,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # One line above shows Disable or Enable, so all the controls need Enable on its own
    if ALL_CONTROLS:
        hudSubheader(
            getAllPlayers().filter(lambda localPlayer: localPlayer.faqPage == 0),
            _(ctrlsHudText[6])
            .replace("@0", "" if canToggleHints(localPlayer) else "<fg808080FF>")
            .replace("@1", "<fgFFFFFFFF>" if canToggleHints(localPlayer) else "")
            .replace("@2", inputBindingString(Button.ULTIMATE))
            .replace("@3", inputBindingString(Button.ABILITY_2)),
            HudPosition.TOP,
            4.07,
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
    # Between Spectate and Lobby/Pause, for everyone, as it works anywhere (HUD Input)
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
        4.09,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[8] = _("Lobby/Pause:             <fgFFFFFFFF>@0 + @1 (Hold)</fg>")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and not localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[8])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.ABILITY_2)),
        HudPosition.TOP,
        4.10,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    ctrlsHudText[9] = _(
        "Lobby:                          <fgFFFFFFFF>@0 + @1 (Hold)</fg>"
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                isViewingCtrlsList(localPlayer)
                and localPlayer.spectating[0]
                and localPlayer.faqPage == 0
            )
        ),
        _(ctrlsHudText[9])
        .replace("@0", inputBindingString(Button.ULTIMATE))
        .replace("@1", inputBindingString(Button.ABILITY_2)),
        HudPosition.TOP,
        4.11,
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
        4.12,
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
        4.13,
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
        4.14,
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
        4.15,
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
        4.16,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Prev. Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[5] == false
    @Condition (
        (eventPlayer.runCurrentCp > 0 and not eventPlayer.spectating[0])
        or (eventPlayer.spectating[4] > 0 and eventPlayer.spectating[0])
    ) == true
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.faqPage == 0

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


rule "Next Checkpoint Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    # Next Language (HUD Input)
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[5] == false
    @Condition (
        (eventPlayer.runCurrentCp < lastCp and not eventPlayer.spectating[0])
        or (eventPlayer.spectating[4] < lastCp and eventPlayer.spectating[0])
    ) == true
    @Condition eventPlayer.isInLobby == false
    @Condition (eventPlayer.hasSpawned() and not eventPlayer.isLoading) == true
    @Condition eventPlayer.faqPage == 0

    eventPlayer.isLoading = true
    # Like Prev. Checkpoint Input
    if eventPlayer.spectating[0] and not eventPlayer.spectating[2]:
        swapToJetpackCat()
    eventPlayer.setSecondaryFireEnabled(false)
    pauseRun()
    if not eventPlayer.spectating[0]:
        # Only skipping past the furthest CP cleared disqualifies the run
        if eventPlayer.runCurrentCp >= eventPlayer.runFurthestCp:
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
                if eventPlayer.runCurrentCp >= eventPlayer.runFurthestCp:
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


rule "New Run Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.faqPage == 0

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


rule "Freemode Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[0] == false
    @Condition eventPlayer.spectating[5] == false
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.runCurrentCp < lastCp
    @Condition eventPlayer.faqPage == 0

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


rule "Left CP In Freemode":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
    ) == true
    @Condition eventPlayer.isInFreemode == true
    @Condition eventPlayer.isRunLegit == true
    @Condition eventPlayer.runCurrentCp < lastCp
    # Like skipping, leaving a CP already cleared this run is allowed
    @Condition eventPlayer.runCurrentCp >= eventPlayer.runFurthestCp
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
        > eventPlayer.cpData[1]
    )

    # Freemode can't clear CPs, but it can be used to practice the ones ahead, so a run only
    # stops counting once the player is away from their CP with freemode on.
    # Turning it on mid-attempt counts too, as the player is already away from the CP.
    eventPlayer.isRunLegit = false


rule "Load Freemode HUD":
    freemodeHudText = _("\nFreemode On")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInFreemode
            and not localPlayer.spectating[0]
            and localPlayer.faqPage == 0
        ),
        _(freemodeHudText),
        HudPosition.LEFT,
        1,
        rgb(203, 135, 255),
        HudReeval.VISIBILITY_AND_STRING
    )


# Spectator controls have their own file. It's included here, not at the end,
# because the Workshop runs rules in file order.
#!include "spectator.opy"


rule "Lobby Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.spectating[5] == false

    # A tap turns hints on or off. It shares this rule with Lobby/Pause because every
    # eachPlayer rule adds to the server's load.
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
    if eventPlayer.isInLobby or eventPlayer.faqPage > 0 or not RULE_CONDITION:
        return
    eventPlayer.isLoading = true
    if eventPlayer.spectating[0]:
        disableSpectator()
    eventPlayer.setAbility2Enabled(false)
    pauseRun()
    eventPlayer.isViewingRunCompletionText = false
    loadLobby()
    eventPlayer.isLoading = false


rule "FAQ Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    @Condition eventPlayer.spectating[5] == false
    # Melee alone closes it, Ultimate or not (FAQ: Open)
    @Condition eventPlayer.faqPage == 0

    # Opens the FAQ, where either fire turns its pages, once Melee is let go, so the same
    # press doesn't close it again at once
    waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), Math.INFINITY)
    eventPlayer.faqPage = 1


rule "Load Hints HUD":
    # Under FAQ at the top left. While hints are off, or can't be turned on (grayed out), the
    # same spot shows how to turn them on
    hintsHudText[0] = _("@0Hints: @1@2 + @3</fg>")
    # The colors are explained in the FAQ
    hintsHudText[1] = _("Hints On")
    hintsHudText[2] = _("No Hint For This CP")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: controlsVisible(
                not localPlayer.isInLobby and localPlayer.faqPage == 0
            )
        ),
        (
            (
                _(hintsHudText[0])
                .replace("@0", "" if canToggleHints(localPlayer) else "<fg808080FF>")
                .replace("@1", "<fgFFFFFFFF>" if canToggleHints(localPlayer) else "")
                .replace("@2", inputBindingString(Button.ULTIMATE))
                .replace("@3", inputBindingString(Button.ABILITY_2))
                if allControlsOr(
                    not localPlayer.isHintOn or not canToggleHints(localPlayer)
                )
                else (
                    _(hintsHudText[1])
                    if len(hintRoutes[localPlayer.viewCp]) > 1
                    else _(hintsHudText[2])
                )
            )
        ),
        HudPosition.LEFT,
        0.2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Scorecard Input":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.spectating[5] == false

    eventPlayer.isScorecardHidden = not eventPlayer.isScorecardHidden
