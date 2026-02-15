# Release Process

This project uses GitHub Actions to automate the release process.

## How to Create a Release

1. Go to the **Actions** tab in your GitHub repository
2. Select the **Release Addon** workflow from the left sidebar
3. Click **Run workflow** button
4. Select the version bump type:
   - **patch**: Bug fixes and minor changes (e.g., 1.0.0 → 1.0.1)
   - **minor**: New features, backwards compatible (e.g., 1.0.0 → 1.1.0)
   - **major**: Breaking changes (e.g., 1.0.0 → 2.0.0)
5. Or enter a custom version number (e.g., "2.5.3")
6. Click **Run workflow**

## What Happens During Release

The workflow automatically:

1. ✅ Calculates the new version number based on SemVer
2. ✅ Updates version in all code files:
   - All Lua file headers (`@version`)
   - `Core/Defaults.lua` database version
   - `.toc` file (via `@project-version@` replacement)
3. ✅ Commits version changes to main branch
4. ✅ Creates a git tag (e.g., `v1.0.1`)
5. ✅ Generates a changelog from git commits
6. ✅ Packages the addon as a ZIP file
7. ✅ Creates a GitHub Release with the ZIP attached
8. ✅ Uploads the addon to CurseForge automatically

## Prerequisites

- **GitHub Secret**: The workflow uses the built-in `GITHUB_TOKEN` (automatically provided)
- **CurseForge Secret**: Add your CurseForge API key as a secret named `WOW_ADDON_PUBLISH_KEY`
  - Go to Repository Settings → Secrets and variables → Actions
  - Create a new repository secret with the name `WOW_ADDON_PUBLISH_KEY`
  - Paste your CurseForge API token

## Version Tracking

The addon version is maintained in multiple files:

- `BetterAuras.toc`: `## Version: @project-version@` (replaced during packaging)
- `Core/Defaults.lua`: `version = "x.x.x"` (database version)
- All `.lua` files: `@version x.x.x` (file header documentation)

The workflow automatically keeps all these in sync.

## Changelog Generation

The changelog is automatically generated from git commit messages between releases.
To make meaningful changelogs, use descriptive commit messages:

- `feat: add new feature description`
- `fix: resolve issue with X`
- `chore: update dependencies`

## Troubleshooting

**Release fails during packaging:**

- Verify `WOW_ADDON_PUBLISH_KEY` secret is set correctly
- Check that the CurseForge project exists and API key has upload permissions

**Version conflicts:**

- The workflow uses the latest git tag to determine the current version
- If no tags exist, it starts from `1.0.0`
- Manual tags should follow the `vX.Y.Z` format (e.g., `v1.0.0`)

**CurseForge upload fails:**

- Ensure your CurseForge project allows API uploads
- Verify the API key hasn't expired
- Check CurseForge project settings for any restrictions
