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


rule "Spawn Disrupter Destructors":
    waitUntil(hostPlayer.hasSpawned(), Math.INFINITY)
    # dd[i]: [0]nextDdInNewBatch [1]batchSize [2]currentDd [3]ddEntity [4]slot
    dd = [1, 0, 0, 0, 0]
    while dd[0] < len(ddBots):
        dd[1] = min(
            getNumberOfSlots(ddBots[0]) - len(getPlayers(ddBots[0])),
            len(ddBots) - dd[0]
        )
        if dd[1] <= 0:
            wait(1)
        else:
            dd[2] = 0
            dd[4] = getNumberOfSlots(ddBots[0]) - 1
            while dd[2] < dd[1] and dd[4] >= 0:
                if getPlayersInSlot(dd[4], ddBots[0]) == null:
                    createDummy(
                        Hero.LUCIO,
                        ddBots[0],
                        dd[4],
                        ddBots[dd[0] + dd[2]][0],
                        directionTowards(
                            ddBots[dd[0] + dd[2]][0], ddBots[dd[0] + dd[2]][1]
                        )
                    )
                    dd[3] = getLastCreatedEntity()
                    dd[3].startForcingName(
                        "Disrupter Destructor {}".format(dd[0] + dd[2])
                    )
                    dd[2] = dd[2] + 1
                dd[4] = dd[4] - 1
            dd[2] = 0
            while dd[2] < dd[1]:
                waitUntil(
                    getAllPlayers().filter(lambda p: p.isDummy())[dd[2]].hasSpawned(), 5
                )
                getAllPlayers().filter(lambda p: p.isDummy())[dd[2]].forceButtonPress(
                    Button.SECONDARY_FIRE
                )
                dd[2] = dd[2] + 1
            wait()
            if len(getAllPlayers().filter(lambda p: p.isDummy())) >= dd[1]:
                dd[0] = dd[0] + dd[1]
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
