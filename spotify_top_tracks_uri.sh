#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-20 10:50:37 +0100 (Mon, 20 Jul 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# https://developer.spotify.com/documentation/web-api/reference/library/get-users-saved-tracks/

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Returns the current Spotify user's Top Tracks in URI format via the Spotify API

$usage_auth_msg

Caveat: due to limitations of the Spotify API, this requires an interactively authorized access token, which you will be prompted for if you haven't already got one in your shell environment. To set up an authorized token for an hour in your current shell, you can run the following command (make sure you don't have an access token in the environment from spotify_api_token.sh otherwise you will get a 401 error):

$usage_token_private
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<curl_options>]"

help_usage "$@"

# defined in lib/spotify.sh
# shellcheck disable=SC2154
url_path="/v1/me/top/tracks?offset=$offset&limit=$limit"

output(){
    jq -r '.items[] | .uri' <<< "$output"
}

export SPOTIFY_PRIVATE=1

spotify_token

while not_null "$url_path"; do
    output="$("$srcdir/spotify_api.sh" "$url_path" "$@")"
    die_if_error_field "$output"
    url_path="$(get_next "$output")"
    output
done