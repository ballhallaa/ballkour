#!mainFile "../main.opy"
#!rulePrefix "Completion"


rule "Checkpoint (No Skipping)":
    @Event eachPlayer
    @Condition (
        eventPlayer.hasSpawned()
        and not eventPlayer.isLoading
        and not eventPlayer.isInLobby
        and not eventPlayer.hasStatus(Status.ROOTED)
    ) == true
    @Condition eventPlayer.isRunLoaded == true
    @Condition eventPlayer.isInFreemode == false
    @Condition eventPlayer.isRunPaused == false
    @Condition (
        eventPlayer.isOnGround()
        or eventPlayer.cpData[9]
        or eventPlayer.getAltitude() <= 0.02
        and not eventPlayer.cpData[15]
    ) == true
    @Condition eventPlayer.spectating[0] == false
    @Condition (
        distance(eventPlayer.getPosition(), eventPlayer.cpData[7])
        <= eventPlayer.cpData[8]
    )

    # An orb checkpoint only clears with all its orbs, so landing here without them is a mistake
    if eventPlayer.cpData[5] != null and not hasAllOrbs(eventPlayer):
        eventPlayer.isLoading = true
        addMistake()
        cpResetPlayer()
        eventPlayer.isLoading = false
        return
    stopChasingVariable(eventPlayer.cpTime)
    recordSplit()
    # Not a route played in Assist Mode, which the CP's own rules might not allow
    if (
        isHintRecorderOn
        and eventPlayer == hostPlayer
        and not eventPlayer.isInAssistMode
    ):
        saveHintRoute()
    resetCpMistakes()
    eventPlayer.isLoading = true
    # A clear ends an attempt too
    eventPlayer.cpAttempts[eventPlayer.runCurrentCp]++
    eventPlayer.runCurrentCp++
    eventPlayer.runFurthestCp = max(eventPlayer.runFurthestCp, eventPlayer.runCurrentCp)
    syncSpectatorCps()
    showCpNameplate()
    loadCpData()
    setCpAbilities()
    if eventPlayer.runCurrentCp < lastCp:
        if (
            distance(eventPlayer.getPosition(), eventPlayer.cpData[0])
            > eventPlayer.cpData[1]
        ):
            eventPlayer.isLoading = true
            eventPlayer.teleport(eventPlayer.cpData[0])
            eventPlayer.applyImpulse(
                eventPlayer.getVelocity() * -0.001,
                0.001,
                Relativity.TO_WORLD,
                Impulse.CANCEL_CONTRARY_MOTION_XYZ
            )
            eventPlayer.isLoading = false
        playEffect(
            eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 100
        )
    eventPlayer.isLoading = false


rule "Final Checkpoint Reached":
    @Event eachPlayer
    @Condition eventPlayer.runCurrentCp == lastCp

    playEffect(
        eventPlayer, DynamicEffect.BAD_PICKUP_EFFECT, Color.GREEN, eventPlayer, 200
    )
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
    if eventPlayer.spectating[0]:
        return
    if not eventPlayer.isRunPaused:
        stopChasingVariable(eventPlayer.runTime)
        eventPlayer.isRunPaused = true
        # Lobby Stats are for the regular leaderboard's runs. Assisted runs go in the Lobby
        # Top 3 with the rest, marked (Record Top Run).
        if eventPlayer.isRunLegit and not eventPlayer.isRunAssisted:
            if isLobbyStatsOn:
                updateStats()
    if not eventPlayer.isRunFinished:
        eventPlayer.runCount++
        eventPlayer.isRunFinished = true
        eventPlayer.runFinalTimeFormatted = eventPlayer.runTimeFormatted
        eventPlayer.runFinalMistakes = eventPlayer.runMistakes
        eventPlayer.isViewingRunCompletionText = true
        if eventPlayer.isRunLegit:
            recordTopRun()
    eventPlayer.isInFreemode = true
    eventPlayer.nameplate = _("{} | FREEMODE").format(eventPlayer)


def recordTopRun():
    @Name "Record Top Run"

    # topRuns lists runs as [0]time [1]name [2]mistakes [3]timeFormatted [4]assisted
    # By name, so a run stays listed after its player leaves, and one player can only hold one
    # spot, with their best run, assisted or not
    topRunsScratch = topRuns.filter(lambda run: run[1] == "{}".format(eventPlayer))
    if len(topRunsScratch) > 0 and topRunsScratch[0][0] <= eventPlayer.runTime:
        return
    topRunsScratch = topRuns.filter(lambda run: run[1] != "{}".format(eventPlayer))
    topRunsScratch[len(topRunsScratch)] = [
        eventPlayer.runTime,
        "{}".format(eventPlayer),
        eventPlayer.runFinalMistakes,
        eventPlayer.runFinalTimeFormatted,
        eventPlayer.isRunAssisted
    ]
    topRunsScratch = sorted(topRunsScratch, lambda run: run[0]).slice(0, 3)
    topRuns = topRunsScratch
    topRunsText = ""
    # Padded like the scorecard's columns, but for 2-digit mistakes, and times of 7+ characters.
    # The mistakes get a × in the row's color, as a red one marks a disqualified run there.
    # Assisted runs get a pink * after the name, like Assist Mode's pink, outside the row's
    # color, as the scorecard's red × is.
    for index in range(len(topRunsScratch)):
        topRunsText = "{}\n{}{}   {}{}{}×{}{}</fg>{}".format(
            topRunsText,
            ["<fgFFFF00FF>", "<fgB0C4DEFF>", "<fgC46A30FF>"][index],
            index + 1,
            topRunsScratch[index][3],
            "     " if strLen(topRunsScratch[index][3]) < 8 else "   ",
            topRunsScratch[index][2],
            "     " if topRunsScratch[index][2] < 10 else "   ",
            topRunsScratch[index][1],
            "<fgFF80C0FF>*</fg>" if topRunsScratch[index][4] else ""
        )


