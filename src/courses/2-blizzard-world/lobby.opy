#!mainFile "2-blizzard-world.opy"

rule "Lobby":
    # lobbyData[i]: [0]spawnpoint [1]facing [2]welcomeSignTop [3]welcomeSignBottom [4]welcomeSignSize [5]newRunRing [6]newRunIcon [7]newRunSign [8]resumeRunRing [9]resumeRunIcon [10]resumeRunSign [11]lbSign [12]lbSignTextSize [13]lbPosTextSize [14]statsSign [15]statsSignSize [16]statsSize [17]elapsedTime [18]newPlayers [19]rejoins [20]legitRuns [21]totalRunTime [22]totalMistakes [23]avgRunTime [24]avgMistakes [25]boundaryRadius
    lobbyData = []
    lobbyData[0] = vect(2.9, -4.95, -42.38)
    lobbyData[5] = vect(3, -3.99, -22.07)
    lobbyData[6] = lobbyData[5] + vect(0, -1, 0)
    lobbyData[7] = lobbyData[5] + vect(0, 1.5, 0)
    lobbyData[1] = lobbyData[5] + vect(0, 2.3, 0)
    lobbyData[2] = lobbyData[5] + vect(0, 4.2, 0)
    lobbyData[3] = lobbyData[2] + vect(0, -1.05, 0)
    lobbyData[4] = 1.35
    lobbyData[8] = vect(-0.31, -3.99, -25.54)
    lobbyData[9] = lobbyData[8] + vect(0, -1, 0)
    lobbyData[10] = lobbyData[8] + vect(0, 1.5, 0)
    lobbyData[11] = vect(12.055, 1.25, -23.265)
    lobbyData[12] = 1.2
    lobbyData[13] = 0.7
    lobbyData[25] = 20
    lbPos = []
    lbPos[1] = lobbyData[11] + vect(0, -0.65, 0)
    for index in range(2, 11):
        lbPos[index] = lbPos[1] + vect(0, -0.4, 0) * (index - 1)
    if isLobbyStatsOn:
        lobbyData[14] = vect(12.03, 1.25, -32.93)
        lobbyData[15] = 1.2
        lobbyData[16] = 0.7
        lobbyData[17] = lobbyData[14] + vect(0, -0.65, 0)
        # The stats rows use the leaderboard's row spacing
        for index in range(18, 25):
            lobbyData[index] = lobbyData[17] + vect(0, -0.4, 0) * (index - 17)
