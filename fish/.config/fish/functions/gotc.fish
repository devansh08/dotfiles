function gotc --wraps='go clean -testcache && gotestsum --format dots -- -coverprofile=cover.out ./... && go tool cover -html=cover.out' --description 'alias gotc go clean -testcache && gotestsum --format dots -- -coverprofile=cover.out ./... && go tool cover -html=cover.out'
    go clean -testcache && gotestsum --format dots -- -coverprofile=cover.out ./... && go tool cover -html=cover.out $argv
end
