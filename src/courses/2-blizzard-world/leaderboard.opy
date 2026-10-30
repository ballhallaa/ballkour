#!mainFile "2-blizzard-world.opy"

rule "Leaderboard":
    # lb[i]: [0]name [1]time [2]mistakes [3]alignmentSeparator
    lb = []
    lb[1] = "BALLMYBLOVED, 7:14.76, 16, '          '"


def loadRunInfo():
    @Name "Leaderboard Run Info"

    # lbRunInfo(rank, submission date (UTC, YYYY-MM-DD), video link without https://)
    lbRunInfo(1, "2026-06-05", "youtu.be/hNSpNvWyNcI")
