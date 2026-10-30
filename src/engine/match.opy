#!mainFile "../main.opy"
#!rulePrefix "Match"


rule "Initialize":
    disableAnnouncer()
    disableGamemodeCompletion()
    setMatchTime(0)
    if not isDebugOn and not isHintRecorderOn:
        disableInspector()
    if isLobbyStatsOn:
        players = []
        # lobbyStats[i]: [0]players [1]rejoins [2]legitRuns [3]totalRunTime [4]totalRunTimeFormatted [5]totalMistakes [6]avgRunTime [7]avgRunTimeFormatted [8]avgMistakes
        lobbyStats = [0, 0, 0, 0, "00:00.00", 0, 0, "00:00.00", 0]
    # timeToBeat: the 10th place's time in seconds, or 0 while the leaderboard has fewer than 10 runs
    timeToBeat = 0
    timeToBeatFormatted = "00:00.00"
    if lb[10] != null:
        timeToBeatFormatted = lb[10].split(",")[1].replace(" ", "")
        # Reads [H:]M:SS.cc left to right: each ":" carries the units read so far into the next one,
        # which leaves the seconds and hundredths in lbObj as one number (SScc)
        lbObj = 0
        for index in range(strLen(timeToBeatFormatted)):
            if timeToBeatFormatted.charAt(index) == ":":
                timeToBeat = (timeToBeat + lbObj) * 60
                lbObj = 0
            elif timeToBeatFormatted.charAt(index) != ".":
                lbObj = lbObj * 10 + "0123456789".strIndex(
                    timeToBeatFormatted.charAt(index)
                )
        timeToBeat += lbObj / 100
    nameplateObjs = []
    tinyNameplateObjs = []


rule "Start Elapsed Timer":
    chaseAtRate(elapsedTime, 14340, 1)


rule "Format Elapsed Time":
    @Event eachPlayer
    @Condition isLobbyStatsOn == true
    @Condition isDebugOn == false
    @Condition eventPlayer == hostPlayer

    wait(0.1)
    eventPlayer.timeToFormat = elapsedTime
    formatTime()
    elapsedTimeFormatted = eventPlayer.timeFormatted
    if RULE_CONDITION:
        loop()


rule "Spawn Disruptive Environment Destructors (DEDs)":
    waitUntil(hostPlayer.hasSpawned(), Math.INFINITY)
    # ded[i]: [0]nextDedInNewBatch [1]batchSize [2]currentDed [3]dedEntity [4]slot
    ded = [1, 0, 0, 0, 0]
    while ded[0] < len(dedBots):
        ded[1] = min(
            getNumberOfSlots(dedBots[0]) - len(getPlayers(dedBots[0])),
            len(dedBots) - ded[0]
        )
        if ded[1] <= 0:
            wait(1)
        else:
            ded[2] = 0
            ded[4] = getNumberOfSlots(dedBots[0]) - 1
            while ded[2] < ded[1] and ded[4] >= 0:
                if getPlayersInSlot(ded[4], dedBots[0]) == null:
                    createDummy(
                        Hero.LUCIO,
                        dedBots[0],
                        ded[4],
                        dedBots[ded[0] + ded[2]][0],
                        directionTowards(
                            dedBots[ded[0] + ded[2]][0], dedBots[ded[0] + ded[2]][1]
                        )
                    )
                    ded[3] = getLastCreatedEntity()
                    ded[3].startForcingName(
                        "Disruptive Environment Destructor {}".format(ded[0] + ded[2])
                    )
                    ded[2] = ded[2] + 1
                ded[4] = ded[4] - 1
            ded[2] = 0
            while ded[2] < ded[1]:
                waitUntil(
                    getAllPlayers().filter(lambda p: p.isDummy())[ded[2]].hasSpawned(),
                    5
                )
                getAllPlayers().filter(lambda p: p.isDummy())[ded[2]].forceButtonPress(
                    Button.SECONDARY_FIRE
                )
                ded[2] = ded[2] + 1
            wait()
            if len(getAllPlayers().filter(lambda p: p.isDummy())) >= ded[1]:
                ded[0] = ded[0] + ded[1]
            destroyAllDummies()
            waitUntil(len(getAllPlayers().filter(lambda p: p.isDummy())) == 0, 1)


rule "Auto-Restart Server":
    @SuppressWarnings w_ow2_rule_condition_chase
    # 3hr29min in
    @Condition elapsedTime >= 12540

    chaseAtRate(elapsedTime, Math.INFINITY, 1)
    bigMessage(
        true[0],
        _(
            "Server restart: "
            "\n30min"
        )
    )
    wait(900)
    bigMessage(
        true[0],
        _(
            "Server restart: "
            "\n15min"
        )
    )
    wait(600)
    bigMessage(
        true[0],
        _(
            "Server restart: "
            "\n5min"
        )
    )
    wait(240)
    bigMessage(
        true[0],
        _(
            "Server restart: "
            "\n1min"
        )
    )
    wait(60)
    # 3hr59min in
    restartMatch()


rule "Server Load HUD":
    @Condition isServerLoadOn == true

    # Overwatch shuts the server down as its load nears 100%, so this shows the host what pushes it up
    hudSubtext(
        hostPlayer,
        "Server Load: {}% | Avg: {}% | 10s Avg: {}% | Peak: {}%".format(
            round(getServerLoad()),
            round(getAverageServerLoad()),
            round(serverLoadAvg),
            round(getPeakServerLoad())
        ),
        HudPosition.RIGHT,
        8,
        Color.LIGHT_VIOLET,
        HudReeval.VISIBILITY_AND_STRING
    )
    # Avg only covers 2s and jumps around too much to compare builds by, so 10s Avg evens it out
    while true:
        serverLoadAvg += (getServerLoad() - serverLoadAvg) / 100
        wait(0.1)
