function dadn --description 'Delete all Docker networks'
    for id in (docker network ls | awk 'NR>1 { print $1 }')
        docker network rm $id
    end
end
