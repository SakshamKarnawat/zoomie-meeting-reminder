#!/usr/bin/env bash
# One script for Zoomie semver + changelog.
#   scripts/semver.sh                print next X.Y.Z
#   scripts/semver.sh build V        numeric CURRENT_PROJECT_VERSION
#   scripts/semver.sh notes          markdown notes since last tag
#   scripts/semver.sh changelog V F  prepend V to changelog file F
#   scripts/semver.sh test           self-checks
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

semver_range() {
    if git describe --tags --exact-match --match 'v[0-9]*' HEAD >/dev/null 2>&1; then
        return
    fi
    local last_tag before
    last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)"
    if [[ -n "$last_tag" ]]; then
        echo "${last_tag}..HEAD"
        return
    fi
    before="${BEFORE_SHA:-}"
    if [[ -n "$before" && "$before" != "0000000000000000000000000000000000000000" ]] \
        && git cat-file -e "${before}^{commit}" 2>/dev/null; then
        echo "${before}..HEAD"
    fi
}

semver_commit_log() {
    local range
    range="$(semver_range)"
    if [[ -n "$range" ]]; then
        git log --format='%s%n%b' "$range"
    fi
}

semver_next() {
    if git describe --tags --exact-match --match 'v[0-9]*' HEAD >/dev/null 2>&1; then
        semver_normalize "$(git describe --tags --exact-match --match 'v[0-9]*' HEAD)"
        return
    fi

    local last_tag current="1.0.0" range log
    last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)"
    if [[ -n "$last_tag" ]]; then
        current="$(semver_normalize "$last_tag")"
    fi
    range="$(semver_range)"
    if [[ -n "$range" ]]; then
        log="$(git log --format='%s%n%b' "$range")"
    else
        log=""
    fi
    semver_bump "$current" "$(semver_kind "$log")"
}

semver_plain_subject() {
    local line="$1"
    if [[ "$line" =~ ^[A-Za-z]+(\([A-Za-z0-9._-]+\))?!:[[:space:]]+(.*)$ ]]; then
        echo "${BASH_REMATCH[2]}"
        return
    fi
    if [[ "$line" =~ ^[A-Za-z]+(\([A-Za-z0-9._-]+\))?:[[:space:]]+(.*)$ ]]; then
        echo "${BASH_REMATCH[2]}"
        return
    fi
    echo "$line"
}

semver_is_conventional() {
    local lower="$1"
    [[ "$lower" =~ ^[a-z]+(\([a-z0-9._-]+\))?!: ]] \
        || [[ "$lower" =~ ^[a-z]+(\([a-z0-9._-]+\))?: ]]
}

semver_format_notes() {
    local log="$1"
    local features="" fixes="" others="" line lower text
    local feat_subject="" feat_bullets="" last=""

    flush_feat() {
        if [[ -n "$feat_bullets" ]]; then
            features+="$feat_bullets"
        elif [[ -n "$feat_subject" ]]; then
            features+="- ${feat_subject}"$'\n'
        fi
        feat_subject=""
        feat_bullets=""
        last=""
    }

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        lower="$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')"
        if [[ "$lower" =~ ^chore\(release\): ]] || [[ "$lower" =~ ^breaking[[:space:]]change: ]]; then
            continue
        fi
        if [[ "$line" =~ ^-[[:space:]]+ ]]; then
            if [[ "$last" == "feat" ]]; then
                feat_bullets+="${line}"$'\n'
            elif [[ "$last" == "fix" ]]; then
                fixes+="${line}"$'\n'
            elif [[ "$last" == "other" ]]; then
                others+="${line}"$'\n'
            fi
            continue
        fi
        if ! semver_is_conventional "$lower"; then
            continue
        fi
        text="$(semver_plain_subject "$line")"
        if [[ "$lower" =~ ^feat(\([a-z0-9._-]+\))?!: ]] || [[ "$lower" =~ ^feat(\([a-z0-9._-]+\))?: ]]; then
            flush_feat
            feat_subject="$text"
            last="feat"
        elif [[ "$lower" =~ ^fix(\([a-z0-9._-]+\))?!: ]] || [[ "$lower" =~ ^fix(\([a-z0-9._-]+\))?: ]]; then
            flush_feat
            fixes+="- ${text}"$'\n'
            last="fix"
        else
            flush_feat
            others+="- ${text}"$'\n'
            last="other"
        fi
    done <<< "$log"
    flush_feat

    local out=""
    if [[ -n "$features" ]]; then
        out+="### Features"$'\n\n'"${features}"$'\n'
    fi
    if [[ -n "$fixes" ]]; then
        out+="### Fixes"$'\n\n'"${fixes}"$'\n'
    fi
    if [[ -n "$others" ]]; then
        out+="### Other"$'\n\n'"${others}"$'\n'
    fi
    if [[ -z "$out" ]]; then
        out="- Maintenance release."$'\n'
    fi
    printf '%s' "$out" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
    echo
}

