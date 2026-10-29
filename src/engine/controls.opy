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
    # Stays open through Lobby/Pause, since the lobby has controls too
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE), Math.INFINITY)
    eventPlayer.isViewingCtrlsHud = false
    eventPlayer.allowButton(Button.MELEE)
    if not eventPlayer.spectating[0] or eventPlayer.spectating[2]:
        eventPlayer.allowButton(Button.PRIMARY_FIRE)
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
    if not eventPlayer.spectating[0]:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)


rule "Load HUD":
    # The lobby only has New Run and Spectate
    # Each line is one translated string with its padding inside, so a translation can
    # pad its own label. Grayed-out lines take their colors as arguments for the same reason.
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.isInLobby
        ),
        _("{}Prev. CP:                               {}{} + {}</fg>").format(
            "" if localPlayer.viewCp > 0 else "<fg808080FF>",
            "<fgFFFFFFFF>" if localPlayer.viewCp > 0 else "",
            inputBindingString(Button.ULTIMATE),
            inputBindingString(Button.PRIMARY_FIRE)
        ),
        HudPosition.LEFT,
        1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.isInLobby
        ),
        _("{}Next CP:                               {}{} + {}</fg>").format(
            "" if localPlayer.viewCp < lastCp else "<fg808080FF>",
            "<fgFFFFFFFF>" if localPlayer.viewCp < lastCp else "",
            inputBindingString(Button.ULTIMATE),
            inputBindingString(Button.SECONDARY_FIRE)
        ),
        HudPosition.LEFT,
        2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and localPlayer.runCurrentCp < lastCp
        ),
        _("Reset CP:                           <fgFFFFFFFF>{} (Hold)</fg>").format(
            inputBindingString(Button.RELOAD)
        ),
        HudPosition.LEFT,
        3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(lambda localPlayer: localPlayer.isViewingCtrlsHud),
        _("New Run:                 <fgFFFFFFFF>{} + {} (Hold)</fg>").format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)
        ),
        HudPosition.LEFT,
        4,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.isInLobby
            and not localPlayer.spectating[0]
            and localPlayer.runCurrentCp < lastCp
        ),
        _("Freemode:                            <fgFFFFFFFF>{} + {}</fg>").format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.INTERACT)
        ),
        HudPosition.LEFT,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.isInLobby
            and localPlayer.viewCp < lastCp
            and len(hintRoutes) > 0
        ),
        (
            _("Disable Hints:                <fgFFFFFFFF>{} + {}</fg>").format(
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.MELEE)
            )
            if localPlayer.isHintOn
            else _("Enable Hints:                 <fgFFFFFFFF>{} + {}</fg>").format(
                inputBindingString(Button.ULTIMATE), inputBindingString(Button.MELEE)
            )
        ),
        HudPosition.LEFT,
        5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.spectating[0]
        ),
        _("Spectate:                       <fgFFFFFFFF>{} + {}</fg>").format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_1)
        ),
        HudPosition.LEFT,
        6,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and not localPlayer.isInLobby
            and not localPlayer.spectating[0]
        ),
        _("Lobby/Pause:         <fgFFFFFFFF>{} + {} (Hold)</fg>").format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
        ),
        HudPosition.LEFT,
        7,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and localPlayer.spectating[0]
        ),
        _("Lobby:                      <fgFFFFFFFF>{} + {} (Hold)</fg>").format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_2)
        ),
        HudPosition.LEFT,
        7,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and localPlayer.spectating[0]
        ),
        _(
            "<fg808080FF>- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -</fg>\n"
            "<fgEC9900FF>        Spectator Controls</fg>\n"
            "Disable:                         <fgFFFFFFFF>{} + {}</fg>"
        ).format(
            inputBindingString(Button.ULTIMATE), inputBindingString(Button.ABILITY_1)
        ),
        HudPosition.LEFT,
        7,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and localPlayer.spectating[0]
            and localPlayer.spectating[1] != null
            and localPlayer.spectating[2]
        ),
        _("Reattach:                      <fgFFFFFFFF>{} + {}</fg>").format(
            inputBindingString(Button.ABILITY_1), inputBindingString(Button.RELOAD)
        ),
        HudPosition.LEFT,
        8,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and localPlayer.spectating[0]
            and localPlayer.spectating[1] != null
        ),
        _("First Person:               <fgFFFFFFFF>{} + {}</fg>").format(
            inputBindingString(Button.ABILITY_1), inputBindingString(Button.INTERACT)
        ),
        HudPosition.LEFT,
        9,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and localPlayer.spectating[0]
        ),
        _(
            "{0}Prev. Player:              {1}{2} + {3}</fg>"
            "\n{0}Next Player:               {1}{2} + {4}</fg>"
        ).format(
            "" if localPlayer.spectating[7] else "<fg808080FF>",
            "<fgFFFFFFFF>" if localPlayer.spectating[7] else "",
            inputBindingString(Button.ABILITY_1),
            inputBindingString(Button.PRIMARY_FIRE),
            inputBindingString(Button.SECONDARY_FIRE)
        ),
        HudPosition.LEFT,
        10,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingCtrlsHud
            and localPlayer.spectating[0]
        ),
        # Freecam shares X-Hair Player's text: sort order 12 is taken by Spectating
        _("{}X-Hair Player:     {}{} + {}</fg>{}").format(
            (
                ""
                if localPlayer.spectating[2] and localPlayer.spectating[7]
                else "<fg808080FF>"
            ),
            (
                "<fgFFFFFFFF>"
                if localPlayer.spectating[2] and localPlayer.spectating[7]
                else ""
            ),
            inputBindingString(Button.ABILITY_1),
            inputBindingString(Button.JUMP),
            (
                _("\nFreecam:                             <fgFFFFFFFF>Move</fg>")
                if not localPlayer.spectating[2]
                else ""
            )
        ),
        HudPosition.LEFT,
        11,
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

    eventPlayer.isLoading = true
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

    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.isLoading = true
    pauseRun()
    if not eventPlayer.spectating[0]:
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
            eventPlayer.runMistakes++
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

    eventPlayer.disallowButton(Button.MELEE)
    if not eventPlayer.isInFreemode:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        if not eventPlayer.spectating[0]:
            eventPlayer.isRunLegit = false
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            eventPlayer.runMistakes++
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


