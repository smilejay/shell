#!/bin/bash
#git_search_keyword.sh

function usage()
{
    echo "================================================================"
    echo "error! usage: sh $0 your-keyword"
    echo "example: sh $0 helloworld"
    echo "================================================================"
}

function git_info()
{
    echo "=========================== INFO ==============================="
    echo "current keyword: $keyword"
    echo "current branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "current commit id: $(git rev-parse --short HEAD)"
    echo "if you want to use another branch, please git checkout to that branch first."
    echo "================================================================"
}

function git_find_keyword()
{
    commit_ids=$(git log --oneline -S "$keyword" --pretty=format:"%h %an %ae")
    if [ "X$commit_ids" == "X" ]; then
        echo "error! can NOT find your keyword: $keyword"
        exit 1
    fi
    echo "$commit_ids" | while read line
    do
        commit_id=$(echo "$line" | cut -d' ' -f1)
        author=$(echo "$line" | cut -d' ' -f2)
        email=$(echo "$line" | cut -d' ' -f3)
        keyword_lines=$(git --no-pager show $commit_id | grep "$keyword" | sort -n | uniq | cut -d"+" -f2)
        if [ -n "$keyword_lines" ];then
            echo "$commit_id $author $email"
            echo "$keyword_lines"
        fi
    done
}

keyword="$1"
if [ "X$keyword" == "X" ]; then
    usage
    exit 1
fi

git_info
git_find_keyword