semver_notes() {
    semver_format_notes "$(semver_commit_log)"
}

semver_changelog() {
    local version="$1"
    local file="${2:-CHANGELOG.md}"
    local date notes tmp
    if [[ -z "$version" ]]; then
        echo "usage: $0 changelog X.Y.Z [CHANGELOG.md]" >&2
        exit 1
    fi
    if [[ -f "$file" ]] && grep -qF "## [${version}]" "$file"; then
        return 0
    fi
    date="$(date -u +%Y-%m-%d)"
    notes="$(semver_notes)"
    tmp="$(mktemp)"
    {
        echo "# Changelog"
        echo
        echo "What changed in each Zoomie release. GitHub Releases use the same notes."
        echo
        echo "## [${version}] - ${date}"
        echo
        printf '%s\n' "$notes"
        if [[ -f "$file" ]]; then
            echo
            awk '/^## \[/{found=1} found{print}' "$file"
        fi
    } > "$tmp"
    mv "$tmp" "$file"
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

    assert_eq "$(semver_plain_subject "feat: version releases")" "version releases" "plain feat"
    assert_eq "$(semver_plain_subject "fix(banner): glow")" "glow" "plain scoped"
    assert_eq "$(semver_plain_subject "first commit")" "first commit" "plain raw"

    local notes
    notes="$(semver_format_notes $'feat: new banner\nfix: refocus settings\ndocs: readme\nchore(release): v1.0.1\n')"
    assert_eq "$(printf '%s' "$notes" | grep -c 'new banner')" "1" "notes has feat"
    assert_eq "$(printf '%s' "$notes" | grep -c 'refocus settings')" "1" "notes has fix"
    assert_eq "$(printf '%s' "$notes" | grep -c 'readme')" "1" "notes has other"
    assert_eq "$(printf '%s' "$notes" | grep -c 'chore(release)')" "0" "notes skips release chore"

    notes="$(semver_format_notes $'feat: umbrella\n\n- alpha\n- beta\n')"
    assert_eq "$(printf '%s' "$notes" | grep -c 'alpha')" "1" "notes uses feat body bullets"
    assert_eq "$(printf '%s' "$notes" | grep -c 'beta')" "1" "notes keeps each body bullet"
    assert_eq "$(printf '%s' "$notes" | grep -c 'umbrella')" "0" "notes drops umbrella when bullets exist"

    if [[ "$fail" -ne 0 ]]; then
        echo "semver tests failed" >&2
        exit 1
    fi
    echo "semver tests passed"
}

case "${1:-next}" in
    next) semver_next ;;
    notes) semver_notes ;;
    changelog)
        semver_changelog "${2:-}" "${3:-CHANGELOG.md}"
        ;;
    build)
        if [[ -z "${2:-}" ]]; then
            echo "usage: $0 build X.Y.Z" >&2
            exit 1
        fi
        semver_build_number "$2"
        ;;
    test) semver_test ;;
    *)
        echo "usage: $0 [next|notes|changelog X.Y.Z [file]|build X.Y.Z|test]" >&2
        exit 1
        ;;
esac
