function workstation() {
  echo "[CREATE] Workstation (~/src/workstation)"
  # create the workstation
  docker run \
    -d \
    --privileged \
    -p 127.0.0.1:8200:8200/tcp \
    -v ${PWD}:/workstation \
    --name \
      workstation \
    workstation
  # exec into the workstation
  docker exec -it workstation /bin/sh
  echo "Done working..."
  echo "[STOP] Workstation"
  docker ps -a -q --filter="name=workstation" | xargs -I{} docker stop {}
  echo "[CLEANUP] Workstation"
  docker ps -a -q --filter="name=workstation" | xargs -I{} docker rm {}
}
