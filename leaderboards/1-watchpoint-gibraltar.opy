#!mainFile "../src/courses/1-watchpoint-gibraltar/1-watchpoint-gibraltar.opy"

rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator, then a # discord: ID comment to link the player
    lb = []
    lb[1] = "BALLMYBLOVED, 3:54.23, 5, '           '"  # discord: 175372497720573953
    lb[2] = "COLDSKIN, 4:05.81, 2, '                     '"  # discord: 480749915203567617
    lb[3] = "JAKOBONEDGE, 4:21.96, 12, '         '"  # discord: 390556082256478212
    lb[4] = "BACKLINEREIN, 4:34.15, 15, '           '"  # discord: 206866465025032193
    lb[5] = "DVD, 5:02.50, 15, '                            '"  # discord: 140532832748568576
    lb[6] = "GAMINGCHAIR, 5:08.37, 16, '         '"  # discord: 585552694819815452
    lb[7] = "BLOWSKI, 5:40.50, 24, '                    '"  # discord: 486101644732399636
    lb[8] = "安宁, 5:51.20, 40, '                           '"  # discord: 1332978961659068439
    lb[9] = "KINGO, 6:26.18, 37, '                        '"  # discord: 231870424718245888
    lb[10] = "VANESSA, 6:59.56, 58, '                  '"  # discord: 297472760618418176


def loadRunInfo():
    @Name "Leaderboard Run Info"

    # lbRunInfo(rank, submission date (UTC, YYYY-MM-DD), video link without https://)
    lbRunInfo(1, "2026-06-02", "youtu.be/Rkz9kWNEiHM")
    lbRunInfo(2, "2026-08-26", "youtu.be/xDH0hywqCtc")
    lbRunInfo(3, "2026-06-11", "youtu.be/L3tIoo9Ue40")
    lbRunInfo(4, "2026-05-13", "youtu.be/SDw339nB_dw")
    lbRunInfo(5, "2026-05-07", "youtu.be/RXrrX5Sj_L0")
    lbRunInfo(6, "2026-05-07", "youtu.be/Ufn1zTb1Upo")
    lbRunInfo(7, "2026-06-13", "medal.tv/games/overwatch/clips/mTEZK5NUYrfkDFtcS")
    lbRunInfo(8, "2026-06-12", "medal.tv/games/overwatch/clips/mTG72hXv3vOdGEDPP")
    lbRunInfo(9, "2026-06-10", "youtu.be/OaXIV4kSh_k")
    lbRunInfo(10, "2026-09-30", "medal.tv/games/overwatch/clips/nDcPQeGIujXfUqe5G")
