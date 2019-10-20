#!/bin/bash
#
# Tag a Docker image and push the Docker image to Docker Hub.

################################################################################
# Configuration
################################################################################
# Fail on first error
set -e

################################################################################
# Constants
################################################################################


################################################################################
# Global variables
################################################################################


################################################################################
# Functions
################################################################################
########################################
# Tag a Docker image and push the Docker image to Docker Hub.
#
# Globals:
#   None
# Arguments:
#   image_name_and_tag Name and tag of the image.
#   git_branch_name Git branch name.
#   git_tag_name Git tag name.
#   git_pull_request_name Git PR name.
# Returns:
#   None
########################################
docker::tag_and_push() {
  local image_name_and_tag="${1}"
  local docker_username="${2}"
  local git_branch_name="${3}"
  local git_tag_name="${4}"
  local git_pull_request_name="${5}"

  readonly PUSH_BRANCHES=( 'master' )
  if [[ ! ${PUSH_BRANCHES[*]} =~ ${git_branch_name} ]] && \
     [[ -z "${git_tag_name}" ]]; then
    echo "Skipping tagging and pushing of Docker image(s) for branch" \
         "'${git_branch_name}'..."
    return
  fi

  if [[ "${git_pull_request_name}" != "false" ]]; then
    echo "Skipping tagging and pushing of Docker image for PR" \
         "'${git_pull_request_name}'..."
    return
  fi

  if [[ -n "${git_tag_name}" ]]; then
    echo "Tagging Docker images as"\
         "'${docker_username}/${image_name_and_tag}-${git_tag_name}'" \
         "and '${docker_username}/${image_name_and_tag}-latest'"
    docker tag "${image_name_and_tag}" "${docker_username}/${image_name_and_tag}-${git_tag_name}"
    docker tag "${image_name_and_tag}" "${docker_username}/${image_name_and_tag}-latest"
    docker push "${docker_username}/${image_name_and_tag}-${git_tag_name}"
    docker push "${docker_username}/${image_name_and_tag}-latest"
  else
    echo "Tagging Docker image as" \
         "'${docker_username}/${image_name_and_tag}-${git_branch_name}'"
    docker tag "${image_name_and_tag}" "${docker_username}/${image_name_and_tag}-${git_branch_name}"
    docker push "${docker_username}/${image_name_and_tag}-${git_branch_name}"
  fi
}

main() {
  docker::tag_and_push "${@}"
}

main "${@}"