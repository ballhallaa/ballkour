#!mainFile "5-practice-range.opy"

rule "Checkpoints":
    # cpDefaults[i]: [0]cpSize [1]orbSize [2]nextCpSize
    cpDefaults = []
    cpDefaults[0] = 2.5
    cpDefaults[1] = 1
    cpDefaults[2] = 2.5
    # cps is one compressed vector array, which Expand Data unpacks. Each line is a checkpoint:
    # its location, vect(isGrappleAllowed, isShieldBounceAllowed, isPiledriverAllowed), and its
    # orb location, or vect(0, 0, 0) without an orb. Put it where the jump takes the player. The
    # final checkpoint only has its location.
    # Sizes come from cpDefaults. compress() keeps 2 decimals.
    cps = compress(
        [
            vect(53.34, 1.00, 34.30), vect(0, 0, 1), vect(0, 0, 0),
            vect(49.77, 1.00, 43.13), vect(0, 0, 1), vect(0, 0, 0),
            vect(51.75, 3.94, 45.92), vect(0, 0, 1), vect(0, 0, 0),
            vect(49.77, 1.00, 43.13), vect(0, 0, 1), vect(0, 0, 0),
            vect(46.78, 7.00, 45.14), vect(0, 0, 1), vect(0, 0, 0),
            vect(47.56, 7.00, 34.43), vect(0, 1, 1), vect(0, 0, 0),
            vect(57.72, 7.00, 47.94), vect(0, 1, 1), vect(0, 0, 0),
            vect(47.48, 7.00, 34.99), vect(1, 1, 1), vect(0, 0, 0),
            vect(48.17, 2.00, 14.55), vect(0, 0, 1), vect(0, 0, 0),
            vect(55.53, 5.00, 10.14), vect(1, 1, 1), vect(0, 0, 0),
            vect(31.56, 2.19, 4.79), vect(0, 0, 1), vect(0, 0, 0),
            vect(25.10, 0.50, -8.45), vect(0, 0, 1), vect(0, 0, 0),
            vect(33.64, -1.00, -23.92), vect(0, 0, 1), vect(0, 0, 0),
            vect(22.48, 0.08, -27.60), vect(0, 0, 1), vect(0, 0, 0),
            vect(12.77, 2.08, -14.65), vect(0, 0, 1), vect(0, 0, 0),
            vect(24.35, 0.50, -9.98), vect(0, 0, 1), vect(0, 0, 0),
            vect(19.54, 7.08, -8.48), vect(0, 0, 1), vect(0, 0, 0),
            vect(11.97, 2.08, -13.57), vect(0, 0, 1), vect(0, 0, 0),
            vect(10.92, 2.00, -4.96), vect(0, 0, 1), vect(0, 0, 0),
            vect(19.01, 2.40, 4.26), vect(0, 0, 1), vect(0, 0, 0),
            vect(18.67, 6.00, 10.75), vect(0, 0, 1), vect(0, 0, 0),
            vect(19.81, 8.82, 13.78), vect(0, 0, 0), vect(0, 0, 0),
            vect(15.98, 11.54, 12.46), vect(0, 0, 1), vect(0, 0, 0),
            vect(12.22, 14.34, 6.93), vect(1, 1, 1), vect(0, 0, 0),
            vect(86.10, -4.00, 38.16), vect(0, 0, 1), vect(0, 0, 0),
            vect(84.53, 2.26, 40.14), vect(0, 0, 1), vect(0, 0, 0),
            vect(72.69, 5.00, 38.12), vect(0, 0, 1), vect(0, 0, 0),
            vect(77.80, 8.00, 30.85), vect(0, 0, 1), vect(0, 0, 0),
            vect(92.17, -4.00, 24.33), vect(0, 0, 1), vect(0, 0, 0),
            vect(93.75, -0.73, 25.64), vect(1, 1, 1), vect(0, 0, 0),
            vect(84.76, 2.26, 39.88), vect(1, 1, 1), vect(0, 0, 0),
            vect(41.04, 11.00, 4.71), vect(0, 0, 1), vect(0, 0, 0),
            vect(31.82, 12.50, 17.04), vect(1, 1, 1), vect(0, 0, 0),
            vect(55.34, 7.28, -10.09), vect(0, 0, 1), vect(0, 0, 0),
            vect(73.55, -2.00, -9.65), vect(1, 1, 1), vect(0, 0, 0),
            vect(76.13, 7.24, 5.98), vect(0, 0, 1), vect(0, 0, 0),
            vect(71.11, 11.00, 17.93), vect(1, 1, 1), vect(0, 0, 0),
            vect(73.60, 1.20, -19.52), vect(1, 1, 1), vect(0, 0, 0),
            vect(39.90, -1.00, -26.37), vect(1, 1, 1), vect(0, 0, 0),
            vect(11.28, 2.00, -4.86), vect(0, 0, 1), vect(0, 0, 0),
            vect(8.60, 6.00, 5.39), vect(1, 1, 1), vect(0, 0, 0),
            vect(24.64, 12.50, 19.32), vect(1, 1, 1), vect(0, 0, 0),
            vect(55.79, 11.00, 8.61), vect(1, 1, 1), vect(0, 0, 0),
            vect(79.55, -4.00, 37.81), vect(0, 0, 1), vect(0, 0, 0),
            vect(85.30, -0.83, 26.32), vect(0, 0, 1), vect(0, 0, 0),
            vect(77.94, 2.26, 35.73), vect(0, 0, 1), vect(0, 0, 0),
            vect(68.74, 5.00, 29.52), vect(0, 0, 1), vect(0, 0, 0),
            vect(82.51, -4.00, 35.36), vect(1, 0, 1), vect(89.42, -3.00, 25.88),
            vect(96.34, -4.00, 22.18), vect(1, 1, 1), vect(92.58, -3.00, 19.89),
            vect(44.75, 11.00, 0.75), vect(0, 0, 1), vect(0, 0, 0),
            vect(50.70, 1.00, 20.46), vect(0, 1, 0), vect(0, 0, 0),
            vect(45.50, 1.00, 34.16), vect(1, 0, 1), vect(50.83, 2.00, 38.60),
            vect(57.59, 7.00, 46.45), vect(0, 1, 1), vect(0, 0, 0),
            vect(53.45, 1.00, 25.20), vect(0, 0, 1), vect(0, 0, 0),
            vect(65.08, 5.00, 29.89), vect(0, 0, 1), vect(0, 0, 0),
            vect(72.12, 11.00, 18.39), vect(1, 1, 1), vect(68.93, 12.00, 25.48),
            vect(76.13, 7.24, 7.12), vect(1, 1, 1), vect(0, 0, 0),
            vect(54.09, 7.47, -20.46), vect(0, 0, 1), vect(0, 0, 0),
            vect(42.58, 5.00, -4.67), vect(0, 0, 1), vect(0, 0, 0),
            vect(44.44, 11.00, -2.95), vect(1, 1, 1), vect(0, 0, 0),
            vect(22.13, 0.08, -28.10), vect(0, 0, 1), vect(0, 0, 0),
            vect(39.54, -1.00, -26.07), vect(0, 0, 1), vect(0, 0, 0),
            vect(45.51, -1.99, -11.02), vect(1, 1, 1), vect(0, 0, 0),
            vect(17.96, 6.00, 10.34), vect(0, 0, 1), vect(0, 0, 0),
            vect(16.12, 11.54, 12.28), vect(1, 1, 1), vect(0, 0, 0),
            vect(67.10, 11.00, 15.05), vect(1, 1, 1), vect(0, 0, 0),
            vect(53.59, 7.24, -9.26), vect(1, 1, 1), vect(0, 0, 0),
            vect(12.76, 2.08, -14.71), vect(0, 0, 0), vect(0, 0, 0),
            vect(26.57, 0.50, -13.98), vect(0, 0, 1), vect(0, 0, 0),
            vect(41.56, -1.80, -5.99), vect(1, 1, 1), vect(0, 0, 0),
            vect(37.17, 2.00, 8.16), vect(1, 1, 1), vect(0, 0, 0),
            vect(60.01, 11.00, 12.83), vect(0, 0, 0), vect(0, 0, 0),
            vect(43.61, 4.78, 25.44), vect(1, 1, 1), vect(0, 0, 0),
            vect(47.92, 7.24, -12.83), vect(1, 1, 1), vect(0, 0, 0),
            vect(84.70, 7.24, -17.27), vect(1, 1, 1), vect(0, 0, 0),
            vect(80.32, 8.00, 25.55), vect(0, 0, 1), vect(0, 0, 0),
            vect(73.31, 11.00, 21.12), vect(1, 1, 1), vect(66.57, 12.00, 15.50),
            vect(76.55, 7.45, 0.48), vect(1, 1, 1), vect(86.62, 9.39, -15.73),
            vect(66.76, 7.24, -28.90), vect(1, 0, 1), vect(59.43, 8.24, -19.45),
            vect(47.18, 11.00, -1.76), vect(0, 0, 1), vect(0, 0, 0),
            vect(34.00, 2.01, 11.80), vect(1, 1, 1), vect(0, 0, 0),
            vect(14.19, 6.00, 10.99), vect(0, 0, 1), vect(0, 0, 0),
            vect(19.50, 8.82, 14.30), vect(0, 0, 1), vect(0, 0, 0),
            vect(24.53, 6.00, 12.37), vect(0, 0, 1), vect(0, 0, 0),
            vect(55.30, 0.72, 19.12), vect(0, 0, 1), vect(0, 0, 0),
            vect(55.90, 5.00, 8.36), vect(0, 0, 1), vect(0, 0, 0),
            vect(57.93, 11.00, 8.52), vect(1, 1, 1), vect(0, 0, 0),
            vect(55.06, 5.00, 10.25), vect(1, 1, 1), vect(0, 0, 0),
            vect(50.39, 11.00, 11.63), vect(1, 1, 1), vect(0, 0, 0),
            vect(70.82, -2.00, 14.23), vect(1, 1, 1), vect(0, 0, 0),
            vect(68.95, 5.00, 16.52), vect(1, 1, 1), vect(63.58, 6.00, 12.46),
            vect(68.82, 6.50, -10.70), vect(1, 1, 1), vect(0, 0, 0),
            vect(85.15, -0.73, 26.28), vect(0, 0, 1), vect(94.76, -1.82, 24.11),
            vect(82.51, -4.00, 35.36), vect(1, 1, 1), vect(89.42, -3.00, 25.88),
            vect(90.58, -2.00, -4.63), vect(1, 0, 1), vect(85.93, -1.00, 5.17),
            vect(81.63, 8.00, 26.39), vect(0, 0, 1), vect(0, 0, 0),
            vect(79.89, 5.00, 43.57), vect(0, 0, 1), vect(0, 0, 0),
            vect(94.25, 7.44, 33.66), vect(0, 0, 1), vect(0, 0, 0),
            vect(81.47, 8.00, 25.83), vect(1, 1, 1), vect(0, 0, 0),
            vect(67.79, -2.00, 4.97), vect(1, 1, 1), vect(74.64, -1.00, 10.09),
            vect(99.79, 5.92, 26.96)
        ]
    )
    # More orbs, for checkpoints with several: the checkpoint's number, then the orb. All of a
    # checkpoint's orbs have to be grabbed, in any order.
    cpExtraOrbs = compress(
        [
            vect(47, 0, 0), vect(94.64, -1.89, 19.24),
            vect(48, 0, 0), vect(81.74, -0.37, 14.96),
            vect(51, 0, 0), vect(59.80, 3.15, 44.13),
            vect(55, 0, 0), vect(65.37, 12.75, 32.75),
            vect(76, 0, 0), vect(58.07, 12.00, 9.89),
            vect(76, 0, 0), vect(52.70, 13.62, 6.17),
            vect(77, 0, 0), vect(85.27, 8.28, -4.82),
            vect(78, 0, 0), vect(53.86, 8.79, -15.15),
            vect(90, 0, 0), vect(57.29, 6.29, 4.45),
            vect(93, 0, 0), vect(94.11, -1.89, 18.42),
            vect(94, 0, 0), vect(81.46, -0.20, 14.87),
            vect(99, 0, 0), vect(81.91, -0.25, 15.07)
        ]
    )
    # Sizes past cpDefaults: vect(checkpoint, cpSize, nextCpSize), 0 keeps the default
    cpSizes = [
        vect(1, 0, 0.8), vect(2, 0.8, 0), vect(5, 0, 5), vect(6, 5, 0),
        vect(20, 0, 2.25), vect(21, 2.25, 2.25), vect(22, 2.25, 1), vect(24, 0, 1),
        vect(25, 1, 0), vect(28, 0, 1.25), vect(29, 1.25, 1.25), vect(30, 1.25, 0),
        vect(43, 0, 1.5), vect(44, 1.5, 1.25), vect(45, 1.25, 0), vect(47, 0, 1),
        vect(63, 0, 2.25), vect(64, 2.25, 0), vect(78, 0, 5), vect(81, 0, 2.75),
        vect(82, 2.75, 0), vect(84, 0, 2.75), vect(85, 2.75, 0), vect(92, 0, 1)
    ]
    # Landings away from a checkpoint, as pairs: vect(checkpoint, 0, 0), then where the jump to
    # it lands. Clearing it there teleports the player to the checkpoint.
    cpLandings = [
        vect(18, 0, 0), vect(13.38, 7.08, -10.76),
        vect(19, 0, 0), vect(12.63, 6.00, 2.99),
        vect(48, 0, 0), vect(99.24, 0.29, 22.49),
        vect(49, 0, 0), vect(70.07, 5.00, 16.68),
        vect(55, 0, 0), vect(77.10, 8.00, 30.43),
        vect(58, 0, 0), vect(39.32, 5.00, -8.14),
        vect(72, 0, 0), vect(48.48, 1.00, 25.81),
        vect(79, 0, 0), vect(49.32, 11.00, -3.05),
        vect(84, 0, 0), vect(25.38, 12.50, 16.76),
        vect(93, 0, 0), vect(99.24, 0.29, 22.49),
        vect(95, 0, 0), vect(73.51, 5.00, 20.34)
    ]
