# Settings
globalvar settings_
# Debug, Server Load, Lobby Stats and the Hint Recorder only exist in dev builds (a VERSION ending in -dev), so release builds don't spend elements on them
macro DEV = strContains(VERSION, "-dev")
macro isDebugOn = DEV and settings_[0]
macro isServerLoadOn = DEV and settings_[3]
macro isLobbyStatsOn = DEV and settings_[1]
macro isHintRecorderOn = DEV and settings_[2]
# A VERSION ending in +all-ctrls (e.g. 2026.11.02-beta.1-dev+all-ctrls) shows every Controls
# line on screen at once, for checking their padding, with no Workshop Setting to wait on
macro ALL_CONTROLS = strContains(VERSION, "+all-ctrls")

# Leaderboard
globalvar lb
globalvar lbPos
globalvar lbObj
globalvar lbObjFormatted
globalvar lbRunCount
globalvar lbRunText
globalvar lbRunPad
globalvar lbRunViewers
globalvar timeToBeat
globalvar timeToBeatFormatted

# Checkpoints
globalvar cps
# -1 until Checkpoint: Expand Data sets it, so nobody counts as being on the final checkpoint
globalvar lastCp = -1
globalvar cpDefaults
# Orbs past each checkpoint line's own, as pairs: vect(checkpoint, 0, 0), then the orb
globalvar cpExtraOrbs
globalvar cpOrbScratch

# Hints
globalvar hintData
globalvar hintScratch
globalvar hintDecodeIndex
globalvar hintRoutes
globalvar hintTimes
globalvar hintActions
globalvar hintAnchors
globalvar hintColors

# Lobby
globalvar lobbyCam
globalvar langPos
globalvar langNames
globalvar lobbyAngle
globalvar lobbyPos
globalvar lobbyStats

# Match
globalvar elapsedTime
globalvar elapsedTimeFormatted
globalvar dedBots = []
globalvar ded
globalvar serverLoadAvg

# Players
globalvar players
globalvar hostPlayerName
globalvar nameplateObjs
globalvar tinyNameplateObjs
globalvar scorecard
globalvar scorecardRows
globalvar scorecardDirty
globalvar scorecardPlayers
globalvar scorecardRow
globalvar scorecardTime
globalvar topRuns = []
globalvar topRunsScratch
globalvar topRunsText
globalvar allTimeRunsText

# Spectating
globalvar playerToEnableFreecam
globalvar freecamStartPos
globalvar freecamQueue = []

# Translated HUD Text
# Each HUD text's translations are stored here once and shown with _(), instead of written into the HUD text.
# Overwatch reprocesses every HUD text's definition every 5s, and a translated string puts every language
# into it, which took that spike from ~66% to ~90% server load. A stored string can't have {} placeholders,
# so its arguments are @0, @1... markers, filled in with .replace("@0", value) where it's shown.
globalvar ctrlsHudText = []
globalvar freemodeHudText
globalvar hintsHudText = []
globalvar runHudText
globalvar counterHudText = []
globalvar splitsHudText = []
globalvar spectatorHudText = []
globalvar completionHudText = []
globalvar scorecardHudText = []
globalvar topRunsHudText
globalvar allTimeRunsHudText
globalvar lobbyHudText = []
globalvar faqHudText = []

globalvar index 127

# Player
playervar isLoading
playervar isInLobby
playervar nameplate
playervar isTiny

# Lobby
# The page they're on: 1 for the buttons and leaderboard, 2 for Lobby Stats, or 0 outside
# the lobby
playervar lobbyPage
playervar lobbyAim

# Leaderboard
playervar lbInfoRow

# Run
playervar isRunLoaded
playervar isRunLegit
playervar isRunPaused
playervar isRunFinished
playervar isTimerActive
playervar runCurrentCp
# The furthest CP cleared this run, which can be skipped back to without losing legitimacy
playervar runFurthestCp
playervar runTime
playervar runTimeFormatted
playervar runMistakes
playervar runFinalTimeFormatted
playervar runFinalMistakes
playervar runCount
playervar isViewingRunCompletionText
playervar viewRunner

# Checkpoints
playervar cpData
playervar isCpTimerActive
playervar cpTime
playervar cpTimeFormatted
playervar cpStartMistakes
playervar cpAttempts
playervar cpMistakes
playervar viewCp

# Splits
playervar splitStart
playervar splitTime
playervar splitTimeFormatted
playervar splitBests
playervar splitTotals
playervar splitClears
playervar splitStatsFormatted
playervar splitDelta
playervar isShowingSplitDelta
playervar splitCpBest
playervar attemptBests
playervar attemptTotals
playervar attemptCpBest
playervar splitDiff
playervar splitResult

# Pace
playervar paceEta
playervar paceEtaFormatted
playervar paceSplit
playervar paceSplitTotal
playervar paceSplitClears

# Hint Playback
playervar isHintOn
playervar isHintAutoOn
playervar isHintAutoOff
playervar isHintPlaying
playervar hintPlayCp
playervar hintKeyframes
playervar hintKeyframeTimes
playervar hintIndex
playervar hintStep
playervar hintTime
playervar hintPos
playervar hintS
playervar hintSpline
playervar hintColor
playervar hintAnchor

