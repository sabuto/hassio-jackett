set -ev


docker login -u  "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

docker pull homeassistant/amd64-builder

docker run --rm --privileged \
	-v /var/run/docker.sock:/var/run/docker.sock \
        -v /home/travis/.docker:/root/.docker \
	-v "$(pwd)":/data \
	homeassistant/amd64-builder \
	--target jackett \
	--amd64