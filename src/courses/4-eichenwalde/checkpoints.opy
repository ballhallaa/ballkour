#!mainFile "4-eichenwalde.opy"

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
            vect(87.70, 12.64, -69.13), vect(0, 0, 1), vect(0, 0, 0),
            vect(94.13, 12.69, -72.70), vect(0, 1, 1), vect(0, 0, 0),
            vect(76.31, 12.66, -66.66), vect(1, 0, 1), vect(0, 0, 0),
            vect(97.75, 16.82, -74.42), vect(0, 0, 1), vect(0, 0, 0),
            vect(101.37, 9.59, -93.04), vect(1, 1, 1), vect(0, 0, 0),
            vect(81.37, 12.71, -98.83), vect(0, 1, 1), vect(0, 0, 0),
            vect(64.25, 17.86, -105.81), vect(1, 0, 1), vect(0, 0, 0),
            vect(35.59, 10.37, -95.91), vect(1, 0, 1), vect(0, 0, 0),
            vect(22.53, 11.00, -72.41), vect(0, 0, 1), vect(0, 0, 0),
            vect(13.49, 11.01, -82.08), vect(1, 1, 1), vect(0, 0, 0),
            vect(-5.39, 1.75, -23.91), vect(1, 0, 1), vect(0, 0, 0),
            vect(-32.37, -0.24, -23.49), vect(1, 0, 1), vect(0, 0, 0),
            vect(-1.85, 5.00, -14.63), vect(1, 1, 1), vect(0, 0, 0),
            vect(-29.44, -2.00, -9.30), vect(1, 0, 1), vect(0, 0, 0),
            vect(2.07, 6.00, 1.16), vect(1, 1, 1), vect(0, 0, 0),
            vect(29.46, 1.64, -9.42), vect(1, 1, 1), vect(0, 0, 0),
            vect(43.83, 5.38, -59.13), vect(1, 0, 1), vect(0, 0, 0),
            vect(32.47, 13.74, -85.73), vect(0, 0, 1), vect(0, 0, 0),
            vect(47.36, 6.13, -73.25), vect(1, 0, 1), vect(0, 0, 0),
            vect(60.86, 11.72, -62.92), vect(0, 0, 1), vect(0, 0, 0),
            vect(63.50, 15.76, -60.10), vect(1, 0, 1), vect(0, 0, 0),
            vect(84.57, 12.71, -93.18), vect(0, 0, 1), vect(0, 0, 0),
            vect(102.14, 10.32, -87.59), vect(1, 0, 1), vect(0, 0, 0),
            vect(67.77, 4.79, -83.72), vect(0, 0, 1), vect(0, 0, 0),
            vect(63.77, 16.41, -83.65), vect(0, 0, 1), vect(0, 0, 0),
            vect(77.71, 13.01, -85.23), vect(0, 0, 1), vect(0, 0, 0),
            vect(87.19, 12.67, -75.60), vect(1, 1, 1), vect(77.91, 14.85, -71.14),
            vect(62.67, 14.69, -61.80), vect(0, 0, 1), vect(0, 0, 0),
            vect(45.80, 5.48, -64.30), vect(1, 0, 1), vect(42.07, 7.83, -78.30),
            vect(30.04, 14.00, -81.71), vect(0, 0, 1), vect(0, 0, 0),
            vect(13.34, 11.01, -83.78), vect(0, 0, 1), vect(0, 0, 0),
            vect(-3.89, 3.50, -81.01), vect(1, 0, 1), vect(0, 0, 0),
            vect(-9.01, 3.00, -69.37), vect(0, 0, 1), vect(0, 0, 0),
            vect(-5.23, 6.00, -67.60), vect(1, 1, 1), vect(0, 0, 0),
            vect(29.90, 14.00, -84.03), vect(1, 0, 1), vect(33.68, 16.29, -76.11),
            vect(51.66, 18.17, -76.52), vect(0, 1, 1), vect(0, 0, 0),
            vect(52.09, 21.00, -67.04), vect(1, 0, 1), vect(0, 0, 0),
            vect(65.36, 11.96, -93.51), vect(0, 0, 1), vect(0, 0, 0),
            vect(62.13, 18.72, -92.45), vect(1, 1, 1), vect(0, 0, 0),
            vect(43.21, 5.33, -53.56), vect(1, 1, 1), vect(0, 0, 0),
            vect(18.62, 4.00, -29.69), vect(0, 0, 1), vect(0, 0, 0),
            vect(16.68, 9.82, -38.98), vect(1, 1, 1), vect(0, 0, 0),
            vect(16.88, 4.72, -44.75), vect(0, 0, 1), vect(0, 0, 0),
            vect(16.44, 9.82, -38.65), vect(0, 0, 0), vect(0, 0, 0),
            vect(86.31, 14.47, -63.79), vect(1, 0, 1), vect(0, 0, 0),
            vect(75.93, 12.66, -66.21), vect(1, 0, 1), vect(0, 0, 0),
            vect(89.96, 12.93, -60.32), vect(1, 1, 1), vect(0, 0, 0),
            vect(129.30, 14.74, -35.09), vect(0, 0, 1), vect(0, 0, 0),
            vect(113.66, 8.72, -31.04), vect(0, 0, 1), vect(0, 0, 0),
            vect(115.15, 14.72, -30.36), vect(0, 0, 1), vect(0, 0, 0),
            vect(125.04, 14.73, -19.12), vect(1, 1, 1), vect(0, 0, 0),
            vect(89.20, 12.72, -38.00), vect(0, 0, 1), vect(0, 0, 0),
            vect(82.94, 15.72, -36.11), vect(1, 1, 1), vect(0, 0, 0),
            vect(124.02, 8.72, -39.99), vect(0, 0, 1), vect(0, 0, 0),
            vect(128.96, 14.74, -38.09), vect(0, 0, 1), vect(0, 0, 0),
            vect(118.77, 18.86, -44.53), vect(1, 1, 1), vect(0, 0, 0),
            vect(91.81, 14.23, -65.09), vect(0, 0, 1), vect(0, 0, 0),
            vect(93.73, 18.68, -67.59), vect(1, 1, 1), vect(0, 0, 0),
            vect(42.32, 6.16, -75.19), vect(1, 0, 1), vect(40.34, 8.64, -83.52),
            vect(47.43, 11.73, -99.82), vect(0, 0, 1), vect(0, 0, 0),
            vect(52.21, 17.72, -103.49), vect(0, 0, 1), vect(0, 0, 0),
            vect(56.16, 23.32, -104.00), vect(0, 0, 1), vect(0, 0, 0),
            vect(76.84, 10.69, -108.45), vect(1, 0, 1), vect(73.36, 13.71, -101.13),
            vect(70.51, 14.33, -77.18), vect(0, 0, 1), vect(0, 0, 0),
            vect(64.49, 14.96, -78.81), vect(0, 0, 1), vect(0, 0, 0),
            vect(58.97, 18.05, -82.41), vect(0, 0, 1), vect(0, 0, 0),
            vect(36.94, 12.62, -81.75), vect(0, 0, 1), vect(0, 0, 0),
            vect(42.91, 5.13, -63.69), vect(1, 0, 1), vect(0, 0, 0),
            vect(8.91, 5.80, -65.90), vect(1, 1, 1), vect(0, 0, 0),
            vect(-12.27, 1.80, -25.34), vect(1, 1, 1), vect(0, 0, 0),
            vect(21.84, 0.90, -8.33), vect(1, 1, 1), vect(0, 0, 0),
            vect(-1.03, 7.66, -31.06), vect(1, 1, 1), vect(0, 0, 0),
            vect(25.41, 10.99, -72.19), vect(1, 1, 1), vect(0, 0, 0),
            vect(-8.86, 5.00, -55.85), vect(0, 0, 1), vect(0, 0, 0),
            vect(-0.66, 5.99, -63.85), vect(1, 1, 1), vect(9.59, 9.11, -73.94),
            vect(12.70, 11.01, -82.73), vect(0, 0, 1), vect(0, 0, 0),
            vect(21.52, 10.98, -72.95), vect(0, 0, 1), vect(0, 0, 0),
            vect(31.40, 14.00, -77.16), vect(0, 0, 1), vect(0, 0, 0),
            vect(25.78, 4.81, -60.59), vect(1, 0, 1), vect(20.76, 6.10, -65.04),
            vect(22.81, 6.08, -78.57), vect(1, 0, 1), vect(18.19, 6.85, -75.53),
            vect(21.80, 10.98, -72.99), vect(1, 1, 1), vect(0, 0, 0),
            vect(54.66, 8.89, -60.97), vect(0, 0, 1), vect(0, 0, 0),
            vect(56.95, 11.70, -61.30), vect(0, 0, 1), vect(0, 0, 0),
            vect(63.72, 15.76, -59.29), vect(1, 1, 1), vect(0, 0, 0),
            vect(53.24, 21.00, -65.55), vect(1, 1, 1), vect(0, 0, 0),
            vect(47.57, 6.30, -74.24), vect(1, 0, 1), vect(38.14, 9.34, -70.79),
            vect(36.48, 4.81, -63.99), vect(0, 0, 1), vect(0, 0, 0),
            vect(7.61, 5.04, -45.23), vect(0, 0, 1), vect(0, 0, 0),
            vect(10.20, 9.83, -42.16), vect(1, 1, 1), vect(0, 0, 0),
            vect(0.98, 5.83, -58.66), vect(0, 0, 1), vect(0, 0, 0),
            vect(46.53, 6.30, -75.27), vect(0, 0, 1), vect(0, 0, 0),
            vect(102.78, 12.68, -74.35), vect(0, 0, 1), vect(0, 0, 0),
            vect(91.59, 12.66, -73.93), vect(1, 1, 1), vect(86.50, 13.65, -74.01),
            vect(60.72, 18.72, -89.32), vect(0, 0, 1), vect(0, 0, 0),
            vect(51.66, 18.04, -82.23), vect(0, 0, 1), vect(0, 0, 0),
            vect(37.97, 12.62, -80.11), vect(0, 0, 1), vect(0, 0, 0),
            vect(33.94, 14.00, -77.17), vect(0, 0, 0), vect(0, 0, 0),
            vect(40.96, 8.39, -91.79), vect(0, 0, 1), vect(0, 0, 0),
            vect(33.29, 13.80, -85.81), vect(0, 1, 1), vect(34.73, 16.22, -83.40),
            vect(48.56, 11.72, -79.06), vect(0, 1, 1), vect(0, 0, 0),
            vect(52.27, 18.05, -76.34)
        ]
    )
    # More orbs, for checkpoints with several: the checkpoint's number, then the orb. All of a
    # checkpoint's orbs have to be grabbed, in any order.
    cpExtraOrbs = compress(
        [
            vect(26, 0, 0), vect(73.73, 20.80, -68.82),
            vect(28, 0, 0), vect(38.00, 10.82, -90.51),
            vect(58, 0, 0), vect(38.51, 11.98, -90.00),
            vect(62, 0, 0), vect(67.86, 15.37, -89.76),
            vect(78, 0, 0), vect(13.24, 8.07, -71.09),
            vect(79, 0, 0), vect(12.69, 8.00, -72.29),
            vect(85, 0, 0), vect(37.08, 15.10, -64.55),
            vect(92, 0, 0), vect(76.46, 14.93, -74.18)
        ]
    )
    # Sizes past cpDefaults: vect(checkpoint, cpSize, nextCpSize), 0 keeps the default
    cpSizes = [vect(2, 0, 3), vect(3, 3, 0), vect(48, 4.1, 0), vect(55, 3, 0), vect(66, 0, 1.75), vect(96, 2.25, 0)]
    # Landings away from a checkpoint, as pairs: vect(checkpoint, 0, 0), then where the jump to
    # it lands. Clearing it there teleports the player to the checkpoint.
    cpLandings = [
        vect(29, 0, 0), vect(33.27, 13.75, -85.64),
        vect(43, 0, 0), vect(16.40, 9.83, -42.09),
        vect(44, 0, 0), vect(20.12, 9.00, -25.03),
        vect(45, 0, 0), vect(82.95, 21.15, -64.41),
        vect(48, 0, 0), vect(114.13, 14.72, -31.08),
        vect(49, 0, 0), vect(114.93, 14.72, -31.01),
        vect(56, 0, 0), vect(89.05, 13.04, -64.65),
        vect(67, 0, 0), vect(42.88, 6.13, -62.35),
        vect(87, 0, 0), vect(34.56, 6.02, -71.06),
        vect(90, 0, 0), vect(7.45, 5.80, -65.04),
        vect(91, 0, 0), vect(48.30, 11.72, -79.63),
        vect(92, 0, 0), vect(102.22, 17.71, -71.93),
        vect(96, 0, 0), vect(34.10, 14.00, -79.23)
    ]