# Hint Recording
playervar hintRecording
playervar hintRecordCp
playervar hintRecordStart
playervar hintRecordLast
playervar hintRecordTimes
playervar hintRecordActions
playervar hintActionStarts
playervar hintRecordAnchors
playervar hintGrappleAnchor

# Time Formatting
playervar timeToFormat
playervar timeFormatted

# Controls
playervar isViewingCtrlsHud
# The FAQ page being read (1 to FAQ_PAGES), or 0 while it's closed
playervar faqPage
# FAQ: Open turns the pages, so they're counted here
macro FAQ_PAGES = 4
# The languages in #!translations (ballkour.opy), which __languageIndex__ counts from 0
macro LANGUAGES = 14
playervar isInFreemode
playervar isScorecardHidden
playervar scorecardKey
playervar scorecardSecond
# Ultimate Input / Watch Input: the buttons held (heldButtons) and the ones before, and
# whether that combination's input already ran, so holding it doesn't run it again
playervar ultInputKey
playervar ultInputLastKey
playervar ultInputDone
playervar watchInputKey
playervar watchInputLastKey
playervar watchInputDone

# Spectating
playervar spectating
playervar firstPersonSpectatingTime
playervar spectateTargets
playervar heroSwapTime
playervar swapCooldownLeft

playervar index 127

# Player
subroutine showCpNameplate

# Lobby
subroutine loadLobby
subroutine leaveLobby
subroutine showRunInfo
# Each course's leaderboard has its own, if it has runs
subroutine loadRunInfo

# Run
subroutine newRun
subroutine resetRun
subroutine updateStats
subroutine pauseRun

# Checkpoints
subroutine loadCpData
subroutine setCpAbilities
subroutine cpResetPlayer
subroutine faceNextCp

# Splits
subroutine recordSplit
subroutine recordTopRun
subroutine formatSplitResult

# Pace
subroutine loadPace

# Hints
subroutine decompressScratch
subroutine saveHintRoute
subroutine resetCpMistakes

# Time Formatting
subroutine formatTime

# Controls
subroutine prevCpInput
subroutine nextCpInput
subroutine newRunInput
subroutine freemodeInput
subroutine lobbyInput

# Spectating
subroutine prevPlayerInput
subroutine nextPlayerInput
subroutine crosshairPlayerInput
subroutine toggleSpectator
subroutine enableSpectator
subroutine disableSpectator
subroutine enableFreecam
subroutine swapToJetpackCat
subroutine swapToWreckingBall
subroutine enableFreecamForSpectators
subroutine syncSpectatorCps
subroutine reattachToSpectatingTarget
subroutine enableFirstPersonSpectator


# Whether the Controls list shows: while Ultimate is held (Controls: HUD Input), apart from
# in the lobby, where its controls are buttons
macro isViewingCtrlsList(player):
    (player.isViewingCtrlsHud and not player.isInLobby)


# Who a control's text shows for: who it normally does, or with ALL_CONTROLS, everyone,
# whatever they're doing, apart from in the FAQ
macro controlsVisible(normally):
    (localPlayer.faqPage == 0 if ALL_CONTROLS else (normally))


# Whether a control picks the text that names its keys. Builds without ALL_CONTROLS compile
# it to just the check.
macro allControlsOr(check):
    (true if ALL_CONTROLS else (check))


# Run
# Every mistake also ends an attempt at the CP
macro addMistake():
    eventPlayer.runMistakes++
    eventPlayer.cpAttempts[eventPlayer.runCurrentCp]++
    eventPlayer.cpMistakes[eventPlayer.runCurrentCp]++


# Leaderboard
# A run's submission date and video link, for the players who opened it from its row
# (Lobby: Select Input). The course leaderboards use it, so it's defined here.
# Only open runs get their text, as every text's definition adds to the server's load.
# Workshop text is uppercase and video links aren't, so this overlays progress bar texts,
# which can show lowercase. They only line up in the Latin font, and one CJK character
# changes a text's whole font, so the row with the runner's name is its own text (Show Run
# Info), like the close line.
# It follows the player's camera: the blank lines (lbRunPad) lift it toward the top of the
# screen and push its progress bar off the screen. Each run's 3 texts are separate actions,
# as only literal text is lowercased, so everything they share is kept short: the blank
# lines are stored. Texts are remade whenever a run is opened or closed, which reaches the
# player after their open run has already changed, so each viewer's open run is checked
# again: the last run's date and link would show under the new row until then.
macro lbRunInfo(rank, date, link):
    lbRunViewers = getAllPlayers().filter(
        lambda localPlayer: localPlayer.lbInfoRow == rank
    )
    if len(lbRunViewers) > 0:
        createCasedProgressBarIwt(
            3,
            getAllPlayers().filter(lambda localPlayer: localPlayer.lbInfoRow == rank),
            "{}{}\n<fgFFFFFFFF>{}</fg>\n<fgFFFFFFFF>{}</fg>{}".format(
                lbRunPad[0], lbRunPad[4], date, link, lbRunPad[1]
            ),
            updateEveryFrame(
                localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 10
            ),
            1,
            Clip.NONE,
            rgb(230, 151, 0),
            ProgressWorldTextReeval.VISIBILITY_AND_POSITION
        )
