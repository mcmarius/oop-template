#!/usr/bin/bash

export REBASE_BRANCH="main"


# git branch -r |                     # lista toate branch-urile remote
#  grep 'origin/' |                   # pastrez doar branch-urile care incep cu origin/
#  grep -v "origin/HEAD" |            # exclud HEAD
#  grep -v "origin/$REBASE_BRANCH" |  # exclud branch-ul de rebase
#  sed 's#origin/##' > branches.txt

# branches din branches.txt trebuie sa fie ordonate topologic
# raylib-cpp trebuie dupa sfml3
export BASE_BRANCHES=$(jq -c . .github/config/rebase-branches.json)

while read -r BRANCH; do
    echo "Rebasing branch: $BRANCH"

    # Daca BRANCH e in rebase-branches.json, folosesc base-ul de acolo. Daca nu, folosesc default_base = 'main'
    BASE=$(echo "$BASE_BRANCHES" | jq -r --arg BRANCH "$BRANCH" '.[$BRANCH] // "main"')

    echo "Using base: $BASE"
    git checkout -B "$BRANCH" "origin/$BRANCH"
    # git pull --rebase

    if git rebase "origin/$BASE"; then
        echo "Rebase succeeded"
        (git push origin "$BRANCH" --force-with-lease && echo "Rebased $BRANCH") || echo "Push failed"
    else
        echo "Conflict on $BRANCH"
        git rebase --abort
    fi
    echo "-----------------------------------"
done <<< "$(cat branches.txt)"
