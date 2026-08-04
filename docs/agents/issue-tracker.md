# Issue Tracker

**Type:** GitHub Issues  
**CLI:** `gh` (GitHub CLI)

## Creating issues

```bash
gh issue create --title "<title>" --body "<body>"
```

## Listing issues

```bash
gh issue list
```

## Reading an issue

```bash
gh issue view <number>
```

## Closing an issue

```bash
gh issue close <number>
```

## Notes

- PRs as a request surface: **off** (flip to `on` here if you want open PRs included in the triage queue)
- If the repo hasn't been pushed to GitHub yet, create the remote first: `gh repo create`
