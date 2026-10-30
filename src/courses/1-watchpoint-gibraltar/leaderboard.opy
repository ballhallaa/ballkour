#!mainFile "1-watchpoint-gibraltar.opy"

rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    lb[1] = "BALLMYBLOVED, 3:54.23, 5, '           '"
    lb[2] = "COLDSKIN, 4:05.81, 2, '                     '"
    lb[3] = "JAKOBONEDGE, 4:21.96, 12, '         '"
    lb[4] = "BACKLINEREIN, 4:34.15, 15, '           '"
    lb[5] = "DVD, 5:02.50, 15, '                            '"
    lb[6] = "GAMINGCHAIR, 5:08.37, 16, '         '"
    lb[7] = "BLOWSKI, 5:40.50, 24, '                    '"
    lb[8] = "安宁, 5:51.20, 40, '                           '"
    lb[9] = "KINGO, 6:26.18, 37, '                        '"
    lb[10] = "VANESSA, 6:59.56, 58, '                  '"


def loadRunInfo():
    @Name "Leaderboard Run Info"

    # lbRunInfo(rank, submission date (UTC), video link without https://)
    lbRunInfo(1, "Jun 2, 2026", "youtu.be/Rkz9kWNEiHM")
    lbRunInfo(2, "Aug 26, 2026", "youtu.be/xDH0hywqCtc")
    lbRunInfo(3, "Jun 11, 2026", "youtu.be/L3tIoo9Ue40")
    lbRunInfo(4, "May 13, 2026", "youtu.be/SDw339nB_dw")
    lbRunInfo(5, "May 7, 2026", "youtu.be/RXrrX5Sj_L0")
    lbRunInfo(6, "May 7, 2026", "youtu.be/Ufn1zTb1Upo")
    lbRunInfo(7, "Jun 13, 2026", "medal.tv/games/overwatch/clips/mTEZK5NUYrfkDFtcS")
    lbRunInfo(8, "Jun 12, 2026", "medal.tv/games/overwatch/clips/mTG72hXv3vOdGEDPP")
    lbRunInfo(9, "Jun 10, 2026", "youtu.be/OaXIV4kSh_k")
    lbRunInfo(10, "Sep 30, 2026", "medal.tv/games/overwatch/clips/nDcPQeGIujXfUqe5G")
