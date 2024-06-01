function dadi --description 'Delete all Docker images'
    for id in (docker image ls -a | awk 'NR>1 { print $3 }')
        docker image rm -f $id
    end
end
