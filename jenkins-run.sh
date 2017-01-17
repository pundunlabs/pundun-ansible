#! /bin/bash
_publish(){
    for id in "${ids[@]}"
    do
	local image=`docker ps --filter id="$id" | grep -v ID | awk '{print $2}'`
	echo "commiting: ""$id " "$image"
	docker commit "$id" "$image"
	docker stop "$id"
	echo "pushing: ""$id " "$image"
	docker push "$image"
    done
}

dcleanup(){
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

tag="$(git ls-remote --tags https://github.com/pundunlabs/pundun.git | cut -d "/" -f 3 |grep -v -|grep -v {| sort -n -t. -k1 -k2 -k3 -r | head -n1)"
#run containers
ids[1]=$(docker run -d -P  pundunlabs/pundun-$tag:centos-7)
ids[2]=$(docker run -d -P  pundunlabs/pundun-$tag:centos-6.7)
ids[3]=$(docker run -d -P  pundunlabs/pundun-$tag:ubuntu-16.04)
ids[4]=$(docker run -d -P  pundunlabs/pundun-$tag:ubuntu-14.04)
#deploy with ansible
./docker_play.sh
_publish $tag
#Cleanup dangling images
dcleanup || exit 0
