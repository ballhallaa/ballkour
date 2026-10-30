#!mainFile "3-paraíso.opy"

rule "Lobby":
    # lobbyData[i]: [0]spawnpoint [1]facing [2]welcomeSignTop [3]welcomeSignBottom [4]welcomeSignSize [5]startRunRing [6]startRunIcon [7]startRunSign [8]resumeRunRing [9]resumeRunIcon [10]resumeRunSign [11]lbSign [12]lbSignTextSize [13]lbPosTextSize [14]statsSign [15]statsSignSize [16]statsSize [17]elapsedTime [18]newPlayers [19]rejoins [20]legitRuns [21]totalRunTime [22]totalMistakes [23]avgRunTime [24]avgMistakes [25]boundaryRadius
    lobbyData = []
    lobbyData[0] = vect(-38.33, 6.01, -96.34)
    lobbyData[5] = vect(-27.165, 6.01, -89.69)
    lobbyData[6] = lobbyData[5] + vect(0, -1, 0)
    lobbyData[7] = lobbyData[5] + vect(0, 1.5, 0)
    lobbyData[1] = lobbyData[5] + vect(0, 2.75, 0)
    lobbyData[2] = lobbyData[5] + vect(0, 5.25, 0)
    lobbyData[3] = lobbyData[2] + vect(0, -0.8, 0)
    lobbyData[4] = 1.5
    lobbyData[8] = vect(-25.805, 6.01, -94.965)
    lobbyData[9] = lobbyData[8] + vect(0, -1, 0)
    lobbyData[10] = lobbyData[8] + vect(0, 1.5, 0)
    lobbyData[11] = vect(-31.81, lobbyData[2].y + 0.5, -84.87)
    lobbyData[12] = 1.2
    lobbyData[13] = 0.85
    lobbyData[25] = 18
    lbPos = []
    lbPos[1] = lobbyData[11] + vect(0, -0.65, 0)
    for index in range(2, 11):
        lbPos[index] = lbPos[1] + vect(0, -0.5, 0) * (index - 1)
    if isLobbyStatsOn:
        lobbyData[14] = vect(-30.34, lobbyData[11].y - 0.5, -101.15)
        lobbyData[15] = 1.08
        lobbyData[16] = 0.765
        lobbyData[17] = lobbyData[14] + vect(0, -0.585, 0)
        for index in range(18, 25):
            lobbyData[index] = lobbyData[17] + vect(0, -0.45, 0) * (index - 17)
