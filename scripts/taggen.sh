#!/bin/bash
# taggen.sh - Generate Docker image tags with mythology names
# Theme: Mjolnir - The Hammer of the Gods
# Usage: ./taggen.sh [-A|-D|--name|--version]

FIGURES=(
    # Norse
    thor odin freya loki heimdall baldur tyr fenrir valkyrie frigga
    # Greek
    zeus athena apollo artemis hermes poseidon hades ares hera
    # Roman
    jupiter mars venus neptune mercury minerva diana vulcan janus
    # Egyptian
    ra anubis isis osiris horus thoth bastet sekhmet sobek
    # Celtic
    dagda morrigan lugh brigid cernunnos nuada
    # Heroes & Titans
    prometheus atlas achilles perseus hercules theseus odysseus
    # Mythical Creatures
    phoenix griffin hydra kraken chimera pegasus cerberus
)

REALMS=(
    # Norse
    asgard midgard valhalla bifrost yggdrasil ragnarok jotunheim niflheim
    # Greek
    olympus tartarus elysium styx aegis delphi arcadia
    # Attributes
    thunder lightning storm forge fire wisdom valor glory
    immortal eternal divine sacred cosmic celestial ancient
    # Elements
    inferno tempest aurora eclipse zenith apex nova
)

# Get random element from array
random_element() {
    local arr=("$@")
    echo "${arr[$RANDOM % ${#arr[@]}]}"
}

# Generate random mythology name
generate_name() {
    local figure=$(random_element "${FIGURES[@]}")
    local realm=$(random_element "${REALMS[@]}")
    echo "${figure}-${realm}"
}

# Get Go version from argument or default
get_go_version() {
    if [[ -n "$GO_VERSION" ]]; then
        echo "$GO_VERSION"
    else
        echo "1.25"
    fi
}

# Main
FLAVOR=""
GO_VER=$(get_go_version)
RANDOM_NAME=$(generate_name)

for arg in "$@"; do
    case $arg in
        -A|--alpine)
            FLAVOR="A"
            ;;
        -D|--debian)
            FLAVOR="D"
            ;;
        --name)
            echo "$RANDOM_NAME"
            exit 0
            ;;
        --version)
            echo "$GO_VER"
            exit 0
            ;;
        -h|--help)
            echo "⚡ Mjolnir Tag Generator"
            echo ""
            echo "Usage: taggen.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  (no args)    Print full tag: <go-version>-<figure>-<realm>"
            echo "  -A, --alpine Print tag with Alpine suffix: <go-version>A-<figure>-<realm>"
            echo "  -D, --debian Print tag with Debian suffix: <go-version>D-<figure>-<realm>"
            echo "  --name       Print only mythology name (figure-realm)"
            echo "  --version    Print only Go version"
            echo ""
            echo "Environment:"
            echo "  GO_VERSION   Override Go version (default: 1.25)"
            echo ""
            echo "Examples:"
            echo "  taggen.sh           # 1.25-thor-asgard"
            echo "  taggen.sh -A        # 1.25A-zeus-olympus"
            echo "  taggen.sh -D        # 1.25D-odin-valhalla"
            exit 0
            ;;
    esac
done

echo "${GO_VER}${FLAVOR}-${RANDOM_NAME}"
