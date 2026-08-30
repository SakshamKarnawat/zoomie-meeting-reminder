#!/usr/bin/env bash
# One script for Zoomie semver.
#   scripts/semver.sh          print next X.Y.Z from tags + commits
#   scripts/semver.sh build V  print numeric CURRENT_PROJECT_VERSION
#   scripts/semver.sh test     run self-checks
#
# feat → minor, type! / BREAKING CHANGE: → major, everything else → patch.
set -euo pipefail

semver_normalize() {
    local raw="${1#v}"
    if [[ "$raw" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        echo "$raw"
        return
    fi
    if [[ "$raw" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.0"
        return
    fi
    if [[ "$raw" =~ ^([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}.0.0"
        return
    fi
    echo "1.0.0"
}

semver_kind() {
    local text="$1"
    local kind="patch"
    local line lower
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ (^|.*[[:space:]])BREAKING[[:space:]]CHANGE: ]]; then
            echo "major"
            return
        fi
        lower="$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')"
        if [[ "$lower" =~ ^[a-z]+(\([a-z0-9._-]+\))?!: ]]; then
            echo "major"
            return
        fi
        if [[ "$lower" =~ ^feat(\([a-z0-9._-]+\))?: ]]; then
            kind="minor"
        fi
    done <<< "$text"
    echo "$kind"
}

semver_bump() {
    local current kind major minor patch
    current="$(semver_normalize "$1")"
    kind="${2:-patch}"
    IFS=. read -r major minor patch <<< "$current"
    case "$kind" in
        major) major=$((major + 1)); minor=0; patch=0 ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        *) patch=$((patch + 1)) ;;
    esac
    echo "${major}.${minor}.${patch}"
}

semver_build_number() {
    local current major minor patch
    current="$(semver_normalize "$1")"
    IFS=. read -r major minor patch <<< "$current"
    echo $((major * 10000 + minor * 100 + patch))
}

semver_next() {
    if git describe --tags --exact-match --match 'v[0-9]*' HEAD >/dev/null 2>&1; then
        semver_normalize "$(git describe --tags --exact-match --match 'v[0-9]*' HEAD)"
        return
    fi

    local last_tag current="1.0.0" range="" before log kind
    last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)"
    if [[ -n "$last_tag" ]]; then
        current="$(semver_normalize "$last_tag")"
        range="${last_tag}..HEAD"
    else
        before="${BEFORE_SHA:-}"
        if [[ -n "$before" && "$before" != "0000000000000000000000000000000000000000" ]] \
            && git cat-file -e "${before}^{commit}" 2>/dev/null; then
            range="${before}..HEAD"
        fi
    fi

    if [[ -n "$range" ]]; then
        log="$(git log --format='%s%n%b' "$range")"
    else
        log=""
    fi
    kind="$(semver_kind "$log")"
    semver_bump "$current" "$kind"
}

semver_test() {
    local fail=0
    assert_eq() {
        local got="$1" want="$2" name="$3"
        if [[ "$got" != "$want" ]]; then
            echo "FAIL $name: got '$got' want '$want'" >&2
            fail=1
        fi
    }

    assert_eq "$(semver_normalize "v1.2.3")" "1.2.3" "strip v"
    assert_eq "$(semver_normalize "1.0")" "1.0.0" "pad patch"
    assert_eq "$(semver_normalize "2")" "2.0.0" "pad minor.patch"
    assert_eq "$(semver_normalize "nope")" "1.0.0" "fallback"

    assert_eq "$(semver_kind $'fix: broken banner\n')" "patch" "fix is patch"
    assert_eq "$(semver_kind $'feat: new character\n')" "minor" "feat is minor"
    assert_eq "$(semver_kind $'Feat: New character\n')" "minor" "feat is case-insensitive"
    assert_eq "$(semver_kind $'feat(banner): glow\n')" "minor" "feat scope is minor"
    assert_eq "$(semver_kind $'docs: readme\n')" "patch" "docs still patch"
    assert_eq "$(semver_kind $'first commit\n')" "patch" "unprefixed is patch"
    assert_eq "$(semver_kind $'feat: one\nfix: two\n')" "minor" "feat wins over fix"
    assert_eq "$(semver_kind $'feat!: drop ventura\n')" "major" "bang is major"
    assert_eq "$(semver_kind $'fix: x\n\nBREAKING CHANGE: gone\n')" "major" "footer is major"
    assert_eq "$(semver_kind "")" "patch" "empty is patch"

    assert_eq "$(semver_bump "1.0.0" "patch")" "1.0.1" "patch bump"
    assert_eq "$(semver_bump "1.0.7" "minor")" "1.1.0" "minor resets patch"
    assert_eq "$(semver_bump "1.4.9" "major")" "2.0.0" "major resets"
    assert_eq "$(semver_bump "1.0" "patch")" "1.0.1" "normalize then bump"
    assert_eq "$(semver_build_number "1.2.3")" "10203" "build number"
    assert_eq "$(semver_build_number "2.0.0")" "20000" "major build number"

    if [[ "$fail" -ne 0 ]]; then
        echo "semver tests failed" >&2
        exit 1
    fi
    echo "semver tests passed"
}

case "${1:-next}" in
    next) semver_next ;;
    build)
        if [[ -z "${2:-}" ]]; then
            echo "usage: $0 build X.Y.Z" >&2
            exit 1
        fi
        semver_build_number "$2"
        ;;
    test) semver_test ;;
    *)
        echo "usage: $0 [next|build X.Y.Z|test]" >&2
        exit 1
        ;;
esac
