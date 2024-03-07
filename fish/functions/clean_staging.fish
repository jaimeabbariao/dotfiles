function clean_staging
    git branch -D staging
    git fetch origin staging
    git checkout staging
end
