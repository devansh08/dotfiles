function dadc --description 'Delete all Docker containers'
    for id in (docker container ls -a | awk 'NR>1 { print $1 }')
        docker container rm -fv $id
    end
end
