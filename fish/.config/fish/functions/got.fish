function got --wraps='go clean -testcache && gotestsum --format dots' --description 'alias got go clean -testcache && gotestsum --format dots'
    go clean -testcache && gotestsum --format dots $argv
end
