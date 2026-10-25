rule "Settings":
    # Release builds have no Workshop Settings: see DEV in declarations.opy
    if DEV:
        settings_ = []
        settings_[0] = createWorkshopSettingBool("Settings", "Debug", false, 1)
        settings_[1] = createWorkshopSettingBool("Settings", "Lobby Stats", false, 0)
        settings_[2] = createWorkshopSettingBool("Settings", "Hint Recorder", false, 2)
