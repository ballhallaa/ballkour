# Leaderboard data

The leaderboards' data, kept on its own branch so the commits for every run stay off `develop`:

- `leaderboards/runs.json`: the runs sent from [ballkour.com](https://ballkour.com), saved by the website as they come in, and the runs taken off the boards (`"removed"`).
- `leaderboards/history.json`: every board the leaderboard bot has posted to Discord, saved by the bot after each post.

The courses' own files stay on `develop`, in `leaderboards/`. A push here that changes `runs.json` posts the new boards (`.github/workflows/leaderboard-data.yml`). To take a run off, move it from `"runs"` to `"removed"` in `runs.json` and commit it here.
