#!/usr/bin/env bash
csplit --suppress-matched --elide-empty-files "$1" '/^From - /' '{*}'
