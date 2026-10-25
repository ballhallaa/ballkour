#!mainFile "../main.opy"
#!rulePrefix "Match"


rule "Initialize":
    disableAnnouncer()
    disableGamemodeCompletion()
    setMatchTime(0)
    if not settings_[0] and not settings_[2]:
        disableInspector()
    if settings_[1]:
        players = []
        # lobbyStats[i]: [0]players [1]rejoins [2]legitRuns [3]totalRunTime [4]totalRunTimeFormatted [5]totalMistakes [6]avgRunTime [7]avgRunTimeFormatted [8]avgMistakes
        lobbyStats = []
        lobbyStats[0] = 0
        lobbyStats[1] = 0
        lobbyStats[2] = 0
        lobbyStats[3] = 0
        lobbyStats[4] = "00:00.00"
        lobbyStats[5] = 0
        lobbyStats[6] = 0
        lobbyStats[7] = "00:00.00"
        lobbyStats[8] = 0
    lbObj = lb[10].split(",")[1].replace(" ", "").split(":")
    lbObjFormatted = lbObj[len(lbObj) - 1].split(".")
    timeToBeatInMs = (
        (
            (
                (
                    ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                        lbObj[0].substring(0, 1)
                    )
                    * 10
                    + ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                        lbObj[0].substring(1, 1)
                    )
                )
                if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObj[0].substring(1, 1)
                )
                >= 0
                else ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObj[0].substring(0, 1)
                )
            )
            * 3600000
            if len(lbObj) >= 3
            else 0
        )
        + (
            (
                ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObj[len(lbObj) - 2].substring(0, 1)
                )
                * 10
                + ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObj[len(lbObj) - 2].substring(1, 1)
                )
            )
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                lbObj[len(lbObj) - 2].substring(1, 1)
            )
            >= 0
            else ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                lbObj[len(lbObj) - 2].substring(0, 1)
            )
        )
        * 60000
        + (
            (
                ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObjFormatted[0].substring(0, 1)
                )
                * 10
                + ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObjFormatted[0].substring(1, 1)
                )
            )
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                lbObjFormatted[0].substring(1, 1)
            )
            >= 0
            else ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                lbObjFormatted[0].substring(0, 1)
            )
        )
        * 1000
        + (
            (
                ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObjFormatted[1].substring(0, 1)
                )
                * 10
                + ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                    lbObjFormatted[1].substring(1, 1)
                )
            )
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                lbObjFormatted[1].substring(1, 1)
            )
            >= 0
            else ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].index(
                lbObjFormatted[1].substring(0, 1)
            )
        )
        * 10
    )
    nameplateObjs = []
    tinyNameplateObjs = []


rule "Start Elapsed Timer":
    chaseAtRate(elapsedTime, 14340, 1)
    if settings_[1] and not settings_[0]:
        while true:
            wait(0.1)
            elapsedTimeFormatted = (
                "{}:{}:{}".format(
                    floor(elapsedTime / 3600),
                    (elapsedTime % 3600 / 60 + 100).substring(1, 2),
                    (elapsedTime % 60 + 100).substring(1, 9999)
                )
                if elapsedTime >= 3600
                else (
                    "{}:{}".format(
                        floor(elapsedTime / 60),
                        (elapsedTime % 60 + 100).substring(1, 9999)
                    )
                    if elapsedTime >= 60
                    else "{}.{}".format(
                        floor(elapsedTime),
                        (round(elapsedTime % 1 * 100) + 100).substring(1, 2)
                    )
                )
            )


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
    bigMessage(true[0], "Server restart: \n30min")
    wait(900)
    bigMessage(true[0], "Server restart: \n15min")
    wait(600)
    bigMessage(true[0], "Server restart: \n5min")
    wait(240)
    bigMessage(true[0], "Server restart: \n1min")
    wait(60)
    # 3hr59min in
    restartMatch()
