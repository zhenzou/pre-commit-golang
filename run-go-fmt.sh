#!/bin/bash
# This file modified from k8s
# https://github.com/kubernetes/kubernetes/blob/master/hooks/pre-commit

# How to use this hook?
# ln -s hooks/pre-commit .git/hooks/
# In case hook is not executable
# chmod +x .git/hooks/pre-commit

readonly reset=$(tput sgr0)
readonly red=$(tput bold; tput setaf 1)
readonly green=$(tput bold; tput setaf 2)

exit_code=0

# comment it by default. You can uncomment it.
# echo -ne "Checking that it builds..."
# if ! OUT=$(make 2>&1); then
#     echo
#     echo "${red}${OUT}"
#     exit_code=1
# else
#     echo "${green}OK"
# fi
# echo "${reset}"

echo -ne "Checking for files that need gofmt... "
files_need_gofmt=()
files=($(git diff --cached --name-only --diff-filter ACM | grep ".go$" | grep -v -e "vendor"))
for file in "${files[@]}"; do
    # Check for files that fail gofmt.
    disable="$(grep @formatter:off $file)"
    # 模仿 IDEA的设置，禁用fmt
    if [[ -n "$disable" ]]; then
        continue
    fi
    diff="$(git show ":${file}" | gofmt -s -d 2>&1)"
    if [[ -n "$diff" ]]; then
        files_need_gofmt+=("${file}")
    fi
done

if [[ "${#files_need_gofmt[@]}" -ne 0 ]]; then
    echo "${red}ERROR!"
    echo "Some files have not been gofmt'd. To fix these errors, "
    echo "copy and paste the following:"
    echo "  gofmt -s -w ${files_need_gofmt[@]}"
    exit_code=1
else
    echo "${green}OK"
fi
echo "${reset}"

if [[ "${exit_code}" != 0 ]]; then
    echo "${red}Aborting commit${reset}"
fi
exit ${exit_code}
