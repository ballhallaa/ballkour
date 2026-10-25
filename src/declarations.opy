# Settings
globalvar settings_

# Leaderboard
globalvar lb
globalvar lbPos
globalvar lbObj
globalvar lbObjFormatted
globalvar timeToBeatInMs

# Checkpoints
globalvar cps
globalvar cpDefaults

# Hints
globalvar hintRoutes
globalvar hintTimes
globalvar hintActions
globalvar hintAnchors
globalvar hintColors

# Lobby
globalvar lobbyData
globalvar lobbyStats

# Match
globalvar elapsedTime
globalvar elapsedTimeFormatted
globalvar ddBots
globalvar dd

# Players
globalvar players
globalvar hostPlayerName
globalvar nameplateObjs
globalvar tinyNameplateObjs

# Spectating
globalvar playerToEnableFreecam

globalvar index 127

# Player
playervar isLoading
playervar isInLobby
playervar nameplate
playervar isTiny

# Run
playervar isRunLoaded
playervar isRunLegit
playervar isRunPaused
playervar isRunFinished
playervar isTimerActive
playervar runCurrentCp
playervar runTime
playervar runTimeFormatted
playervar runMistakes
playervar runFinalTimeFormatted
playervar runFinalMistakes
playervar isViewingRunCompletionText

# Checkpoints
playervar cpData
playervar isCpTimerActive
playervar cpStartTime
playervar cpTime
playervar cpTimeFormatted
playervar cpTotalTimeFormatted

# Hint Playback
playervar isHintOn
playervar isHintPlaying
playervar isViewingHintInfo
playervar hintCp
playervar hintPlayCp
playervar hintIndex
playervar hintStep
playervar hintTime
playervar hintPos
playervar hintS
playervar hintSpline
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
playervar isInFreemode

# Spectating
playervar spectating
playervar firstPersonSpectatingTime

playervar index 127

# Lobby
subroutine loadLobby

# Run
subroutine newRun
subroutine updateStats

# Checkpoints
subroutine loadCpData
subroutine setCpAbilities
subroutine cpResetPlayer

# Hints
subroutine saveHintRoute

# Time Formatting
subroutine formatTime

# Spectating
subroutine enableSpectator
subroutine disableSpectator
subroutine enableFreecam
subroutine enableFreecamForSpectators
subroutine reattachToSpectatingTarget
subroutine enableFirstPersonSpectator