rule "Load Run Text":
    @Event eachPlayer
    @Condition eventPlayer.isViewingRunCompletionText == true

    # Stays open until Interact closes it. Interact alone does nothing else on the last CP, and
    # the FAQ hides the text, so it can't close it unseen there.
    waitUntil(
        eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.faqPage == 0,
        Math.INFINITY
    )
    eventPlayer.isViewingRunCompletionText = false


rule "Run Text":
    # A size up from the lines under it, with the name in the Top-10 Time! gold. The blank
    # lines and icons stay out of the translation, so its msgid is unchanged.
    completionHudText[0] = _("Congrats, @0!")
    hudSubtext(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.faqPage == 0
        ),
        "\n\n{0} {1} {0}\n".format(
            iconString(Icon.ASTERISK),
            _(completionHudText[0]).replace(
                "@0", ("<fgFFD200FF>{}</fg>").format(localPlayer)
            )
        ),
        HudPosition.TOP,
        1,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING
    )
    # Bolt and Skull, like the time and mistakes counters on the right, and Fire for the
    # time to beat
    completionHudText[1] = _("Time: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.faqPage == 0
        ),
        "{} {}".format(
            iconString(Icon.BOLT),
            _(completionHudText[1]).replace(
                "@0", ("<fgFFFFFFFF>{}</fg>").format(localPlayer.runFinalTimeFormatted)
            )
        ),
        HudPosition.TOP,
        1.1,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    completionHudText[2] = _("Time to Beat: @0")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.faqPage == 0
        ),
        "{} {}".format(
            iconString(Icon.FIRE),
            _(completionHudText[2]).replace(
                "@0", ("<fgFFFFFFFF>{}</fg>").format(timeToBeatFormatted)
            )
        ),
        HudPosition.TOP,
        1.2,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    completionHudText[3] = _("Mistakes: @0\n")
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.faqPage == 0
        ),
        "{} {}".format(
            iconString(Icon.SKULL),
            _(completionHudText[3]).replace(
                "@0", ("<fgFFFFFFFF>{}</fg>").format(localPlayer.runFinalMistakes)
            )
        ),
        HudPosition.TOP,
        1.3,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )
    # Lines start with a color tag and then their centering spaces: OverPy adds a line's
    # leading spaces to every translation, but spaces after the tag are the translation's own
    completionHudText[4] = _(
        "<fgFFFFFFFF>Submit a Video of Your Run</fg>\n"
        "<fgFFFFFFFF>                        @</fg>\n"
        "<fg00E092FF>              ballkour.com</fg>\n\n"
        "<fgFFFFFFFF>       Thanks for Playing!</fg>"
    )
    # Goes above completionHudText[4], so the shared lines are only stored once
    completionHudText[5] = _("<fgFFD200FF>                Top-10 Time!</fg>")
    completionHudText[6] = _(
        "<fgFF4646FF>   Run Not Counted</fg>\n"
        "<fgFF4646FF>          Skipped CPs</fg>\n\n"
        "<fgFFFFFFFF>Thanks for Playing!</fg>"
    )
    # Goes above completionHudText[4] too, for a run Assist Mode was on for, which goes on the
    # assisted leaderboard, so its video says which board it's for. In Assist Mode's pink, and
    # never with Top-10 Time!, as the time to beat is the regular leaderboard's.
    completionHudText[7] = _("<fgFF80C0FF>               Assisted Run</fg>")
    # One text for the four endings, as texts are capped at 128 per server, HUD texts
    # included (Lobby: Load Buttons). Every line has its own color, so the text's is unseen.
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.faqPage == 0
        ),
        (
            _(completionHudText[6])
            if not localPlayer.isRunLegit
            else (
                "{}\n{}".format(_(completionHudText[7]), _(completionHudText[4]))
                if localPlayer.isRunAssisted
                else (
                    "{}\n{}".format(_(completionHudText[5]), _(completionHudText[4]))
                    if timeToBeat == 0 or localPlayer.runTime <= timeToBeat
                    else _(completionHudText[4])
                )
            )
        ),
        HudPosition.TOP,
        1.4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING
    )
    # Reuses the FAQ's close line, so its translations are only stored once
    hudSubheader(
        getAllPlayers().filter(
            lambda localPlayer: localPlayer.isViewingRunCompletionText
            and localPlayer.faqPage == 0
        ),
        "\n\n{}".format(
            _(faqHudText[26]).replace("@0", inputBindingString(Button.INTERACT))
        ),
        HudPosition.TOP,
        1.5,
        rgb(230, 151, 0),
        HudReeval.VISIBILITY_AND_STRING
    )


def updateStats():
    @Name "Update Lobby Stats"

    # Wrapped so release builds leave the subroutine out entirely
    if DEV:
        lobbyStats[2]++
        lobbyStats[3] += eventPlayer.runTime
        eventPlayer.timeToFormat = lobbyStats[3]
        formatTime()
        lobbyStats[4] = eventPlayer.timeFormatted
        lobbyStats[5] += eventPlayer.runMistakes
        lobbyStats[6] = lobbyStats[3] / lobbyStats[2]
        eventPlayer.timeToFormat = lobbyStats[6]
        formatTime()
        lobbyStats[7] = eventPlayer.timeFormatted
        lobbyStats[8] = lobbyStats[5] / lobbyStats[2]
