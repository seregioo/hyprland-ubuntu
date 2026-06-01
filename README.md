# Hyprland for Ubuntu 24.04.4 LTS

Set of scripts that clone, build and install as packages _Hyprland_ and its dependencies for **Ubuntu 24.04.4 LTS**.

## Usage

```bash
./build-all.sh
```

### Updating to latest versions

```bash
./build-all.sh --update
```

This fetches the latest release tags from all repos, re-clones and rebuilds everything with the newest versions.

At the end of the script you will be asked if you want some extras, you can omit them if you have other preferences :).