rule "Load Freemode HUD":
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isInFreemode
            and not localPlayer.spectating[0]
        ),
        _("\n\nFreemode On"),
        HudPosition.LEFT,
        12,
        rgb(255, 70, 70),
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
    @Condition eventPlayer.isInLobby == false

    wait(0.35, Wait.ABORT_WHEN_FALSE)
    eventPlayer.isLoading = true
    if eventPlayer.spectating[0]:
        disableSpectator()
    eventPlayer.setAbility2Enabled(false)
    pauseRun()
    eventPlayer.isViewingRunCompletionText = false
    loadLobby()
    eventPlayer.isLoading = false


rule "Hints Input":
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
    @Condition eventPlayer.isInLobby == false
    @Condition eventPlayer.viewCp < lastCp

    eventPlayer.isHintOn = not eventPlayer.isHintOn
    # Toggled by hand, so moving to another CP doesn't turn them off
    eventPlayer.isHintAutoOn = false


rule "Load Hints HUD":
    # While hints are off, the same spot shows how to turn them on
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: not localPlayer.isInLobby
            and localPlayer.viewCp < lastCp
            and len(hintRoutes) > 0
        ),
        ("\n\n{}").format(
            (
                _("Hints: <fgFFFFFFFF>{} + {}</fg>").format(
                    inputBindingString(Button.ULTIMATE),
                    inputBindingString(Button.MELEE)
                )
                if not localPlayer.isHintOn
                else (
                    _("Hints On" "\nInfo: <fgFFFFFFFF>{} + {}</fg>{}").format(
                        inputBindingString(Button.ULTIMATE),
                        inputBindingString(Button.ABILITY_2),
                        (
                            _(
                                "\n   <fgCB87FFFF>Movement</fg>"
                                "\n   <fgFFFFFFFF>Jump</fg>"
                                "\n   <fgFFD200FF>Grapple</fg>"
                                "\n   <fgFF4646FF>Piledrive</fg>"
                                "\n   <fg00BEFFFF>Shield Bounce</fg>"
                                "\nDisable: <fgFFFFFFFF>{} + {}</fg>"
                            ).format(
                                inputBindingString(Button.ULTIMATE),
                                inputBindingString(Button.MELEE)
                            )
                            if localPlayer.isViewingHintInfo
                            else ""
                        )
                    )
                    if len(hintRoutes[localPlayer.viewCp]) > 1
                    else _("No Hint For This CP")
                )
            )
        ),
        HudPosition.LEFT,
        15,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


rule "Hint Info Input":
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
    @Condition eventPlayer.isHintOn == true
    @Condition len(hintRoutes[eventPlayer.viewCp]) > 1
    @Condition eventPlayer.spectating[5] == false
    @Condition eventPlayer.isInLobby == false

    # Holding the same combo is Lobby/Pause, so only a tap toggles info
    waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_2), 0.35)
    if eventPlayer.isHoldingButton(Button.ABILITY_2):
        return
    eventPlayer.isViewingHintInfo = not eventPlayer.isViewingHintInfo
