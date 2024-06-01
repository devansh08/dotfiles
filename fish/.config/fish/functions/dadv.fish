function dadv --description 'Delete all Docker volumes'
    for id in (docker volume ls | awk 'NR>1 { print $2 }')
        docker volume rm -f $id
    end
end
